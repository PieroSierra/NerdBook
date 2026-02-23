import SwiftUI
import AppKit

// MARK: - ContentView

struct ContentView: View {
    @ObservedObject var dataMuse = DataMuse()
    @State private var query: String = ""
    @State private var showAbout: Bool = false
    @State private var showAboutDialog: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isUserSelecting: Bool = false
    @State private var hasSearched: Bool = false
    @State private var showDefinitionsSheet: Bool = false
    @State private var selectedSuggestionIndex: Int = -1
    @State private var isReady: Bool = false
    @Environment(\.colorScheme) var colorScheme // for DarkMode detection

    init(dataMuse: DataMuse = DataMuse(), query: String = "", hasSearched: Bool = false) {
        self.dataMuse = dataMuse
        _query = State(initialValue: query)
        _hasSearched = State(initialValue: hasSearched)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background using system window color (adapts to dark/light mode automatically)
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()

            // MARK: - Tap Dismiss Overlay

            // Clear overlay for tap detection
            Color.clear // Use clear color to detect taps
                .contentShape(Rectangle()) // This makes the entire area tappable
                .frame(minWidth: 600, minHeight: 400)
                .onTapGesture {
                    isTextFieldFocused = false // Dismiss keyboard when tapping the background
                    isUserSelecting = true
                    dataMuse.suggestions.removeAll()  // Hide suggestions after selection
                }

            VStack {    // Main layer VStack

                // MARK: - Search Bar

                HStack {
                    NeumorphicStyleTextField(text: $query, imageName: "magnifyingglass", placeholder: "Find word...") {
                        dataMuse.debounceTimer?.invalidate()  // Cancel the debounce timer when pressing "Enter"
                        dataMuse.fetchSynonyms(query: query)
                        hasSearched = true
                        isUserSelecting = true
                        dataMuse.suggestions.removeAll()  // Hide suggestions after selection
                    } onCancel: {
                        clearSearch()
                    }
                    .focused($isTextFieldFocused)
                    .onChange(of: query) { newValue in
                        if isUserSelecting {
                            isUserSelecting = false  // Reset the flag after selection
                        } else if !newValue.isEmpty {
                            dataMuse.fetchSuggestions(for: newValue)  // Only fetch suggestions if not selecting
                        } else {
                            dataMuse.suggestions.removeAll()
                        }
                    }
                }
                .padding(EdgeInsets(top: 20, leading:30, bottom: 20, trailing: 30))

                // MARK: - Content Area (WOTD or Synonym Columns)

                if !hasSearched {
                    // Empty state: show Word of the Day
                    if let wotdWord = dataMuse.wotdWord {
                        WordOfTheDayView(word: wotdWord, definition: dataMuse.wotdDefinition)
                            .transition(.opacity.animation(.easeIn(duration: 0.4)))
                    } else {
                        Spacer()
                    }
                } else {
                    // Search results: show synonym columns
                    HStack(alignment:.top, spacing: 0){
                        SynonymColumnView(
                            title: "🙂 Synonyms",
                            words: dataMuse.synonyms,
                            colorScheme: colorScheme,
                            onWordSelected: { word in handleWordSelected(word) }
                        )
                        SynonymColumnView(
                            title: "😇 Poetic",
                            words: dataMuse.lyricalSynonyms,
                            colorScheme: colorScheme,
                            onWordSelected: { word in handleWordSelected(word) }
                        )
                        SynonymColumnView(
                            title: "🤓 Nerdy",
                            words: dataMuse.pretentiousSynonyms,
                            colorScheme: colorScheme,
                            onWordSelected: { word in handleWordSelected(word) }
                        )
                        SynonymColumnView(
                            title: "🎧 Sounds Like",
                            words: dataMuse.soundsLikeWords,
                            colorScheme: colorScheme,
                            onWordSelected: { word in handleWordSelected(word) }
                        )
                    }
                    .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 30))
                    .frame(maxWidth: .infinity)
                }

