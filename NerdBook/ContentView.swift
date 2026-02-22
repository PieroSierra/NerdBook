import SwiftUI
import AppKit

// MARK: - ContentView

struct ContentView: View {
    @ObservedObject var dataMuse = DataMuse()
    @State private var query: String = ""
    @State private var showAbout: Bool = false
    @State private var showAboutDialog: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isUserSelecting: Bool = false  // flag to track selection
    @State private var hasSearched: Bool = false  // true after Enter/submit, false after ESC/clear
    @State private var showDefinitionsSheet: Bool = false
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

            if !dataMuse.suggestions.isEmpty {
                AutocompleteSuggestionsView(
                    suggestions: dataMuse.suggestions,
                    colorScheme: colorScheme,
                    onSelect: { suggestion in
                        isUserSelecting = true
                        hasSearched = true
                        query = suggestion
                        dataMuse.fetchSynonyms(query: query)
                        dataMuse.suggestions.removeAll()
                    },
                    onDismiss: {
                        dataMuse.debounceTimer?.invalidate()
                        isUserSelecting = true
                        dataMuse.suggestions.removeAll()
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
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { // ESC key
                    if showDefinitionsSheet {
                        showDefinitionsSheet = false
                    } else {
                        clearSearch()
                    }
                    return nil // consume the event, no beep
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

// MARK: - WordOfTheDayView

struct WordOfTheDayView: View {
    let word: String
    let definition: String?

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 4) {
                Text("\u{201C}")
                    .font(.custom("American Typewriter", size: 50))
                    .foregroundColor(.gray)
                    .baselineOffset(10)
                Text(word)
                    .font(.custom("American Typewriter", size: 28).bold())
                    .lineLimit(1)
            }

            Rectangle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 200, height: 1)

            if let definition = definition, definition != "No definition available" {
                Text(definition)
                    .font(.custom("American Typewriter", size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(7)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: 480)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - SynonymColumnView

struct SynonymColumnView: View {
    let title: String
    let words: [Word]
    let colorScheme: ColorScheme
    let onWordSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.body)
//                .font(.custom("American Typewriter", size: 13))
       //         .foregroundColor(.secondary)
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(words, id: \.word) { synonym in
                        ColorButton(
                            text: synonym.word,
                            fontSize: 14,
                            colorScheme: colorScheme,
                            action: {
                                onWordSelected(synonym.word)
                            },
                            onAnimationComplete: {}
                        )
                    }
                }
                .padding(.top, 2)
                .padding(.leading, 2)
                .padding(.bottom, 10)
            }
        }
        .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
        .clipped()
    }
}

// MARK: - AutocompleteSuggestionsView

struct AutocompleteSuggestionsView: View {
    let suggestions: [String]
    let colorScheme: ColorScheme
    let onSelect: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            Spacer().frame(height: 62)  // Position it below the TextField
            List(suggestions, id: \.self) { suggestion in
                Text(suggestion)
                    .foregroundColor(colorScheme == .dark ? Color.pinkColor : .blue)
                    .onTapGesture {
                        onSelect(suggestion)
                    }
            }
            .onKeyPress(.escape) {            // <ESCAPE> key tracking
#if DEBUG
                print ("ESC key pressed - Autocomplete window")
#endif
                onDismiss()
                return .handled
            }
            .frame(width: 400, height: 120)  // Limit the height of the suggestions list
            .background(colorScheme == .dark ? Color.black : Color.white)  // Ensure the list has a background color
            .cornerRadius(8)  // Add some corner radius
            .shadow(radius: 10)  // Add shadow to the dropdown
            Spacer()
        } // end VSTACK
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity)  // Smooth transition when showing/hiding
        .padding()
        .padding(.leading, 20)

        VStack {
            Spacer().frame(height: 65)
            HStack{
                Spacer().frame(width: 80)
                Triangle()
                    .fill(colorScheme == .dark ? Color(hex: 0x2c2e2f) : Color.white)
                    .frame(width: 25, height: 13)
                    .opacity(1)
                Spacer()
            }
            Spacer()
        }
    }
}

// MARK: - DefinitionBarView

