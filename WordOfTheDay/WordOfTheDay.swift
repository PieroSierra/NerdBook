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
            VStack {
                HStack {
                    Spacer()
                    Image("Logo_transparent_100")
                        .resizable()
                        .frame(maxWidth:25, maxHeight:25)
                }
                Spacer()
            }

            // Main Content
            VStack(alignment: .leading) {
                HStack {
                    Text("“")
                        .font(.custom("American Typewriter", size: 30))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -5))
                    Text("\(entry.word)")
                        .padding(.bottom, 0)
                        .font(.custom("American Typewriter", size: 18))
                        .lineLimit(1) // Restricts the text to one line
                        .truncationMode(.tail) // Truncates with ellipsis if it overflows
                }
                .padding(EdgeInsets(top: -10, leading: 0, bottom: 0, trailing: 0))
                Divider()
                    .padding(EdgeInsets(top: -7, leading: 0, bottom: 0, trailing: 0))
                
                Text("\(entry.definition)")
                    .font(.subheadline)
                    .lineLimit(3) // Restricts the text to one line
                    .truncationMode(.tail) // Truncates with ellipsis if it overflows
 
/*                Text("\(entry.synonyms.joined(separator: ", "))")
                    .font(.subheadline)
                    .lineLimit(3) // Restricts the text to one line
                    .truncationMode(.tail) // Truncates with ellipsis if it overflows*/
            }
            .padding(paddingForWidgetSize())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            return 12
        case .systemLarge:
            return 24
        default:
            return 12
        }
    }
    
    private func createWidgetURL() -> URL? {
        let urlString = "nerdbook://\(entry.word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
        print("Widget URL: \(urlString)")
        return URL(string: urlString)
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
    SimpleEntry(date: .now, word: "serendipity", definition: "A combination of events which have come together by chance to make a surprisingly good or wonderful outcome.", isPlaceholder: false)
    SimpleEntry(date: .now, word: "ephemeral", definition: "To get lucky", isPlaceholder: false)
    SimpleEntry(date: .now, word: "short", definition: "To get lucky",  isPlaceholder: false)
    SimpleEntry(date: .now, word: "joy", definition: "A feeling of extreme happiness or cheerfulness, especially related to the acquisition or expectation of something good.", isPlaceholder: false)
    SimpleEntry(date: .now, word: "Loading...", definition: "Loading...", isPlaceholder: true)
}

#Preview(as: .systemMedium) {
    WordOfTheDay()
} timeline: {
    SimpleEntry(date: .now, word: "serendipity", definition: "A combination of events which have come together by chance to make a surprisingly good or wonderful outcome.", isPlaceholder: false)
    SimpleEntry(date: .now, word: "ephemeral", definition: "To get lucky", isPlaceholder: false)
    SimpleEntry(date: .now, word: "joy", definition: "A feeling of extreme happiness or cheerfulness, especially related to the acquisition or expectation of something good.", isPlaceholder: false)
    SimpleEntry(date: .now, word: "short", definition: "The feeling of happiness", isPlaceholder: false)
    SimpleEntry(date: .now, word: "Loading...", definition: "Loading...", isPlaceholder: true)
}
