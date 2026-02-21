# Data Model: Mac Multiple Definitions

## Existing Entities (no changes needed)

### Word
- `word: String` — the word text
- `numSyllables: Int?` — syllable count
- `frequency: Double?` — usage frequency
- `defs: [String]?` — raw definitions from API (format: `"partOfSpeech\tdefinition"`)
- `tags: [String]?` — metadata tags

### DataMuse (ObservableObject)
- `currentDefinition: String?` — first definition, displayed in the bar
- `currentDefs: [String]` — **all** parsed definitions (tab-prefix stripped), populated by `fetchSynonyms()`

## New State (ContentView only)

### showDefinitionsSheet: Bool
- New `@State` property on `ContentView`
- Toggled to `true` when user clicks the definition bar
- Controls `.sheet()` presentation
- Reset to `false` on sheet dismissal

## Data Flow

```
User clicks definition bar
  → showDefinitionsSheet = true
  → .sheet presents DefinitionsSheetView
  → DefinitionsSheetView receives dataMuse.currentDefs (read-only)
  → User scrolls through DefinitionCard instances
  → User dismisses → showDefinitionsSheet = false
```

No write-back, no mutations, no new API calls. Purely read-only presentation of existing data.
