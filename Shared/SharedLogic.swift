//
//  SharedLogic.swift
//  NerdBook
//
//  Created by Piero Sierra on 14/09/2024.
//
// NOTE: When using SHARED LOGIC, check "Target Membership" and enable all relevant targets

import Foundation
import SwiftUI


// Define custom colors
extension Color {
    static let lightShadow = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    static let darkShadow = Color(red: 163 / 255, green: 177 / 255, blue: 198 / 255)
    static let background = Color(red: 224 / 255, green: 229 / 255, blue: 236 / 255)
    static let neumorphictextColor = Color(red: 132 / 255, green: 132 / 255, blue: 132 / 255)
    static let pinkColor: Color = Color(hex: 0xff46d6)
    static let blueColor: Color = Color(hex: 0x01b3f7)
}

// Structure needed to draw a triangle
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Start from the bottom left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Add line to the top middle
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        // Add line to the bottom right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Close the path to create the third side of the triangle
        path.closeSubpath()
        
        return path
    }
}

// Growing button style (grows when pressed)
struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            .background(Color.gray.opacity(0.2))
            .foregroundStyle(.blue)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .clipShape(Capsule())
    }
}

// HEX color code extension
extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

// Flow Layout (for Rap view)
struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var availableWidth: CGFloat = 0
    
    init(data: Data, spacing: CGFloat = 8, alignment: HorizontalAlignment = .center, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            
            _FlowLayout(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
    }
}

struct _FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var elementsSize: [Data.Element: CGSize] = [:]
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
                .frame(maxWidth: availableWidth, alignment: .center) // Center align each row
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow += 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth -= elementSize.width + spacing
        }
        
        return rows
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

func categorizeFrequency(_ frequency: Double, thresholds: (Double, Double)) -> Font.Weight {
    switch frequency {
    case ..<thresholds.0:
        return .regular // Small
    case thresholds.0..<thresholds.1:
        return .semibold // Medium
    default:
        return .bold // Large
    }
}

func calculateFrequencyThresholds(for words: [Word]) -> (Double, Double) {
    let frequencies = words.compactMap { $0.frequency }
    guard !frequencies.isEmpty else { return (0, 0) }
    
    let sortedFrequencies = frequencies.sorted()
    let lowerIndex = Int(Double(sortedFrequencies.count) * 0.33)
    let upperIndex = Int(Double(sortedFrequencies.count) * 0.66)
    
    return (sortedFrequencies[lowerIndex], sortedFrequencies[upperIndex])
}

class ColorButtonViewModel: ObservableObject {
    @Published var isAnimationComplete: Bool = false
}

struct ColorButton: View {
    let text: String
    let fontSize: CGFloat
    let colorScheme: ColorScheme
    let action: () -> Void
    let onAnimationComplete: () -> Void // Add this line

    @State private var isPressed: Bool = false
    @State private var scale: CGFloat = 0.6  // Start with a smaller scale for pop-in effect

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: fontSize))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LinearGradient(gradient: Gradient(colors: [colorScheme == .dark ? Color.pinkColor : Color.blueColor, colorScheme == .dark ? Color.blueColor : Color.pinkColor]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
                .scaleEffect(isPressed ? 1.1 : scale)
                .animation(.easeOut(duration: 0.2), value: isPressed)
                .onAppear {
                    let randomDelay = Double.random(in: 0...0.35) // Random delay between 0 and 0.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            scale = 1.15
                        }
                        withAnimation(.easeOut(duration: 0.1).delay(0.2)) {
                            scale = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Adjust delay as needed
                            onAnimationComplete() // Notify when animation is complete
                        }
                    }
                }
        }
        .foregroundColor(colorScheme == .dark ? Color.pinkColor : Color.blue)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            withAnimation(.easeOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct FrequencyURLButton: View {
    let word: String
    let frequency: Double
    let thresholds: (Double, Double)
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    private var fontSize: CGFloat {
        switch categorizeFrequency(frequency, thresholds: thresholds) {
        case .regular:
            return 14 // Small
        case .semibold:
            return 18 // Medium
        case .bold:
            return 23 // Large
        default:
            return 14
        }
    }
    
    var body: some View {
        ColorButton(
            text: word,
            fontSize: fontSize,
            colorScheme: colorScheme,
            action: { // Correctly label the action parameter
                if let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                   let url = URL(string: "nerdbook://\(encodedWord)") {
                    openURL(url)
                }
            },
            onAnimationComplete: {}
        )
    }
}

// Create "word - definition" pairs
func buildWordAndDefinition(wordString: String, defString: String, colorScheme: ColorScheme) -> AttributedString {
//    @Environment(\.colorScheme) var colorScheme // for DarkMode detection
    var attributedString = AttributedString("")
    var wordAttrString = AttributedString(wordString)
    //  Turn into URL if needed (but in this case, skip)
    //  let encodedWord = wordString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? wordString
    //  wordAttrString.link = URL(string: "nerdbook://\(encodedWord)")!
    wordAttrString.foregroundColor = colorScheme == .dark ? Color.pinkColor : .blue
    
    // Append the word to the main attributed string
    attributedString.append(wordAttrString)
    
    // Create and append the gray text
    var grayText = AttributedString(" - \(defString)")
    grayText.foregroundColor = .gray
    attributedString.append(grayText)
    
    return attributedString
}