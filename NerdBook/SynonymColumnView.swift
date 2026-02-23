import SwiftUI

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
