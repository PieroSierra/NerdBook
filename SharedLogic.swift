//
//  SharedLogic.swift
//  NerdBook
//
//  Created by Piero Sierra on 14/09/2024.
//

import Foundation
//import AppKit
import SwiftUI


// Structure for fetching suggestions
struct Suggestion: Codable {
    let word: String
}

// Model for decoding the API response
struct Word: Codable {
    let word: String
    let numSyllables: Int?
    let frequency: Double?
    let defs: [String]?  // Optional array of definitions
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

// HEX color code extension
extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

// DataMuse class - reads DataMuse API, fills up synonym structs, and powers autocomplete
class DataMuse: ObservableObject {
    @Published public var synonyms: [Word] = []
    @Published public var lyricalSynonyms: [Word] = []
    @Published public var pretentiousSynonyms: [Word] = []
    @Published public var suggestions: [String] = []
    @Published public var currentDefinition: String? = nil
    @Published public var debounceTimer: Timer?
    @Published public var isLoading: Bool = false
    @Published public var networkAvailable: Bool = true

    init(){
    }
    
    // Function to fetch synonyms from the Datamuse API
    func fetchSynonyms(query: String) {
        guard let synonymURL = URL(string: "https://api.datamuse.com/words?rel_syn=\(query)&md=s,f"),
              let definitionURL = URL(string: "https://api.datamuse.com/words?sp=\(query)&md=d") else {
            self.networkAvailable = false
            return
        }
        
        self.networkAvailable = true
        isLoading = true
        synonyms.removeAll()
        lyricalSynonyms.removeAll()
        pretentiousSynonyms.removeAll()
        suggestions.removeAll()
        
        // Fetch the definition of the query word itself
        let definitionTask = URLSession.shared.dataTask(with: definitionURL) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let decodedResponse = try? JSONDecoder().decode([Word].self, from: data), let firstWord = decodedResponse.first, let defs = firstWord.defs {
                    let definitionText = defs.first?.components(separatedBy: "\t").last
                    self.currentDefinition = definitionText ?? "No definition available"
                } else {
                    self.currentDefinition = "No definition available"
                }
            }
        }
        
        // Fetch the synonyms
        let synonymTask = URLSession.shared.dataTask(with: synonymURL) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let decodedResponse = try? JSONDecoder().decode([Word].self, from: data) {
                    self.synonyms = decodedResponse
                    self.lyricalSynonyms = decodedResponse.sorted {
                        ($0.numSyllables ?? 0, $0.frequency ?? 0) < ($1.numSyllables ?? 0, $1.frequency ?? 0)
                    }
                    self.pretentiousSynonyms = decodedResponse.sorted {
                        ($0.numSyllables ?? 0, $0.frequency ?? Double.greatestFiniteMagnitude) > ($1.numSyllables ?? 0, $1.frequency ?? Double.greatestFiniteMagnitude)
                    }
                    self.isLoading = false
                } else {
                    print("Error fetching synonyms: \(error?.localizedDescription ?? "Unknown error")")
                    self.isLoading = false
                    self.networkAvailable = false
                }
            }
        }
        
        // Start both tasks
        definitionTask.resume()
        synonymTask.resume()
    }
    
    // Function to fetch suggestions for Autocomplete
    func fetchSuggestions(for input: String) {
        debounceTimer?.invalidate()  // Cancel any existing timer
        // isUserSelecting = true
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            guard let url = URL(string: "https://api.datamuse.com/sug?s=\(input)") else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching suggestions: \(error?.localizedDescription ?? "Unknown error")")
                    self.networkAvailable = false
                    return
                }
                
                if let decodedSuggestions = try? JSONDecoder().decode([Suggestion].self, from: data) {
                    DispatchQueue.main.async {
                        self.suggestions = decodedSuggestions.map { $0.word }
                    }
                }
            }
            task.resume()
        }
    }
}
