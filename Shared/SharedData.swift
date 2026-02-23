//  SharedData.swift
//  NerdBook
//
//  Created by Piero Sierra on 07/10/2024.
//

import Foundation
import SwiftUI
import FeedKit

// Model for decoding the API response
struct Word: Codable, Identifiable, Hashable {
    var id: String { word }
    let word: String
    let numSyllables: Int?
    let frequency: Double?
    let defs: [String]?  // Optional array of definitions
    let tags: [String]?  // Added this property

    init(word: String, numSyllables: Int? = nil, frequency: Double? = nil, defs: [String]? = nil, tags: [String]? = nil) {
        self.word = word
        self.numSyllables = numSyllables
        self.frequency = frequency
        self.defs = defs
        self.tags = tags
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
    }

    static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.word == rhs.word
    }

    enum CodingKeys: String, CodingKey {
        case word
        case numSyllables
        case defs
        case tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        word = try container.decode(String.self, forKey: .word)
        numSyllables = try container.decodeIfPresent(Int.self, forKey: .numSyllables)
        defs = try container.decodeIfPresent([String].self, forKey: .defs)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)

        // Extract frequency from tags
        var freq: Double? = nil
        if let tags = tags {
            for tag in tags {
                if tag.starts(with: "f:") {
                    let freqString = String(tag.dropFirst(2)) // Remove "f:"
                    freq = Double(freqString)
                    break  // Assuming only one frequency tag
                }
            }
        }
        frequency = freq
    }

    // Implement the encode(to:) method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(word, forKey: .word)
        try container.encode(numSyllables, forKey: .numSyllables)
        try container.encode(defs, forKey: .defs)
        try container.encode(tags, forKey: .tags)
        // Note: You may omit frequency since it's derived from tags
    }
}

// Structure for fetching suggestions
struct Suggestion: Codable {
    let word: String
}

// Determine if a word is Latinate, or Greek
struct PrefixSuffixList {
    // Latin prefixes and suffixes
    static let latinPrefixes = ["ab", "ad", "ambi", "ante", "bi", "circum", "contra", "de", "dis", "ex", "extra", "in", "infra", "inter", "intro", "multi", "non", "omni", "per", "post", "pre", "pro", "re", "retro", "semi", "sub", "super", "trans", "ultra", "uni"]
    static let latinSuffixes = ["able", "ible", "ation", "ment", "ous", "ance", "ence", "ant", "ent", "ive", "ion", "ure", "ory"]
    
    // Greek prefixes and suffixes
    static let greekPrefixes = ["aero", "ana", "anti", "auto", "bio", "chrono", "geo", "hetero", "homo", "hydro", "hyper", "hypo", "mono", "neo", "pan", "peri", "photo", "poly", "pseudo", "syn", "thermo", "zoo"]
    static let greekSuffixes = ["phobia", "phile", "logy", "graphy", "metry", "nomy", "scope", "cracy", "itis", "osis", "ism", "ist"]
    
    // Function to check if a word is Latin
    static func isLatin(word: String) -> Bool {
        return latinPrefixes.contains { word.hasPrefix($0) } || latinSuffixes.contains { word.hasSuffix($0) }
    }
    
    // Function to check if a word is Greek
    static func isGreek(word: String) -> Bool {
        return greekPrefixes.contains { word.hasPrefix($0) } || greekSuffixes.contains { word.hasSuffix($0) }
    }
}

// DataMuse class - reads DataMuse API, fills up synonym structs, and powers autocomplete
class DataMuse: ObservableObject {
    @Published public var synonyms: [Word] = []
    @Published public var lyricalSynonyms: [Word] = []
    @Published public var pretentiousSynonyms: [Word] = []
    @Published public var triggerWords: [Word] = []
    @Published public var soundsLikeWords: [Word] = []
    @Published public var suggestions: [String] = [] // for Autocomplete
    @Published public var currentDefinition: String? = nil
    @Published public var currentDefs: [String] = []
    @Published public var isLoading: Bool = false
    @Published public var networkAvailable: Bool = true
    public var debounceTimer: Foundation.Timer?

    // Word of the Day state
    @Published public var wotdWord: String? = nil
    @Published public var wotdDefinition: String? = nil
    public var wotdFetchedAt: Date? = nil
    private var wotdRefreshTimer: Foundation.Timer?

    init() {
        startWotdRefreshTimer()
    }

