import SwiftUI
import AppKit

// MARK: - AutocompleteSuggestionsView

struct AutocompleteSuggestionsView: View {
    let suggestions: [String]
    let colorScheme: ColorScheme
    @Binding var selectedIndex: Int
    let onSelect: (String) -> Void
    let onDismiss: () -> Void

    private let rowHeight: CGFloat = 30
    private let maxRows: Int = 5

    private var listHeight: CGFloat {
        let count = min(suggestions.count, maxRows)
        return CGFloat(count) * rowHeight + 8
    }

    var body: some View {
        VStack {
            Spacer().frame(height: 62)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions.indices, id: \.self) { index in
                            Text(suggestions[index])
                                .foregroundColor(colorScheme == .dark ? Color.pinkColor : .blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: rowHeight)
                                .padding(.horizontal, 16)
                                .background(
                                    Group {
                                        if index == selectedIndex {
                                            RoundedRectangle(cornerRadius: 7)
                                                .fill(colorScheme == .light
                                                      ? Color.pinkColor.opacity(0.2)
                                                      : Color.blueColor.opacity(0.15))
                                                .padding(.horizontal, 5)
                                        }
                                    }
                                )
                                .id(index)
                                .onTapGesture { onSelect(suggestions[index]) }
                                .onHover { hovering in
                                    if hovering { NSCursor.pointingHand.push() }
                                    else { NSCursor.pop() }
                                }
                        }
                    }
                }
                .onChange(of: selectedIndex) { oldValue, newValue in
                    guard newValue >= 0 else { return }
                    let anchor: UnitPoint = newValue > oldValue ? .bottom : .top
                    withAnimation(.easeInOut(duration: 0.1)) {
                        proxy.scrollTo(newValue, anchor: anchor)
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 5)
            }
            .frame(width: 400, height: listHeight)
            .nerdBookGlassEffect(cornerRadius: 10)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity)
        .padding()
        .padding(.leading, 40)
    }
}
