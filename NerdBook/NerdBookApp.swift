//
//  NerdBookApp.swift
//  NerdBook
//
//  Created by Piero Sierra on 05/09/2024.
//

import SwiftUI
import Cocoa
import AppKit

// MARK: - Liquid Glass Extensions (macOS Tahoe support)

extension View {
    /// Applies the system-managed Liquid Glass toolbar surface on macOS 26+.
    ///
    /// This must be attached to the view that owns `.toolbar { ... }` so the OS can
    /// treat it as window chrome. We intentionally do not hardcode blur/opacity.
    @ViewBuilder
    func nerdBookWindowToolbarLiquidGlass() -> some View {
        if #available(macOS 26.0, *) {
            self
                .toolbarBackground(.visible, for: .windowToolbar)
        } else {
            self
        }
    }

    /// Applies Liquid Glass distortion effect on macOS 26+ (Tahoe),
    /// falling back to thin material blur on earlier systems.
    @ViewBuilder
    func nerdBookGlassEffect() -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(.regular)
        } else {
            self.background(.thinMaterial)
        }
    }
}

extension Scene {
    /// Use unified toolbar style which participates in Tahoe's Liquid Glass chrome on macOS 26+.
    func nerdBookWindowToolbarStyleForTahoe() -> some Scene {
        self.windowToolbarStyle(.unified)
    }
}

@main
struct NerdBookApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowToolbarStyle(.unified)
    }
}

// Translucent window style
struct TranslucentBackgroundView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.blendingMode = .behindWindow
        effectView.material = .hudWindow
        effectView.state = .active
        return effectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// Helper view to access the NSWindow and modify its properties
struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {  // Access the window asynchronously
            if let window = nsView.window {
                callback(window)
            }
        }
        return nsView
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