struct DefinitionBarView: View {
    let definition: String
    let onTap: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Spacer().frame(width: 20)
                    Text("Def. ")
                        .font(.headline)
                    Text(definition)
                        .font(.body)
                        .italic()
                        .lineLimit(2)
                        .truncationMode(.tail)
                    Spacer()
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(definition, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(Color.gray)
                    }
                    .buttonStyle(.plain)
                    .help("Copy definition")
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.gray)
                        .imageScale(.large)
                        .padding(.trailing, 15)
                }
                .frame(height: 50)
            }
            .nerdBookGlassEffect()
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

// MARK: - MacDefinitionCard

struct MacDefinitionCard: View {
    @Environment(\.colorScheme) var colorScheme
    let definition: String
    @State private var scale = 0.2

    private var cleanDefinition: String {
        definition.components(separatedBy: "\t").last ?? ""
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(cleanDefinition)
                .multilineTextAlignment(.center)
                .padding()
                .frame(width: 220, height: 136, alignment: .center)
                .font(.custom("American Typewriter", size: 13))
                .foregroundColor(.secondary)
                .lineLimit(5)
                .truncationMode(.tail)
            
            
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(cleanDefinition, forType: .string)
            } label: {
                Image(systemName: "doc.on.doc")
                    .foregroundStyle(Color.gray)
            }
            .buttonStyle(.plain)
            .help("Copy definition")
            .padding(10)
        }
        .onAppear {
            scale = 1.0
        }
        .scaleEffect(scale)
        .animation(.bouncy(duration: 0.5), value: scale)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(15)
        .font(.body)
//        .font(.custom("American Typewriter", size: 14))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.2), radius: 5, x: 0, y: 2)
    }
}

// MARK: - DefinitionsSheetView

struct DefinitionsSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    let word: String
    let definitions: [String]
    let triggerWords: [Word]
    let onWordSelected: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                Text("\u{201C}")
                    .font(.custom("American Typewriter", size: 50))
                    .foregroundColor(.gray)
                    .baselineOffset(6)
                Text(word)
                    .font(.custom("American Typewriter", size: 28).bold())
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))

            ScrollView {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 200, height: 1)
                //    .padding(.bottom, 10)
                
                if !definitions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 20) {
                            ForEach(definitions, id: \.self) { def in
                                MacDefinitionCard(definition: def)
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("No definitions available.")
                        .padding()
                }

                if triggerWords.first != nil {
                    Text("Words associated with \(word):")
                        .padding()

                    let thresholds = calculateFrequencyThresholds(for: triggerWords)
                    FlowLayout(data: triggerWords.shuffled(), spacing: 0) { triggerWord in
                        ColorButton(
                            text: triggerWord.word,
                            fontSize: fontSize(for: triggerWord.frequency ?? 0.0, thresholds: thresholds),
                            colorScheme: colorScheme,
                            action: {
                                onWordSelected(triggerWord.word)
                            },
                            onAnimationComplete: {}
                        )
                    }
                    .padding(.horizontal, 3)
                    .padding(.vertical, 4)
                } else {
                    Text("No words associated with \(word)")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .transition(.opacity)
            .background(Color.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(dismissButton, alignment: .topTrailing)
    }

    private func fontSize(for frequency: Double, thresholds: (Double, Double)) -> CGFloat {
        switch categorizeFrequency(frequency, thresholds: thresholds) {
        case .regular:
            return 12
        case .semibold:
            return 16
        case .bold:
            return 21
        default:
            return 12
        }
    }

    private var dismissButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .imageScale(.large)
        }
        .buttonStyle(.plain)
        .padding()
    }
}

// MARK: - NeumorphicStyleTextField

struct NeumorphicStyleTextField: View {
    @Binding var text: String
    var imageName: String
    var placeholder: String
    var onSubmit: () -> Void
    var onCancel: () -> Void // Add this line
    @Environment(\.colorScheme) var colorScheme // for DarkMode detection

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(colorScheme == .dark ? Color.pinkColor : Color.blueColor)
            CustomTextField(text: $text, placeholder: placeholder, onSubmit: onSubmit, onCancel: onCancel) // Pass onCancel
                .font(.custom("Open Sans", size: 12))
                .foregroundColor(colorScheme == .dark ? Color.pinkColor : Color.blue)
                .background(Color.clear) // Ensure background is clear
                .cornerRadius(8)
            if !text.isEmpty {  // Check if the text is not empty

                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        text=""
                    }
            }
        }
        .padding()
        .foregroundColor(.neumorphictextColor)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorScheme == .dark ? Color.pinkColor : Color.blueColor,
                            colorScheme == .dark ? Color.blueColor : Color.pinkColor
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
        )
    }
}

