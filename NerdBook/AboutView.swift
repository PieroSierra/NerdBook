//
//  AboutView.swift
//  NerdBook
//
//  About dialog with Tip Jar IAP section.
//  Pattern adapted from SoftBurn.
//

import AppKit
import SwiftUI

// MARK: - About View

struct AboutView: View {
    @ObservedObject private var tipJar = TipJarManager.shared
    @State private var showThankYouAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String?
    @State private var showAcknowledgements = false

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? "NerdBook"
    }

    private var versionLine: String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (shortVersion, build) {
        case let (.some(v), .some(b)):
            return "Version \(v) (\(b))"
        case let (.some(v), .none):
            return "Version \(v)"
        case let (.none, .some(b)):
            return "Build \(b)"
        default:
            return "Version —"
        }
    }

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            HStack(alignment: .top, spacing: 20) {
                // App icon
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: Color.black.opacity(0.15), radius: 18, x: 6, y: 6)

                VStack(alignment: .leading, spacing: 12) {
                    Text(appName)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text("\(versionLine)\nCopyright © 2024 Piero Sierra. All rights reserved.")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    //Text("Finds synonyms for the selected word, sorted by normal, poetic (more lyrical words first), or nerdy (latin & greek words first). Rap mode shows words that sound like the selected word.")
                      //  .font(.system(size: 11))
                     //   .foregroundStyle(.secondary)
                      //  .fixedSize(horizontal: false, vertical: true)

                    Spacer().frame(height: 4)

                    // Tip Jar Section
                    TipJarSection(
                        tipJar: tipJar,
                        onPurchaseComplete: {
                            showThankYouAlert = true
                        },
                        onPurchaseError: { message in
                            errorMessage = message
                            showErrorAlert = true
                        }
                    )

                    Spacer()

                    HStack {
                        Spacer()
                        Button("Acknowledgements") {
                            showAcknowledgements = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .frame(width: 640, height: 400)
        .task {
            await TipJarManager.shared.loadProducts()
        }
        .alert("Thank you!", isPresented: $showThankYouAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your support means a lot ❤️")
        }
        .alert("Purchase not completed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            } else {
                Text("No worries — thanks for trying NerdBook!")
            }
        }
        .sheet(isPresented: $showAcknowledgements) {
            AcknowledgementsView()
        }
    }
}

// MARK: - Acknowledgements View

struct AcknowledgementsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acknowledgements")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView {
                Text(
                    """
                    **Synonym & Word Data**
                    Powered by [DataMuse](https://www.datamuse.com/) — a word-finding query engine used by millions of writers, developers, and linguists.

                    **Word of the Day**
                    Word of The Day selection by [Merriam-Webster](https://www.merriam-webster.com/).

                    **Made with ❤️**
                    For Mila — Papa.
                    """
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(minWidth: 400, minHeight: 260)
    }
}

// MARK: - Tip Jar Section

struct TipJarSection: View {
    @ObservedObject var tipJar: TipJarManager
    let onPurchaseComplete: () -> Void
    let onPurchaseError: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NerdBook is free. Coffee is not. Buy me a cup?")
                //.font(.system(size: 11))
                //.foregroundStyle(.secondary)

            Spacer().frame(height: 2)

            HStack(spacing: 24) {
                ForEach(TipJarManager.TipTier.allCases, id: \.self) { tier in
                    TipOptionView(
                        tier: tier,
                        tipJar: tipJar,
                        onPurchaseComplete: onPurchaseComplete,
                        onPurchaseError: onPurchaseError
                    )
                }
            }
        }
    }
}

// MARK: - Tip Option View

struct TipOptionView: View {
    let tier: TipJarManager.TipTier
    @ObservedObject var tipJar: TipJarManager
    let onPurchaseComplete: () -> Void
    let onPurchaseError: (String) -> Void

    private var isPurchasing: Bool {
        tipJar.purchasingTier == tier
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(tier.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text(tier.displayName)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Button {
                Task {
                    await purchaseTip()
                }
            } label: {
                if isPurchasing {
                    ProgressView()
                        .controlSize(.small)
                        .frame(minWidth: 60)
                } else {
                    Text(tipJar.price(for: tier))
                        .frame(minWidth: 60)
                }
            }
            .buttonStyle(.bordered)
            .disabled(isPurchasing || !tipJar.isProductAvailable(tier))
        }
        .frame(maxWidth: .infinity)
    }

    private func purchaseTip() async {
        let result = await tipJar.purchase(tier)

        switch result {
        case .success:
            onPurchaseComplete()

        case .failure(let error):
            if let tipError = error as? TipJarError {
                switch tipError {
                case .userCancelled:
                    break // Don't show an error for user cancellation
                default:
                    onPurchaseError("No worries — thanks for trying NerdBook!")
                }
            } else {
                onPurchaseError("No worries — thanks for trying NerdBook!")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AboutView()
        .frame(width: 640, height: 400)
}
