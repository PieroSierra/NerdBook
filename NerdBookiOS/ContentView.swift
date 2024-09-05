//
//  ContentView.swift
//  NerdBookiOS
//
//  Created by Piero Sierra on 14/09/2024.
//

import SwiftUI

// Define a field to handle keyboard dismiss form multiple sources
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    @StateObject private var appState = AppState()
    @AppStorage("waveToggle") private var waveToggle: Bool = false
    @Binding var initialWord: String?
    @ObservedObject var dataMuse = DataMuse()
    @State private var query: String = ""
    @State private var isUserSelecting: Bool = false  // flag to track selection
    @Environment(\.colorScheme) var colorScheme // for DarkMode detection
    @State private var selectedSegment = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var currentQueryWord: Word?
    @State private var shouldRefreshRapView = false // New state variable
    @State private var phase = 0.0
    @State private var isAnimationComplete: Bool = false
    @State private var scale: CGFloat = 0.6  // Start with a smaller scale for pop-in effect
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass? //detects Orientation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass? // detects Orientation
    @State private var animationCompletionStatus: [String: Bool] = [:]
    
    
    init(initialWord: Binding<String?>) {
        _initialWord = initialWord
    }
    
    var body: some View {
        ZStack {
            //Color.background.edgesIgnoringSafeArea(.all) // Keep your original background color
            Color.clear // Use clear color to detect taps
                .contentShape(Rectangle()) // This makes the entire area tappable
                .edgesIgnoringSafeArea(.all) // Go edge to edge
                .onTapGesture {
                    isTextFieldFocused = false // Dismiss keyboard when tapping the background
                }
            
            VStack (spacing: 0) {
                if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                    Image("Logo_transparent_100")
                        .resizable()
                        .frame(width:90, height:90)
                        .foregroundStyle(.tint)
                }
                
                HStack {
                    NeumorphicStyleTextField(
                        textField: TextField("Find words", text: $query),
                        imageName: "magnifyingglass",
                        text: $query
                    )
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
                    .onSubmit {
                        dataMuse.debounceTimer?.invalidate()
                        dataMuse.fetchSynonyms(query: query)
                        isUserSelecting = true
                        dismissKeyboard()
                        dataMuse.suggestions.removeAll()
                    }
                }
                .padding()
                .padding(.trailing, (verticalSizeClass == .regular && horizontalSizeClass == .compact) ? 0 : 60)
                .padding(.bottom, (verticalSizeClass == .regular && horizontalSizeClass == .compact) ? 0 : -10)
                
                // Segmented Control
                ZStack {
                    Picker("Select Category", selection: $selectedSegment) {
                        Text("🙂 Normal").tag(0)
                        Text("😇 Poetic").tag(1)
                        Text("🤓 Nerdy").tag(2)
                        Text("🎤 Rap    \t").tag(3)
                            .bold()
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    
                    HStack {
                        Spacer()
                        waveStateButton.padding(.trailing, 5)
                    }
                }
                .padding(.top, -12)
                .padding(.bottom, -12)
                
                // Content changes based on the selected segment
                ZStack {
                    if selectedSegment == 0 {
                        synonymListView(synonyms: dataMuse.synonyms)
                    } else if selectedSegment == 1 {
                        synonymListView(synonyms: dataMuse.lyricalSynonyms)
                    } else if selectedSegment == 2 {
                        synonymListView(synonyms: dataMuse.pretentiousSynonyms)
                    } else {      // Rap view
                        ZStack {
                            // Wave animation
                            if (waveToggle && !isTextFieldFocused) {
                                Wave(strength: (verticalSizeClass == .regular && horizontalSizeClass == .compact) ? 100 : 40, frequency: 30, phase: self.phase)
                                    .stroke(colorScheme == .dark ? Color.pinkColor.opacity(0.3) :  Color.blueColor.opacity(0.3), lineWidth: 5)
                                    .offset(y: (verticalSizeClass == .regular && horizontalSizeClass == .compact) ? -60 : 0)
                                    .onAppear {
                                        resetAndStartWaveAnimation()
                                    }
                            }
                            // Sound-alike word pills
                            ScrollView {
                                let thresholds = calculateFrequencyThresholds(for: dataMuse.soundsLikeWords)
                                let words = shouldRefreshRapView ? dataMuse.soundsLikeWords.shuffled() : dataMuse.soundsLikeWords
                                FlowLayout(data: words, spacing: 10) { word in
                                    FrequencyURLButton(word: word.word, frequency: word.frequency ?? 0.0, thresholds: thresholds)
                                }
                                .padding()
                                .padding(.bottom, 200)
                            }
                            .transition(.opacity)
                            .background(Color.clear)
                            .onAppear {
                                shouldRefreshRapView = false // Reset the flag when the view appears
                            }
                        }
                    }
                    VStack {
                        Rectangle() // white fade rectangle
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [colorScheme == .dark ? Color.black.opacity(1.0) : Color.white.opacity(1.0), colorScheme == .dark ? Color.black.opacity(0.0) : Color.white.opacity(0.0)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 15) // Adjust height as needed
                        Spacer ()
                    }
                }
            } // end VSTACK
            // Show word definition overlay
            if !isTextFieldFocused {
                VStack () {
                    if let definition = dataMuse.currentDefinition {
                        Spacer()
                        HStack(alignment:.top) {
                            Spacer().frame(width:20)
                            
                            Text("'Def.' ").font(.headline)
                            
                            Text(definition)
                                .font(.body)
                                .italic()
                                .textSelection(.enabled)
                            
                            Spacer()
                            
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(Color.gray)
                                .imageScale(.large)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                        }
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                        .background(.ultraThinMaterial)
                        .foregroundStyle(.primary)
                        .onTapGesture {
                            dataMuse.fetchInspiration(query: query)
                            appState.showingTriggerSheet = true
                        }
                    }
                }
            }
            
            // AUTOSUGGEST MENU
            // Overlay to detect outside taps
            if !dataMuse.suggestions.isEmpty {
                Color.clear  // Transparent color below the autosuggest
                    .padding(-70)
                    .contentShape(Rectangle())  // Makes the area tappable
                    .onTapGesture {
                        isUserSelecting = true
                        dismissKeyboard()
                        dataMuse.suggestions.removeAll()  // Dismiss suggestions on outside click
                    }
                
                VStack {
                    Spacer().frame(height: 155)  // Position it below the TextField
                    List(dataMuse.suggestions, id: \.self) { suggestion in
                        Text(suggestion)
                            .onTapGesture {
                                isUserSelecting = true
                                query = suggestion
                                dataMuse.fetchSynonyms(query: query)
                                dataMuse.suggestions.removeAll()  // Hide suggestions after selection
                            }
                            .font(.custom("Open Sans", size: 18))
                            .padding(EdgeInsets(top: 0, leading:25, bottom: 0, trailing: -50))
                    }
                    .scrollContentBackground(.hidden) // Hides the default background
                    .background(Color.clear)           // Sets a custom background color
                    .foregroundColor(colorScheme == .dark ? Color.pinkColor : .blue)
                    // Dynamically adjust the height based on the number of suggestions, but limit it to a max height
                    .frame(maxHeight: min(CGFloat((dataMuse.suggestions.count) * 40)+40, 250))
                    .padding(EdgeInsets(top: -20, leading:-20, bottom: 0, trailing: -20))
                    .background(Color.clear)  // Ensure the list has a background color
                    .cornerRadius(8)  // Add some corner radius
                    .shadow(color: colorScheme == .dark ? Color.clear : Color.darkShadow, radius: 3, x: 2, y: 2) // Shadow for light mode
                    Spacer()
                }
                .transition(.opacity)  // Smooth transition when showing/hiding
                .padding()
                .transition(.opacity)  // Smooth transition when showing/hiding
                .padding()
            }
            
            // Show loader if needed
            if (dataMuse.isLoading == true) {
                VStack {
                    Spacer()
                    ProgressView().controlSize(.extraLarge)
                    Spacer().frame(height: 150)
                }
            }
            
            // Show network error if needed
            if (dataMuse.networkAvailable == false) {
                VStack {
                    Spacer()
                    HStack {
                        Spacer().frame(width:50, height:50)
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.gray)
                        Text ("No connection")
                        Spacer().frame(width:50)
                    }
                    .shadow(color: colorScheme == .dark ? Color.clear : Color.lightShadow, radius: 3, x: -2, y: -2) // Second shadow for light mode
                    .transition(.opacity)
                    Spacer().frame(height: 100)
                }
            }
        } // end ZSTACK
        .environmentObject(appState) // Pass the AppState instance to child views
        .sheet(isPresented: $appState.showingTriggerSheet) {
            TriggersSheetView(
                sheetTitle: query,
                queryWord: query,
                queryDefs: dataMuse.currentDefs,
                triggerWords: dataMuse.triggerWords,
                onTriggerSelected: { selectedWord in
                    query = selectedWord
                    dataMuse.fetchSynonyms(query: query)
                    appState.showingTriggerSheet = false
                }
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium, .large]).presentationBackground(.thickMaterial)
        }
        .sheet(isPresented: $appState.showingAboutSheet) {
            SheetView(
                sheetImage: Image(""),
                sheetImageResize: false,
                sheetTitle: "NerdBook iOS",
                sheetContent: """
                Finds synonyms for the selected word, sorted by normal, poetic (more lyrical woreds first), or nerdy (latin & greek words first).  Rap mode shows words that sound like the selected word.
                
                Powered by: [DataMuse](https://www.datamuse.com/)
                
                Word of The Day selection by: [Merriam-Webster](https://www.merriam-webster.com/)
                
                Piero Sierra, 2024.  For Mila ❤️ Papa
                """
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium, .large ]).presentationBackground(.ultraThinMaterial)
        }
        // Handle incoming URL with initialWord
        .onChange(of: initialWord) { newWord in
            if let word = newWord {
                print("ContentView received initialWord: \(word)")
                query = word
                isUserSelecting = true // dismiss autosuggest
                dismissKeyboard() // dismiss keyboard
                initialWord = nil  // Reset after use
                appState.showingTriggerSheet = false // close TriggerSheet if needed
                appState.showingAboutSheet = false // close AboutSheet if needed
                dataMuse.fetchSynonyms(query: word)
                shouldRefreshRapView = true // Set the flag when a new query word is selected
                resetAnimationStatus()
            }
        }
        // Update the flag when the selected segment changes
        .onChange(of: selectedSegment) { newSegment in
            resetAnimationStatus()
            if newSegment == 3 { // Rap segment
                shouldRefreshRapView = true
            }
        }
        .overlay(infoButton, alignment: .topTrailing)
    }
    
    private func synonymListView(synonyms: [Word]) -> some View {
        ScrollView {
            ForEach(synonyms, id: \.word) { synonym in
                let firstDefinition = synonym.defs?.first?.components(separatedBy: "\t").last ?? "No definition available"
                HStack {
                    ColorButton(
                        text: synonym.word,
                        fontSize: 16,
                        colorScheme: colorScheme,
                        action: {
                            isUserSelecting = true
                            dismissKeyboard()
                            query = synonym.word
                            dataMuse.fetchSynonyms(query: query)
                        },
                        onAnimationComplete: {
                            animationCompletionStatus[synonym.word] = true
                        }
                    )
                    if animationCompletionStatus[synonym.word] == true {
                        Text(" \(firstDefinition)")
                            .lineLimit(1)
                            .italic()
                            .foregroundColor(Color.gray)
                            .onTapGesture {
                                isUserSelecting = true
                                dismissKeyboard()
                                query = synonym.word
                                dataMuse.fetchSynonyms(query: query)
                            }
                    }
                    Spacer()
                }
                .padding(.top, 4).padding(.leading, 15)
            }
            .padding(.top, 15).padding(.bottom, 200)
        }
        .onAppear {
            resetAnimationStatus()
        }
    }
    
    private func dismissKeyboard() {
        isTextFieldFocused = false
    }
    
    private var infoButton: some View {
        Button(action: { appState.showingAboutSheet = true}) {
            Image(systemName: "info.circle")
                .foregroundColor(.gray)
                .imageScale(.large)
        }
        .padding()
    }
    
    private var waveStateButton: some View {
        Button(action: { waveToggle.toggle() }) {
            if waveToggle == true {
                Image(systemName: "waveform.circle.fill")
                    .foregroundColor(colorScheme == .dark ? Color.pinkColor : Color.blueColor)
                    .imageScale(.large)
            } else {
                Image(systemName: "waveform.circle")
                    .foregroundColor(.gray)
                    .imageScale(.large)
            }
        }
        .padding()
    }
    /*
     
     private var waveStateButton: some View {
     Button(action: { waveToggle.toggle() }) {
     ZStack {
     if waveToggle == true {
     Image(systemName: "waveform.circle.fill")
     .foregroundColor(.gray)
     .background(Color.white)
     .cornerRadius(20)
     .imageScale(.large)
     }
     else {
     Image(systemName: "line.diagonal")
     .foregroundColor(.gray)
     .cornerRadius(20)
     .imageScale(.large)
     }
     }
     .padding()
     }
     */
    
    private func resetAndStartWaveAnimation() {
        self.phase = 0 // Reset the phase
        startWaveAnimation()
    }
    
    private func startWaveAnimation() {
        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
            self.phase = .pi * 2
        }
    }
    
    private func resetAnimationStatus() {
        animationCompletionStatus = dataMuse.synonyms.reduce(into: [:]) { dict, synonym in
            dict[synonym.word] = false
        }
    }
}

