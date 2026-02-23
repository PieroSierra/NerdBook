import SwiftUI
import AppKit

// MARK: - DefinitionBarView

struct DefinitionBarView: View {
    let definition: String
    let onTap: () -> Void

    @State private var opacity: Double = 0

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                HStack(alignment: .center) {
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
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.35)) { opacity = 1 }
            }
            .onChange(of: definition) {
                opacity = 0
                withAnimation(.easeIn(duration: 0.35)) { opacity = 1 }
            }
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
