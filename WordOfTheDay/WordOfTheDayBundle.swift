//
//  WordOfTheDayBundle.swift
//  WordOfTheDay
//
//  Created by Piero Sierra on 22/09/2024.
//

import WidgetKit
import SwiftUI

@main
struct WordOfTheDayBundle: WidgetBundle {
    var body: some Widget {
        WordOfTheDay()
        WordOfTheDayControl()
        WordOfTheDayLiveActivity()
    }
}
