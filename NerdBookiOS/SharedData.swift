class DataMuse: ObservableObject {
    static let shared = DataMuse()
    
    @Published var synonyms: [Word] = []
    @Published var lyricalSynonyms: [Word] = []
    @Published var pretentiousSynonyms: [Word] = []
    @Published var soundsLikeWords: [Word] = []
    @Published var suggestions: [String] = []
    @Published var currentDefinition: String?
    @Published var currentDefs: [String] = []
    @Published var triggerWords: [Word] = []
    @Published var isLoading: Bool = false
    @Published var networkAvailable: Bool = true
    
    private var debounceTimer: Timer?
    private let baseURL = "https://api.datamuse.com"
    
    private init() {} // Private initializer to enforce singleton pattern
    
    func fetchSynonyms(query: String) {
        isLoading = true
        networkAvailable = true
        
        // Clear previous data
        synonyms.removeAll()
        lyricalSynonyms.removeAll()
        pretentiousSynonyms.removeAll()
        soundsLikeWords.removeAll()
        currentDefinition = nil
        currentDefs.removeAll()
        triggerWords.removeAll()
        
        // Fetch synonyms
        fetchWords(from: "\(baseURL)/words?rel_syn=\(query)&max=1000") { [weak self] words in
            self?.synonyms = words
            self?.fetchLyricalSynonyms(query: query)
        }
    }
    
    private func fetchLyricalSynonyms(query: String) {
        fetchWords(from: "\(baseURL)/words?rel_syn=\(query)&topics=poetry&max=1000") { [weak self] words in
            self?.lyricalSynonyms = words
            self?.fetchPretentiousSynonyms(query: query)
        }
    }
    
    private func fetchPretentiousSynonyms(query: String) {
        fetchWords(from: "\(baseURL)/words?rel_syn=\(query)&topics=academic&max=1000") { [weak self] words in
            self?.pretentiousSynonyms = words
            self?.fetchSoundsLikeWords(query: query)
        }
    }
    
    private func fetchSoundsLikeWords(query: String) {
        fetchWords(from: "\(baseURL)/words?sl=\(query)&max=1000") { [weak self] words in
            self?.soundsLikeWords = words
            self?.fetchDefinitions(query: query)
        }
    }
    
    private func fetchDefinitions(query: String) {
        fetchWords(from: "\(baseURL)/words?sp=\(query)&md=d") { [weak self] words in
            if let word = words.first {
                self?.currentDefinition = word.defs?.first?.components(separatedBy: "\t").last
                self?.currentDefs = word.defs ?? []
                self?.fetchTriggerWords(query: query)
            } else {
                self?.isLoading = false
            }
        }
    }
    
    private func fetchTriggerWords(query: String) {
        fetchWords(from: "\(baseURL)/words?rel_trg=\(query)&max=1000") { [weak self] words in
            self?.triggerWords = words
            self?.isLoading = false
        }
    }
    
    func fetchSuggestions(for query: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.fetchWords(from: "\(baseURL)/sug?s=\(query)") { words in
                self?.suggestions = words.map { $0.word }
            }
        }
    }
    
    private func fetchWords(from urlString: String, completion: @escaping ([Word]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    self?.networkAvailable = false
                    self?.isLoading = false
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    self?.isLoading = false
                    return
                }
                
                do {
                    let words = try JSONDecoder().decode([Word].self, from: data)
                    completion(words)
                } catch {
                    print("Decoding error: \(error)")
                    self?.isLoading = false
                }
            }
        }.resume()
    }
}