    private func startWotdRefreshTimer() {
        wotdRefreshTimer = Foundation.Timer.scheduledTimer(withTimeInterval: 14400, repeats: true) { [weak self] _ in
            self?.fetchWordOfTheDayIfNeeded()
        }
    }
    
    // Function to fetch synonyms from the Datamuse API
    func fetchSynonyms(query: String) {
        guard let synonymURL = URL(string: "https://api.datamuse.com/words?rel_syn=\(query)&md=d,s,f"),
              let soundsLikeURL = URL(string: "https://api.datamuse.com/words?sl=\(query)&md=f"),
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
        triggerWords.removeAll()
        soundsLikeWords.removeAll()
        
        // Fetch the definition of the query word itself
        let definitionTask = URLSession.shared.dataTask(with: definitionURL) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let decodedResponse = try? JSONDecoder().decode([Word].self, from: data), let firstWord = decodedResponse.first, let defs = firstWord.defs {
                    // Store all definitions in self.defs
                    self.currentDefs = defs.map { $0.components(separatedBy: "\t").last ?? "" }
                    // Set the first definition as the current definition
                    self.currentDefinition = self.currentDefs.first ?? "No definition available"
                } else {
                    self.currentDefs = []
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
                        let isLatin1 = PrefixSuffixList.isLatin(word: $0.word)
                        let isLatin2 = PrefixSuffixList.isLatin(word: $1.word)
                        
                        // Prioritize Latin first
                        if isLatin1 != isLatin2 {
                            return isLatin1
                        }
                        
                        let isGreek1 = PrefixSuffixList.isGreek(word: $0.word)
                        let isGreek2 = PrefixSuffixList.isGreek(word: $1.word)
                        
                        // Then prioritize Greek
                        if isGreek1 != isGreek2 {
                            return isGreek1
                        }
                        
                        // Then sort by word frequency (rarer words first)
                        let freq1 = $0.frequency ?? Double.greatestFiniteMagnitude
                        let freq2 = $1.frequency ?? Double.greatestFiniteMagnitude
                        if (freq1 != freq2) {
                            return freq2 > freq1
                        }
                        
                        // Lastly, sort by number of syllables
                        let syllableCount1 = $0.numSyllables ?? 0
                        let syllableCount2 = $1.numSyllables ?? 0
                        if syllableCount1 != syllableCount2 {
                            return syllableCount1 > syllableCount2
                        }
                        
                        return false
                    }
                } else {
                    print("Error fetching synonyms: \(error?.localizedDescription ?? "Unknown error")")
                    self.networkAvailable = false
                }
            }
        }
        
        // Fetch the soundsLike words
        let soundsLikeTask = URLSession.shared.dataTask(with: soundsLikeURL) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let decodedResponse = try? JSONDecoder().decode([Word].self, from: data) {
                    self.soundsLikeWords = decodedResponse.filter { $0.word.lowercased() != query.lowercased() }
                } else {
                    self.soundsLikeWords = [Word(word: "No sound-alike words")]
///                    self.soundsLikeWords = [Word(word: "No sound-alike words", numSyllables: nil, frequency: nil, defs: nil, tags: nil)]
                    self.networkAvailable = false
                }
            }
        }
        
        // Start all tasks
        self.isLoading = false
        definitionTask.resume()
        synonymTask.resume()
        soundsLikeTask.resume()
    }
    
    // Separate call to fetch more inspiration for a given word on demand
    func fetchInspiration (query: String) {
        guard let triggersURL = URL(string: "https://api.datamuse.com/words?rel_trg=\(query)&md=f") else {  // Fixed the URL for triggers
            self.networkAvailable = false
            return
        }
        
        self.networkAvailable = true
        isLoading = true
        triggerWords.removeAll()
        
        // Fetch the trigger words
        let triggerTask = URLSession.shared.dataTask(with: triggersURL) { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let decodedResponse = try? JSONDecoder().decode([Word].self, from: data) {
                    self.triggerWords = decodedResponse
                } else {
                    self.triggerWords = [Word(word: "No related words")]
//                      self.triggerWords = [Word(word: "No related words", numSyllables: nil, frequency: nil, defs: nil)]
                    self.networkAvailable = false
                }
            }
        }
        self.isLoading = false
        triggerTask.resume()
    }
    
    // Fetch Word of the Day if stale (>23 hours) or never fetched
    func fetchWordOfTheDayIfNeeded() {
        if let fetchedAt = wotdFetchedAt,
           Date().timeIntervalSince(fetchedAt) < 23 * 3600 {
            return // Still fresh
        }

        fetchWordOfTheDay { [weak self] word, _ in
            guard let self = self, word != "Error" else { return }
            fetchDefinitionForWidget(query: word) { [weak self] definition in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.wotdWord = word
                    self.wotdDefinition = definition
                    self.wotdFetchedAt = Date()
                }
            }
        }
    }

    // Function to fetch suggestions for Autocomplete
    func fetchSuggestions(for input: String) {
        debounceTimer?.invalidate()  // Cancel any existing timer

        debounceTimer = Foundation.Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
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


// Word of the Day functions
func fetchWordOfTheDay(completion: @escaping (String, [String]) -> Void) {
    print("Starting fetchWordOfTheDay")
    guard let url = URL(string: "https://www.merriam-webster.com/wotd/feed/rss2") else {
        print("Invalid URL")
        completion("Error", ["Invalid URL"])
        return
    }
    
    let parser = FeedParser(URL: url)
    
    parser.parseAsync { result in
        switch result {
        case .success(let feed):
            guard let rssFeed = feed.rssFeed else {
                print("Feed is not RSS")
                completion("Error", ["Not RSS Feed"])
                return
            }
            
            if let firstItem = rssFeed.items?.first, let title = firstItem.title {
                let word = title.trimmingCharacters(in: .whitespacesAndNewlines)
                print("WOTD: \(word)")
                completion(word, [])  // We're not extracting synonyms from the feed
            } else {
                print("No items found in the feed")
                completion("Error", ["No Items"])
            }
            
        case .failure(let error):
            print("Failed to parse RSS feed: \(error)")
            completion("Error", ["Failed To Parse"])
        }
    }
}

func fetchSynonymsForWidget(query: String, completion: @escaping ([Word]) -> Void) {
    guard let synonymURL = URL(string: "https://api.datamuse.com/words?rel_syn=\(query)&md=s,f") else {
        return
    }
    
    let synonymTask = URLSession.shared.dataTask(with: synonymURL) { data, response, error in
        if let data = data, let decodedResponse = try? JSONDecoder().decode([Word].self, from: data) {
            completion(decodedResponse)
        } else {
            completion([])
        }
    }
    synonymTask.resume()
}

func fetchDefinitionForWidget(query: String, completion: @escaping (String) -> Void) {
    guard let widgetDefinitionURL = URL(string: "https://api.datamuse.com/words?sp=\(query)&md=d") else {
        completion("No definition available")
        return
    }
    
    let definitionTask = URLSession.shared.dataTask(with: widgetDefinitionURL) { data, response, error in
        DispatchQueue.main.async {
            if let data = data, let decodedResponse = try? JSONDecoder().decode([Word].self, from: data), let firstWord = decodedResponse.first, let defs = firstWord.defs {
                // Join all definitions with commas, removing the word type prefix
                let definitions = defs.map { $0.components(separatedBy: "\t").last ?? "" }
                let combinedDefinition = definitions.joined(separator: " ❡ ")
                completion(combinedDefinition)
            } else {
                completion("No definition available")
            }
        }
    }
    definitionTask.resume()
}

struct WordEntry {
    let word: String
    let synonyms: [String]
}

func parseRSSFeed(data: Data) -> WordEntry? {
    print("Starting to parse RSS feed")
    let parser = XMLParser(data: data)
    let feedParserDelegate = RSSParserDelegate()
    parser.delegate = feedParserDelegate
    
    if parser.parse() {
        print("RSS feed parsed successfully")
        return feedParserDelegate.wordEntry
    } else {
        print("Failed to parse RSS feed: \(parser.parserError?.localizedDescription ?? "Unknown error")")
        return nil
    }
}

func stripHTML(from string: String) -> String {
    return string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
}

func extractSynonyms(from description: String) -> [String] {
    // This is a placeholder implementation. You'll need to adjust this based on the actual format of the description.
    let cleanDescription = stripHTML(from: description)
    // For now, let's just split by commas as a simple example
    return cleanDescription.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
}

class RSSParserDelegate: NSObject, XMLParserDelegate {
    var currentElement = ""
    var currentWord = ""
    var isInItem = false
    var wordEntry: WordEntry?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            isInItem = true
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            isInItem = false
            if !currentWord.isEmpty {
                wordEntry = WordEntry(word: currentWord, synonyms: [])
                parser.abortParsing()
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isInItem && currentElement == "title" {
            currentWord += string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
