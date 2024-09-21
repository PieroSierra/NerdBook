//
//  NerdBookiOSApp.swift
//  NerdBookiOS
//
//  Created by Piero Sierra on 14/09/2024.
//

import SwiftUI
import UIKit

@main
struct NerdBookiOSApp: App {
    // Create an instance of AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    // Lock orientation to portrait only
    var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
}
