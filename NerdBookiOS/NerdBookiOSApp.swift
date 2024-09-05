// TODO:
// [X] Add "x" on neuromorphic edit field
// [x] Add Info on words wiht a sheet - sounds like, frequency, etc
// [x] Add definition on the widget
// [x] Refactor Shared Code to only call extra info on click
// [x] Add SoundsLike
// [x] Add Max search results
// [x] Add color on half-sheet
// [x] Rapper mode
// [X] Add Dark mode icon
// [x] make Definitions semi-transparent
// [x] Add entrance effects for Pop icons
// [x] make Definitions a hit-target
// [x] add Mic jump
// [x] add mic on/off


import SwiftUI

@main
struct NerdBookiOSApp: App {
    @State private var initialWord: String?

    var body: some Scene {
        WindowGroup {
            ContentView(initialWord: $initialWord)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        print("Handling URL: \(url)")
        
        switch url.scheme {
        case "nerdbook":
            handleNerdBookURL(url)
        case "triggerword":
            handleTriggerWordURL(url)
        default:
            print("Unknown URL scheme: \(url.scheme ?? "nil")")
        }
    }

    // Handles nerdbook:// URLs
    private func handleNerdBookURL(_ url: URL) {
        guard let word = url.host, !word.isEmpty else {
            print("Invalid nerdbook URL or empty word")
            return
        }
        print("Setting initialWord to: \(word)")
        initialWord = word
    }

    // Handles triggerword:// URLs
    private func handleTriggerWordURL(_ url: URL) {
        guard let word = url.host, !word.isEmpty else {
            print("Invalid triggerword URL or empty word")
            return
        }
        print("Trigger word selected: \(word)")
        // Call the function that processes the trigger word selection
    }
    
}

// App State variables -- visible from All passed around using the @EnvironmentObject or @ObservedObject property wrappers.
class AppState: ObservableObject {
    @Published var showingAboutSheet: Bool = false // Shared state for showing the About sheet
    @Published var showingTriggerSheet: Bool = false // Shared state for showing the Trigger sheet
}
