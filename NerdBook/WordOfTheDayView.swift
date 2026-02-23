import SwiftUI

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

#Preview("Word of the Day") {
    WordOfTheDayView(
        word: "serendipity",
        definition: "the faculty or phenomenon of finding valuable or agreeable things not sought for"
    )
    .frame(width: 680, height: 420)
}
