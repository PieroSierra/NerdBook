//
//  ContentView.swift
//  NerdBookiOS
//
//  Created by Piero Sierra on 14/09/2024.
//

import SwiftUI

// Define custom colors
extension Color {
    static let lightShadow = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    static let darkShadow = Color(red: 163 / 255, green: 177 / 255, blue: 198 / 255)
    static let background = Color(red: 224 / 255, green: 229 / 255, blue: 236 / 255)
    static let neumorphictextColor = Color(red: 132 / 255, green: 132 / 255, blue: 132 / 255)
}

// Define a field to handle keyboard dismiss form multiple sources
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct ContentView: View {
    @ObservedObject var dataMuse = DataMuse()
    @State private var query: String = ""
    @State private var isUserSelecting: Bool = false  // flag to track selection
    @Environment(\.colorScheme) var colorScheme // for DarkMode detection
    @State private var selectedSegment = 0
    @State private var showAbout: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            //Color.background.edgesIgnoringSafeArea(.all) // Keep your original background color
            Color.clear // Use clear color to detect taps
                .contentShape(Rectangle()) // This makes the entire area tappable
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isTextFieldFocused = false // Dismiss keyboard when tapping the background
                }
            
            VStack {
                Image("Logo_transparent_100")
                    .resizable()
                    .frame(width:100, height:100)
                    .foregroundStyle(.tint)
                
                HStack {
                    NeumorphicStyleTextField(textField: TextField("NerdBook...", text: $query), imageName: "magnifyingglass")
                        .focused($isTextFieldFocused)
                        .onChange(of: query) { newValue, _ in  // Ignore the transaction if not needed
                            if isUserSelecting {
                                isUserSelecting = false  // Reset the flag after selection
                            } else if !newValue.isEmpty {
                                dataMuse.fetchSuggestions(for: newValue)  // Only fetch suggestions if not selecting
                            } else {
                                dataMuse.suggestions.removeAll()
                            }
                        }
                        .onSubmit {
                            dataMuse.debounceTimer?.invalidate()  // Cancel the debounce timer when pressing "Enter"
                            dataMuse.fetchSynonyms(query: query)
                            isUserSelecting = true
                            dismissKeyboard()
                            dataMuse.suggestions.removeAll()  // Hide suggestions after selection
                        }
                }.padding()
                
                // Segmented Control
                Picker("Select Category", selection: $selectedSegment) {
                    Text("Normal 🙂").tag(0)
                    Text("Lyrical 😇").tag(1)
                    Text("Pretentious 🤓").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 15, leading:15, bottom: -5, trailing: 15))
                
                // Content changes based on the selected segment
                if selectedSegment == 0 {
                    List(dataMuse.synonyms, id: \.word) { synonym in
                        Text(synonym.word)
                            .onTapGesture {
                                isUserSelecting = true
                                dismissKeyboard()
                                query = synonym.word
                                dataMuse.fetchSynonyms(query: query) // Immediately trigger search
                            }
                    }
                    .transition(.opacity)  // Smooth transition when showing/hiding
                    .scrollContentBackground(.hidden) // Hides the default background
                    .background(Color.clear)           // Sets a custom background color
                    .foregroundColor(colorScheme == .dark ? Color(hex: 0xff46d6) : .blue)
                } else if selectedSegment == 1 {
                    List(dataMuse.lyricalSynonyms, id: \.word) { synonym in
                        Text(synonym.word)
                            .onTapGesture {
                                isUserSelecting = true
                                dismissKeyboard()
                                query = synonym.word
                                dataMuse.fetchSynonyms(query: query) // Immediately trigger search
                            }
                    }
                    .transition(.opacity)  // Smooth transition when showing/hiding
                    .scrollContentBackground(.hidden) // Hides the default background
                    .background(Color.clear)           // Sets a custom background color
                    .foregroundColor(colorScheme == .dark ? Color(hex: 0xff46d6) : .blue)
                } else {
                    List(dataMuse.pretentiousSynonyms, id: \.word) { synonym in
                        Text(synonym.word)
                            .onTapGesture {
                                isUserSelecting = true
                                dismissKeyboard()
                                query = synonym.word
                                dataMuse.fetchSynonyms(query: query) // Immediately trigger search
                            }
                    }
                    .transition(.opacity)  // Smooth transition when showing/hiding
                    .scrollContentBackground(.hidden) // Hides the default background
                    .background(Color.clear)           // Sets a custom background color
                    .foregroundColor(colorScheme == .dark ? Color(hex: 0xff46d6) : .blue)
                }
                
                if !isTextFieldFocused {
                    if let definition = dataMuse.currentDefinition {
                        Divider()
                            .padding(.top, -8)
                        // .background(.red)
                        HStack(alignment:.top) {
                            Spacer().frame(width:20)
                            Text("Def. ")
                                .font(.headline)
                            Text(definition)
                                .font(.body)
                                .italic()
                                .textSelection(.enabled)
                            Spacer()
                        }
                    }
                    
                    VStack {
                        let myStringWithLink = "Powered by https://www.datamuse.com/"
                        Divider()
                        //        .background(.white)
                        Text(LocalizedStringKey(myStringWithLink))
                            .padding(EdgeInsets(top: 10, leading:0, bottom: 0, trailing: 0))
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .onTapGesture {
                                showAbout.toggle()
                            }
                        if (showAbout == true) {
                            Text("For Mila ❤️ Papa, 2024")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .onTapGesture {
                                    showAbout.toggle()
                                }
                        }
                    }
                }
            } // end VSTACK
            
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
                    .foregroundColor(colorScheme == .dark ? Color(hex: 0xff46d6) : .blue)
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
            
            // Show loader
            
            if (dataMuse.isLoading == true) {
                VStack {
                    Spacer()
                    ProgressView().controlSize(.extraLarge)
                    Spacer().frame(height: 150)
                }
            }
            // Show network error
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
    }
    
    private func dismissKeyboard() {
        isTextFieldFocused = false
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
    @Environment(\.colorScheme) var colorScheme // for DarkMode detection
    var body: some View {
        HStack {
            Image(systemName: imageName)
            //        .foregroundColor(.darkShadow)
                .foregroundColor(colorScheme == .dark ? Color(hex: 0xff46d6) : Color(hex: 0x01b3f7))
            textField
                .font(.custom("Open Sans", size: 18))
                .foregroundColor(colorScheme == .dark ? Color(hex: 0xff46d6) : .blue)
        }
        .padding()
        .foregroundColor(.neumorphictextColor)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(LinearGradient(gradient: Gradient(colors: [colorScheme == .dark ? Color(hex: 0xff46d6) : Color(hex: 0x01b3f7), colorScheme == .dark ? Color(hex: 0x01b3f7) : Color(hex: 0xff46d6)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2.5))
        // Shadow Style option
        // .shadow(color: colorScheme == .dark ? Color.clear : Color.darkShadow, radius: 3, x: 2, y: 2) // Shadow for light mode
        // .shadow(color: colorScheme == .dark ? Color.clear : Color.lightShadow, radius: 3, x: -2, y: -2) // Second shadow for light mode
    }
}

#Preview {
    ContentView()
}

