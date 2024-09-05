//
//  TriggerWordsView.swift
//  NerdBook
//
//  Created by Piero Sierra on 02/10/2024.
//

import Foundation
import SwiftUI

struct TriggersSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    var sheetTitle: String
    var queryWord: String
    var queryDefs: [String]
    var triggerWords: [Word]
    var onTriggerSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(sheetTitle)")
                .font(.largeTitle)
                .bold()
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
            
            ScrollView {
                if (!queryDefs.isEmpty) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 20) {
                            ForEach(queryDefs, id: \.self) { def in
                                DefinitionCard(definition: def)
                            }
                        }
                        .padding()
                    }
                }
                else { Text("No definitions available.") }
                
                if triggerWords.first != nil {
                    Text("Words associated with \(queryWord):").padding()
                    
                    let thresholds = calculateFrequencyThresholds(for: triggerWords)
                    FlowLayout(data: triggerWords.shuffled(), spacing: 10) { word in
                        FrequencyURLButton(word: word.word, frequency: word.frequency ?? 0.0, thresholds: thresholds)
                    }
                    .padding()
                }
                else { Text("No words acciated with \(queryWord)") }
                
                Button("Dismiss") {
                    dismiss()
                }
                .buttonStyle(GrowingButton())
                .padding()
            }
            .transition(.opacity)
            .background(Color.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(dismissButton, alignment: .topTrailing)
    }
    
    private var dismissButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .imageScale(.large)
        }
        .padding()
    }
}

struct DefinitionCard: View {
    @Environment(\.colorScheme) var colorScheme
    let definition: String
    @State private var scale = 0.2
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(definition.components(separatedBy: "\t").last ?? "")
                .padding()
                .frame(width: 300, height: 150)
        }
        .onAppear() {
            scale = 1.0
        }
        .scaleEffect(scale)
        .animation(.bouncy(duration: 0.5), value: scale)
        .presentationBackground(.thickMaterial)
        .background(Color(UIColor.systemBackground))
//        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(15)
        .font(.custom("American Typewriter", size: 16))
        .textSelection(.enabled)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        
        
        
        // .shadow(color: colorScheme == .dark ? Color.clear : Color.darkShadow, radius: 3, x: 2, y: 2) // Shadow for light mode
        // .shadow(color: colorScheme == .dark ? Color.clear : Color.lightShadow, radius: 3, x: -2, y: -2) // Second shadow for light mode
    }
}

// Preview with dummy data
#Preview {
    TriggersSheetView(
        sheetTitle: "ocean",
        queryWord: "ocean",
        queryDefs: ["A wheeled vehicle that moves independently, with at least three wheels, powered mechanically, steered by a driver and mostly for personal transportation.", "Def 2"],
        triggerWords: [
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.01, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 2, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 2, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 2, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 2, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil)
        ],
        
        onTriggerSelected: { selectedWord in
            print("Selected trigger word: \(selectedWord)")
        }
    )
}

#Preview {
    TriggersSheetView(
        sheetTitle: "ocean",
        queryWord: "ocean",
        queryDefs: ["A wheeled vehicle that moves independently, with at least three wheels, powered mechanically, steered by a driver and mostly for personal transportation.", "Def 2"],
        triggerWords: [
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.01, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 2, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 2, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 2, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 2, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "meridian", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "tide", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "acidification", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "current", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "waves", numSyllables: 1, frequency: 0.8, defs: nil),
            Word(word: "surf", numSyllables: 5, frequency: 0.5, defs: nil),
            Word(word: "seagull", numSyllables: 3, frequency: 0.3, defs: nil),
            Word(word: "shell", numSyllables: 1, frequency: 0.8, defs: nil)
        ],
        
        onTriggerSelected: { selectedWord in
            print("Selected trigger word: \(selectedWord)")
        }
    )
}








