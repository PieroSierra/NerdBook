# Data Model: Word of the Day in Desktop Empty State

**Branch**: `005-mac-wotd-empty-state` | **Date**: 2026-02-22

## Entities

### WordOfTheDay (New — in-memory on DataMuse)

| Field       | Type     | Description                                        |
|-------------|----------|----------------------------------------------------|
| word        | String?  | The daily featured word (nil before first fetch)    |
| definition  | String?  | Combined definition text (nil before first fetch)   |
| fetchedAt   | Date?    | Timestamp of last successful fetch (nil = never)    |

**Lifecycle**:
- Created: On first app launch when WOTD fetch completes
- Updated: On subsequent launches when `fetchedAt` is >23 hours ago
- Cleared: Never (persists in-memory for session duration)

**Staleness Rule**: `fetchedAt == nil || Date().timeIntervalSince(fetchedAt!) > 23 * 3600`

### Empty State (Derived — no stored data)

The empty state is a computed condition, not stored data:
- `isEmptyState = searchText.isEmpty && synonyms.isEmpty && lyricalSynonyms.isEmpty && pretentiousSynonyms.isEmpty && soundsLikeWords.isEmpty`

## Relationships

- `DataMuse` owns `WordOfTheDay` fields (added as `@Published` properties)
- `ContentView` observes `DataMuse` and derives `isEmptyState` to toggle between WOTD display and results columns