// MARK: - CustomTextField

struct CustomTextField: NSViewRepresentable {
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: CustomTextField

        init(parent: CustomTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                parent.onSubmit()
                return true
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                parent.onCancel()
                return true
            }
            return false
        }
    }

    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme // for DarkMode detection
    var placeholder: String
    var onSubmit: () -> Void = {}
    var onCancel: () -> Void = {} // Add this line

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        let foreColor: NSColor
        if colorScheme == .dark {
            foreColor = NSColor(red: 255/255, green: 70/255, blue: 214/255, alpha: 1.0)  // Custom RGB color
        } else {
            foreColor = NSColor(red: 0/255, green: 112/255, blue: 255/255, alpha: 1.0)  // Custom RGB color
        }
        textField.placeholderString = placeholder
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.font = NSFont.systemFont(ofSize: 14)
        textField.textColor = foreColor
        textField.delegate = context.coordinator
        textField.focusRingType = .none
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text

        // Update the text color based on the color scheme
        let foreColor: NSColor
        if colorScheme == .dark {
            foreColor = NSColor(red: 255/255, green: 70/255, blue: 214/255, alpha: 1.0)  // Custom RGB color
        } else {
            foreColor = NSColor(red: 0/255, green: 112/255, blue: 255/255, alpha: 1.0)  // Custom RGB color
        }
        nsView.textColor = foreColor
    }
}

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

#Preview("Word of the Day") {
    WordOfTheDayView(
        word: "serendipity",
        definition: "the faculty or phenomenon of finding valuable or agreeable things not sought for"
    )
    .frame(width: 680, height: 420)
}

#Preview("Definitions Sheet") {
    DefinitionsSheetView(
        word: "ephemeral",
        definitions: [
            "adj\tLasting a very short time.  Like this preview text which is extremly long, and unlikely that we'll ever hit it.  Still, worth seeing how long this thing can get and if it was insanely long what would happen really?  Who know... Certainly not I.",
            "adj\tliving or lasting only for a day",
            "n\tsomething that lasts for a markedly brief time"
        ],
        triggerWords: [
            Word(word: "fleeting", frequency: 8.0),
            Word(word: "transient", frequency: 5.5),
            Word(word: "momentary", frequency: 4.2),
            Word(word: "brief", frequency: 12.0),
            Word(word: "passing", frequency: 9.0),
            Word(word: "fleeting", frequency: 8.0),
            Word(word: "transient", frequency: 5.5),
            Word(word: "momentary", frequency: 4.2),
            Word(word: "brief", frequency: 12.0),
            Word(word: "passing", frequency: 9.0),
            Word(word: "fleeting", frequency: 8.0),
            Word(word: "transient", frequency: 5.5),
            Word(word: "momentary", frequency: 4.2),
            Word(word: "brief", frequency: 12.0),
            Word(word: "passing", frequency: 9.0),
            Word(word: "fleeting", frequency: 8.0),
            Word(word: "transient", frequency: 5.5),
            Word(word: "momentary", frequency: 4.2),
            Word(word: "brief", frequency: 12.0),
            Word(word: "passing", frequency: 9.0),
            Word(word: "transient", frequency: 5.5),
            Word(word: "momentary", frequency: 4.2),
            Word(word: "brief", frequency: 12.0),
            Word(word: "passing", frequency: 9.0),
            Word(word: "fleeting", frequency: 8.0),
            Word(word: "transient", frequency: 5.5),
            Word(word: "momentary", frequency: 4.2),
            Word(word: "brief", frequency: 12.0),
            Word(word: "passing", frequency: 9.0),
        ],
        onWordSelected: { _ in }
    )
    .frame(width: 600, height: 450)
}
