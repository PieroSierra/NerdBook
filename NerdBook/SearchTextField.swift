import SwiftUI
import AppKit

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
