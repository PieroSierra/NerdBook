//
//  WordOfTheDayLiveActivity.swift
//  WordOfTheDay
//
//  Created by Piero Sierra on 22/09/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WordOfTheDayAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WordOfTheDayLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WordOfTheDayAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WordOfTheDayAttributes {
    fileprivate static var preview: WordOfTheDayAttributes {
        WordOfTheDayAttributes(name: "World")
    }
}

extension WordOfTheDayAttributes.ContentState {
    fileprivate static var smiley: WordOfTheDayAttributes.ContentState {
        WordOfTheDayAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WordOfTheDayAttributes.ContentState {
         WordOfTheDayAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WordOfTheDayAttributes.preview) {
   WordOfTheDayLiveActivity()
} contentStates: {
    WordOfTheDayAttributes.ContentState.smiley
    WordOfTheDayAttributes.ContentState.starEyes
}
