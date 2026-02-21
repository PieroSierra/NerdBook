//
//  TipJarManager.swift
//  NerdBook
//
//  Manages In-App Purchase tips using StoreKit 2.
//  Pattern adapted from SoftBurn.
//

import Foundation
import StoreKit
import Combine

@MainActor
final class TipJarManager: ObservableObject {
    static let shared = TipJarManager()

    // MARK: - Tip Tiers
    // NOTE: Product IDs must match exactly what is configured in App Store Connect.
    // Update these strings if your App Store Connect product IDs differ.
    enum TipTier: String, CaseIterable {
        case espresso = "nerdbook.tip.espresso"
        case latte    = "nerdbook.tip.latte"
        case venti    = "nerdbook.tip.venti"

        var displayName: String {
            switch self {
            case .espresso: return "Espresso"
            case .latte:    return "Latte"
            case .venti:    return "Venti"
            }
        }

        var imageName: String {
            switch self {
            case .espresso: return "coffee_small"
            case .latte:    return "coffee_medium"
            case .venti:    return "coffee_large"
            }
        }
    }

    // MARK: - Published State

    @Published private(set) var products: [TipTier: Product] = [:]
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var purchasingTier: TipTier?

    private var updateListenerTask: Task<Void, Never>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async {
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let productIdentifiers = TipTier.allCases.map { $0.rawValue }
            print("TipJarManager: Requesting products: \(productIdentifiers)")
            let storeProducts = try await Product.products(for: productIdentifiers)
            print("TipJarManager: Received \(storeProducts.count) products: \(storeProducts.map(\.id))")

            var loadedProducts: [TipTier: Product] = [:]
            for product in storeProducts {
                if let tier = TipTier(rawValue: product.id) {
                    loadedProducts[tier] = product
                } else {
                    print("TipJarManager: ⚠️ No TipTier match for product.id='\(product.id)'")
                }
            }
            self.products = loadedProducts
            print("TipJarManager: products dict now has \(self.products.count) entries")
        } catch {
            print("TipJarManager: ❌ Failed to load products: \(error) — \(error.localizedDescription)")
        }
    }

    // MARK: - Purchase

    func purchase(_ tier: TipTier) async -> Result<Void, Error> {
        guard let product = products[tier] else {
            return .failure(TipJarError.productNotAvailable)
        }

        guard purchasingTier == nil else {
            return .failure(TipJarError.purchaseInProgress)
        }

        purchasingTier = tier
        defer { purchasingTier = nil }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()
                return .success(())

            case .userCancelled:
                return .failure(TipJarError.userCancelled)

            case .pending:
                return .failure(TipJarError.pending)

            @unknown default:
                return .failure(TipJarError.unknown)
            }
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Helpers

    func price(for tier: TipTier) -> String {
        guard let product = products[tier] else {
            switch tier {
            case .espresso: return "£2"
            case .latte:    return "£5"
            case .venti:    return "£8"
            }
        }
        return product.displayPrice
    }

    func isProductAvailable(_ tier: TipTier) -> Bool {
        return products[tier] != nil
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try Self.checkVerified(result)
                    await transaction.finish()
                } catch {
                    print("TipJarManager: Transaction verification failed: \(error)")
                }
            }
        }
    }

    private nonisolated static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw TipJarError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Error Types

enum TipJarError: LocalizedError {
    case productNotAvailable
    case purchaseInProgress
    case userCancelled
    case pending
    case unknown
    case unverifiedTransaction

    var errorDescription: String? {
        switch self {
        case .productNotAvailable:    return "Product not available"
        case .purchaseInProgress:     return "Purchase already in progress"
        case .userCancelled:          return "Purchase cancelled"
        case .pending:                return "Purchase pending"
        case .unknown:                return "Unknown error"
        case .unverifiedTransaction:  return "Transaction verification failed"
        }
    }
}
