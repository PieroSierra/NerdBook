//
//  AboutWindowController.swift
//  NerdBook
//
//  Presents the About box as a standalone popup window.
//  Pattern adapted from SoftBurn.
//

import AppKit
import SwiftUI

final class AboutWindowController {
    static let shared = AboutWindowController()

    private var window: NSWindow?

    private init() {}

    @MainActor
    func show() {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hostingView = NSHostingView(rootView: AboutView())

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.isReleasedWhenClosed = false
        window.title = ""
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.center()
        window.contentView = hostingView

        self.window = window

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
