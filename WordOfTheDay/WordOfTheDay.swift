//
//  WordOfTheDay.swift
//  WordOfTheDay
//
//  Created by Piero Sierra on 22/09/2024.
//

import WidgetKit
import SwiftUI

// definies the Timeline for the Widget and how often to refresh
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), word: "Loading...", definition: "Loading...", isPlaceholder: true)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        fetchWordOfTheDay { word, _ in
            fetchDefinitionForWidget(query: word) { definition in
                let entry = SimpleEntry(date: Date(), word: word, definition: definition, isPlaceholder: word.isEmpty)
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        fetchWordOfTheDay { word, _ in
            fetchDefinitionForWidget(query: word) { definition in
                let entry = SimpleEntry(date: Date(), word: word, definition: definition, isPlaceholder: word.isEmpty)
                let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let word: String
    let definition: String
    let isPlaceholder: Bool
    
    var displayWord: String {
        isPlaceholder || word.isEmpty ? "Loading..." : word
    }
    
    var isValid: Bool {
        !isPlaceholder && !word.isEmpty
    }
}

struct WordOfTheDayEntry: TimelineEntry {
    let date: Date
    let word: String
    let definition: String
    let synonyms: [String]
}

// The main widget View
struct WordOfTheDayEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily  // Detect the widget family
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            // Logo in corner
            /*
            VStack {
                HStack {
                    Spacer()
                    Image("Logo_transparent_100")
                        .resizable()
                        .frame(maxWidth:25, maxHeight:25)
                }
                Spacer()
            }*/

            // Main Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("“")
                        .font(.custom("American Typewriter", size: widgetFamily == .systemMedium ? 30 : 25))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -5))
                    Text("\(entry.word)")
                        .padding(.bottom, 0)
                        .font(.custom("American Typewriter", size: widgetFamily == .systemMedium ? 18 : 16))
                        .lineLimit(1) // Restricts the text to 1 line
                        .truncationMode(.tail) // Truncates with ellipsis if it overflows
                }
                
                // Custom divider that respects container padding
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 1)
                
                Text("\(entry.definition)")
                    .font(.custom("American Typewriter", size: widgetFamily == .systemMedium ? 13 : 12))
                    .lineLimit(5) // Restricts the text to 4 lines
                    .truncationMode(.tail) // Truncates with ellipsis if it overflows
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(EdgeInsets(top: 0, leading: paddingForWidgetSize(), bottom: 0, trailing: paddingForWidgetSize()))
         }
        .containerBackground(for: .widget) {
            Color.clear
        }
        .widgetURL(entry.isValid ? createWidgetURL() : nil)
    }
    
    // Function to return different padding based on widget size
    func paddingForWidgetSize() -> CGFloat {
        switch widgetFamily {
        case .systemSmall:
            return 4
        case .systemMedium:
            return 6
        case .systemLarge:
            return 24
        default:
            return 12
        }
    }
    
    private func createWidgetURL() -> URL? {
        let urlString = "nerdbook://\(entry.word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")?showTrigger=true"
        print("🔴 Widget creating URL: \(urlString)")
        let url = URL(string: urlString)
        print("🔴 Widget URL created: \(url?.absoluteString ?? "nil")")
        return url
    }
    
}

// Base Widget Object
struct WordOfTheDay: Widget {
    let kind: String = "WordOfTheDay"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WordOfTheDayEntryView(entry: entry)
        }
        .configurationDisplayName("Word of the Day")
        .description("Displays the word of the day and its synonyms.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Previews the widget
#Preview(as: .systemSmall) {
    WordOfTheDay()
} timeline: {
    SimpleEntry(date: .now, word: "serendipity", definition: "A combination of events which have come together by chance to make a surprisingly good or wonderful outcome. ❡ A feeling of extreme happiness or cheerfulness, especially related to the acquisition or expectation of something good.", isPlaceholder: false)
    SimpleEntry(date: .now, word: "ephemeral", definition: "To get lucky", isPlaceholder: false)
    SimpleEntry(date: .now, word: "short", definition: "To get lucky",  isPlaceholder: false)
    SimpleEntry(date: .now, word: "joy", definition: "A feeling of extreme happiness or cheerfulness, especially related to the acquisition or expectation of something good.", isPlaceholder: false)
    SimpleEntry(date: .now, word: "Loading...", definition: "Loading...", isPlaceholder: true)
}

#Preview(as: .systemMedium) {
    WordOfTheDay()
} timeline: {
    SimpleEntry(date: .now, word: "serendipity", definition: "A combination of events which have come together by chance to make a surprisingly good or wonderful outcome. ❡ A feeling of extreme happiness or cheerfulness, especially related to the acquisition or expectation of something good.", isPlaceholder: false)
    SimpleEntry(date: .now, word: "ephemeral", definition: "To get lucky", isPlaceholder: false)
    SimpleEntry(date: .now, word: "joy", definition: "A feeling of extreme happiness or cheerfulness, especially related to the acquisition or expectation of something good.", isPlaceholder: false)
    SimpleEntry(date: .now, word: "short", definition: "The feeling of happiness", isPlaceholder: false)
    SimpleEntry(date: .now, word: "Loading...", definition: "Loading...", isPlaceholder: true)
}
