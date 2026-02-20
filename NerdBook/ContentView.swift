import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var dataMuse = DataMuse()
    @State private var query: String = ""
    @State private var showAbout: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isUserSelecting: Bool = false  // flag to track selection
    @Environment(\.colorScheme) var colorScheme // for DarkMode detection
    
    var body: some View {
        ZStack {
            Color.clear // Use clear color to detect taps
                .contentShape(Rectangle()) // This makes the entire area tappable
                .ignoresSafeArea()
                .frame(minWidth: 600, minHeight: 400)
                .onTapGesture {
                    isTextFieldFocused = false // Dismiss keyboard when tapping the background
                    isUserSelecting = true
                    dataMuse.suggestions.removeAll()  // Hide suggestions after selection
                }
            
            VStack {    // Main layer VStack
                HStack {
                    NeumorphicStyleTextField(text: $query, imageName: "magnifyingglass", placeholder: "NerdBook...") {
                        dataMuse.debounceTimer?.invalidate()  // Cancel the debounce timer when pressing "Enter"
                        dataMuse.fetchSynonyms(query: query)
                        isUserSelecting = true
                        dataMuse.suggestions.removeAll()  // Hide suggestions after selection
                    } onCancel: {
                        dataMuse.debounceTimer?.invalidate()  // Cancel the debounce timer when pressing "ESC"
                        isUserSelecting = true
                        dataMuse.suggestions.removeAll()  // Hide suggestions after cancellation
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
                .padding(EdgeInsets(top: 20, leading:40, bottom: 20, trailing: 40))
                
                
                HStack(alignment:.top){
                    // Column for regular synonyms
                    Spacer().frame(width:20)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Normal 🙂")
                            .font(.headline)
                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(dataMuse.synonyms, id: \.word) { synonym in
                                    Text(synonym.word)
                                        .font(.body)
                                        .foregroundColor(colorScheme == .dark ? Color.pinkColor : .blue)
                                        .lineLimit(1) // Limit to one line
                                        .truncationMode(.tail) // Use ellipsis at the end if the text is too long
                                        .fixedSize(horizontal: true, vertical: false)
                                        .onTapGesture {
                                            isUserSelecting = true
                                            query = synonym.word
                                            dataMuse.fetchSynonyms(query: query) // Immediately trigger search
                                        }
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .frame(maxWidth: 140, alignment: .leading)
                    .clipped()
                    
                    Spacer().frame(width: 50)
                    
                    // Column for most lyrical synonyms
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Lyrical 😇")
                            .font(.headline)
                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(dataMuse.lyricalSynonyms, id: \.word) { synonym in
                                    Text(synonym.word)
                                        .font(.body)
                                        .foregroundColor(colorScheme == .dark ? Color.pinkColor : .blue)
                                        .lineLimit(1) // Limit to one line
                                        .truncationMode(.tail) // Use ellipsis at the end if the text is too long
                                        .fixedSize(horizontal: true, vertical: false)
                                        .onTapGesture {
                                            isUserSelecting = true
                                            query = synonym.word
                                            dataMuse.fetchSynonyms(query: query) // Immediately trigger search
                                        }
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .frame(maxWidth: 140, alignment: .leading)
                    .clipped()
                    
                    Spacer().frame(width: 50)
                    
                    // Column for most pretentious synonyms
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pretentious 🤓")
                            .font(.headline)
                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(dataMuse.pretentiousSynonyms, id: \.word) { synonym in
                                    Text(synonym.word)
                                        .font(.body)
                                        .foregroundColor(colorScheme == .dark ? Color.pinkColor : .blue)
                                        .lineLimit(1) // Limit to one line
                                        .truncationMode(.tail) // Use ellipsis at the end if the text is too long
                                        .fixedSize(horizontal: true, vertical: false)
                                        .onTapGesture {
                                            isUserSelecting = true
                                            query = synonym.word
                                            dataMuse.fetchSynonyms(query: query) // Immediately trigger search
                                        }
                                }
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .frame(maxWidth: 140, alignment: .leading)
                    .clipped()
                    Spacer().frame(width: 20)
                }
                
                Spacer()
                
                // Add a Definition
                if let definition = dataMuse.currentDefinition {
                    Divider().padding(.top, -8)
                        .background(.white)
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
                    Text(LocalizedStringKey(myStringWithLink))
                    // .padding(EdgeInsets(top: 0, leading:20, bottom: 0, trailing: 20))
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
                    Spacer().frame(height: 10)
                }
            } // END OF LAYER 1 VSTACK
            
            // Autocomplete Suggestions List as an overlay
            if !dataMuse.suggestions.isEmpty {
                VStack {
                    Spacer().frame(height: 62)  // Position it below the TextField
                    List(dataMuse.suggestions, id: \.self) { suggestion in
                        Text(suggestion)
                            .foregroundColor(colorScheme == .dark ? Color.pinkColor : .blue)
                            .onTapGesture {
                                isUserSelecting = true
                                query = suggestion
                                dataMuse.fetchSynonyms(query: query)
                                dataMuse.suggestions.removeAll()  // Hide suggestions after selection
                            }
                    }
                    .onKeyPress(.escape) {            // <ESCAPE> key tracking
#if DEBUG
                        print ("ESC key pressed - Autocomplete window")
#endif
                        dataMuse.debounceTimer?.invalidate()  // Cancel the debounce timer when pressing "Enter"
                        isUserSelecting = true
                        dataMuse.suggestions.removeAll()  // Hide suggestions after selection
                        return .handled
                    }
                    .frame(width:500, height: 120)  // Limit the height of the suggestions list
                    .background(Color.white)  // Ensure the list has a background color
                    .cornerRadius(8)  // Add some corner radius
                    .shadow(radius: 10)  // Add shadow to the dropdown
                    //  .opacity(0.7)
                    //.background(TranslucentBackgroundView())
                    Spacer()
                } // end VSTACK
                .transition(.opacity)  // Smooth transition when showing/hiding
                .padding()
                
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
            // Show loader
            if (dataMuse.isLoading == true) {
                VStack {
                    Spacer()
                    ProgressView().controlSize(.extraLarge)
                    Spacer().frame(height: 150)
                }
            }
            
            // Show network error
            if (dataMuse.networkAvailable == false){
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
            
        } // END OF MAIN Z STACK VIEW
        .padding()
        .toolbar {
            Image("LogoSqFull")
        }
        .frame(minWidth: 600, minHeight: 400)  // Ensure the min size is respected in the view
        .background(WindowAccessor { window in
            // Set the initial size of the window when it is first created
            window.setContentSize(NSSize(width: 600, height: 400))
            window.minSize = NSSize(width: 600, height: 400)  // Set the minimum size
        })
        //.background(TranslucentBackgroundView())
    }
    
    //  private func dismissKeyboard() {
    //    isTextFieldFocused = false
    // }
} // END OF MAIN VIEW

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
            RoundedRectangle(cornerRadius: 12)
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

// Structure needed to enable Preview in XCODE
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

