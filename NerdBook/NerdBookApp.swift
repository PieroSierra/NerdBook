//
//  NerdBookApp.swift
//  NerdBook
//
//  Created by Piero Sierra on 05/09/2024.
//

import SwiftUI
import Cocoa
import AppKit

@main
struct NerdBookApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView() // Your main view
            //                .background(TranslucentBackgroundView())
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        // Enable translucency
                    //    window.isOpaque = false
                    //    window.backgroundColor = NSColor.clear
                    //    window.titlebarAppearsTransparent = true
                    //    window.titleVisibility = .hidden
                        
                        // Ensure toolbar is displayed
                        window.styleMask.insert(.titled)
                        window.styleMask.insert(.fullSizeContentView)
                        window.toolbar = NSToolbar() // Adding a toolbar
                    }
                }
        }
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