                Spacer()
            } // END OF LAYER 1 VSTACK

            // MARK: - Overlays (Autocomplete, Loading, Network Error, Definition)

            if !dataMuse.suggestions.isEmpty && isReady {
                AutocompleteSuggestionsView(
                    suggestions: dataMuse.suggestions,
                    colorScheme: colorScheme,
                    selectedIndex: $selectedSuggestionIndex,
                    onSelect: { suggestion in
                        isUserSelecting = true
                        hasSearched = true
                        query = suggestion
                        dataMuse.fetchSynonyms(query: query)
                        dataMuse.suggestions.removeAll()
                        selectedSuggestionIndex = -1
                    },
                    onDismiss: {
                        dataMuse.debounceTimer?.invalidate()
                        isUserSelecting = true
                        dataMuse.suggestions.removeAll()
                        selectedSuggestionIndex = -1
                    }
                )
            }

            loadingOverlay
            networkErrorOverlay

            if let definition = dataMuse.currentDefinition {
                DefinitionBarView(definition: definition, onTap: {
                    dataMuse.fetchInspiration(query: query)
                    showDefinitionsSheet = true
                })
            }

        } // END OF MAIN Z STACK VIEW
        .onAppear {
            dataMuse.fetchWordOfTheDayIfNeeded()
            DispatchQueue.main.async { isReady = true }
        }
        .onChange(of: dataMuse.suggestions) {
            selectedSuggestionIndex = -1
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                let keyCode = event.keyCode

                if keyCode == 53 { // ESC
                    if showDefinitionsSheet {
                        showDefinitionsSheet = false
                    } else if !dataMuse.suggestions.isEmpty {
                        // Dismiss dropdown only — keep query text
                        isUserSelecting = true
                        dataMuse.suggestions.removeAll()
                        selectedSuggestionIndex = -1
                    } else {
                        clearSearch()
                    }
                    return nil
                }

                guard !dataMuse.suggestions.isEmpty else { return event }

                if keyCode == 125 { // Down arrow
                    selectedSuggestionIndex = min(selectedSuggestionIndex + 1,
                                                  dataMuse.suggestions.count - 1)
                    return nil
                }
                if keyCode == 126 { // Up arrow
                    if selectedSuggestionIndex > 0 {
                        selectedSuggestionIndex -= 1
                    } else {
                        selectedSuggestionIndex = -1
                    }
                    return nil
                }
                if keyCode == 36, selectedSuggestionIndex >= 0 { // Return with selection
                    let word = dataMuse.suggestions[selectedSuggestionIndex]
                    isUserSelecting = true
                    hasSearched = true
                    query = word
                    dataMuse.fetchSynonyms(query: word)
                    dataMuse.suggestions.removeAll()
                    selectedSuggestionIndex = -1
                    return nil
                }

                return event
            }
        }

        // MARK: - Toolbar

        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { AboutWindowController.shared.show() }) {
                    Image(systemName: "cup.and.heat.waves.fill")
                    Text("Like this?")
                }
                .help("About NerdBook")
            }
        }
        .frame(minWidth: 680, minHeight: 420)  // Ensure the min size is respected in the view
        .background(WindowAccessor { window in
            // Set the initial size of the window when it is first created
            window.setContentSize(NSSize(width: 680, height: 420))
            window.minSize = NSSize(width: 680, height: 420)  // Set the minimum size
        })
        .nerdBookWindowToolbarLiquidGlass()
        .sheet(isPresented: $showDefinitionsSheet) {
            DefinitionsSheetView(
                word: query,
                definitions: dataMuse.currentDefs,
                triggerWords: dataMuse.triggerWords,
                onWordSelected: { selectedWord in
                    showDefinitionsSheet = false
                    isUserSelecting = true
                    query = selectedWord
                    dataMuse.fetchSynonyms(query: query)
                }
            )
            .frame(minWidth: 600, minHeight: 450)
        }
    }

    // MARK: - Private Helpers

    private func handleWordSelected(_ word: String) {
        isUserSelecting = true
        hasSearched = true
        query = word
        dataMuse.fetchSynonyms(query: query)
    }

    private func clearSearch() {
        dataMuse.debounceTimer?.invalidate()
        hasSearched = false
        isUserSelecting = true
        query = ""
        dataMuse.suggestions.removeAll()
        dataMuse.synonyms.removeAll()
        dataMuse.lyricalSynonyms.removeAll()
        dataMuse.pretentiousSynonyms.removeAll()
        dataMuse.soundsLikeWords.removeAll()
        dataMuse.currentDefinition = nil
        dataMuse.currentDefs.removeAll()
        dataMuse.triggerWords.removeAll()
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if dataMuse.isLoading == true {
            VStack {
                Spacer()
                ProgressView().controlSize(.extraLarge)
                Spacer().frame(height: 150)
            }
        }
    }

    @ViewBuilder
    private var networkErrorOverlay: some View {
        if dataMuse.networkAvailable == false {
            VStack {
                Spacer()
                HStack {
                    Spacer().frame(width:50, height:50)
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.gray)
                    Text ("No connection")
                    Spacer().frame(width:50)
                }
                .shadow(color: colorScheme == .dark ? Color.clear : Color.lightShadow, radius: 3, x: -2, y: -2)
                .transition(.opacity)
                Spacer().frame(height: 100)
            }
        }
    }
} // END OF MAIN VIEW

// MARK: - Previews

#Preview("Main App") {
    ContentView()
        .frame(width: 680, height: 420)
}

#Preview("Search Results") {
    let dm = DataMuse()
    dm.synonyms = [
        Word(word: "raid", frequency: 12.0),
        Word(word: "incursion", frequency: 3.2),
        Word(word: "sortie", frequency: 2.1),
        Word(word: "attack", frequency: 18.0),
        Word(word: "assault", frequency: 10.5),
        Word(word: "expedition", frequency: 6.0),
        Word(word: "venture", frequency: 8.0),
        Word(word: "sally", frequency: 1.8),
        Word(word: "invasion", frequency: 9.0),
        Word(word: "onset", frequency: 4.5),
    ]
    dm.lyricalSynonyms = [
        Word(word: "sally", numSyllables: 2, frequency: 1.8),
        Word(word: "sortie", numSyllables: 2, frequency: 2.1),
        Word(word: "venture", numSyllables: 2, frequency: 8.0),
        Word(word: "incursion", numSyllables: 3, frequency: 3.2),
        Word(word: "expedition", numSyllables: 4, frequency: 6.0),
    ]
    dm.pretentiousSynonyms = [
        Word(word: "incursion", frequency: 3.2),
        Word(word: "sortie", frequency: 2.1),
        Word(word: "sally", frequency: 1.8),
        Word(word: "expedition", frequency: 6.0),
        Word(word: "assault", frequency: 10.5),
    ]
    dm.soundsLikeWords = [
        Word(word: "foyer", frequency: 5.0),
        Word(word: "fray", frequency: 7.0),
        Word(word: "hurray", frequency: 3.0),
        Word(word: "hooray", frequency: 4.0),
    ]
    dm.currentDefinition = "a sudden or irregular invasion or attack for war or spoils"
    return ContentView(dataMuse: dm, query: "foray", hasSearched: true)
        .frame(width: 680, height: 420)
}