struct customViewModifier: ViewModifier {
    var roundedCorners: CGFloat
    var startColor: Color
    var endColor: Color
    var textColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(roundedCorners)
            .padding(3)
            .foregroundColor(textColor)
            .overlay(RoundedRectangle(cornerRadius: roundedCorners)
                .stroke(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2.5))
            .font(.custom("Open Sans", size: 18))
            .shadow(radius: 10)
    }
}

struct NeumorphicStyleTextField: View {
    var textField: TextField<Text>
    var imageName: String
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme // for DarkMode detection
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(colorScheme == .dark ? Color.pinkColor : Color.blueColor)
            textField
                .font(.custom("Open Sans", size: 18))
                .foregroundColor(colorScheme == .dark ? Color.pinkColor : .blue)
            if !text.isEmpty {  // Check if the text is not empty
                Button(action: {
                    text = ""  // Clear the text
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .foregroundColor(.neumorphictextColor)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(LinearGradient(gradient: Gradient(colors: [colorScheme == .dark ? Color.pinkColor : Color.blueColor, colorScheme == .dark ? Color.blueColor : Color.pinkColor]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2.5))
        // Shadow Style option
        // .shadow(color: colorScheme == .dark ? Color.clear : Color.darkShadow, radius: 3, x: 2, y: 2) // Shadow for light mode
        // .shadow(color: colorScheme == .dark ? Color.clear : Color.lightShadow, radius: 3, x: -2, y: -2) // Second shadow for light mode
    }
}

#Preview("Normal Launch") {
    ContentView(initialWord: .constant(nil))
}
