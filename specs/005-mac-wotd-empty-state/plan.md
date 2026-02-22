# Implementation Plan: Word of the Day in Desktop Empty State

**Branch**: `005-mac-wotd-empty-state` | **Date**: 2026-02-22 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-mac-wotd-empty-state/spec.md`

## Summary

Add a Word of the Day display to the macOS NerdBook app's empty state. When no search query is active and no results are shown, the results area displays the daily word from Merriam-Webster's RSS feed, styled with American Typewriter font, an opening curly quotation mark, a divider, and the definition — matching the existing iOS widget. Column headers are hidden in this state. The WOTD is fetched once per launch and refreshed when stale (>23 hours).

## Technical Context

**Language/Version**: Swift 5.9+, SwiftUI 4.0+
**Primary Dependencies**: FeedKit (SPM, already in project), SwiftUI (built-in), AppKit (built-in, macOS)
**Storage**: In-memory `@Published` properties on existing `DataMuse` ObservableObject
**Testing**: XCTest (existing but minimal test infrastructure)
**Target Platform**: macOS 14.6+ (Sonoma)
**Project Type**: Mobile/Desktop (Xcode project with shared code)
**Performance Goals**: WOTD visible within 2 seconds of launch
**Constraints**: Single network fetch per launch; graceful degradation when offline
**Scale/Scope**: 2 files modified (`SharedData.swift`, `ContentView.swift`)

## Constitution Check

*No constitution file exists. Proceeding with standard project conventions.*

## Project Structure

### Documentation (this feature)

```text
specs/005-mac-wotd-empty-state/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Research decisions
├── data-model.md        # Data model
├── quickstart.md        # Implementation quickstart
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # (Phase 2 - /speckit.tasks)
```

### Source Code (files to modify)

```text
Shared/
└── SharedData.swift          # Add WOTD properties + fetch method to DataMuse class

NerdBook/
└── ContentView.swift         # Add WordOfTheDayView, conditional empty state logic
```

**Structure Decision**: No new files created. All changes are additions to existing files, following the project's established pattern of keeping shared logic in `SharedData.swift` and macOS UI in `NerdBook/ContentView.swift`.

## Implementation Steps

### Step 1: Add WOTD State to DataMuse (`Shared/SharedData.swift`)

Add three `@Published` properties to the `DataMuse` class:
- `wotdWord: String?` — the daily word
- `wotdDefinition: String?` — the combined definition
- `wotdFetchedAt: Date?` — timestamp for staleness check

Add a `fetchWordOfTheDayIfNeeded()` method:
1. Check if `wotdFetchedAt` is nil or >23 hours old
2. If stale, call existing `fetchWordOfTheDay()` to get the word from RSS
3. Then call existing `fetchDefinitionForWidget()` to get the definition
4. Update the three `@Published` properties on the main thread
5. If fetch fails and cached data exists, keep the cache (graceful degradation)

**Key detail**: The existing free functions `fetchWordOfTheDay()` and `fetchDefinitionForWidget()` use completion handlers. The new method wraps them in the staleness check.

### Step 2: Add WordOfTheDayView (`NerdBook/ContentView.swift`)

Create a new `WordOfTheDayView` struct inside ContentView.swift:
- Takes `word: String` and `definition: String` as parameters
- Layout: centered `VStack` with:
  - Opening curly quote `"` in American Typewriter ~40pt, gray color
  - Word text in American Typewriter ~28pt, bold weight
  - Gray `Rectangle` divider (height: 1, opacity: 0.4)
  - Definition text in American Typewriter ~16pt, secondary color, multi-line
- All centered horizontally and vertically in available space
- Max width ~500pt to keep text readable and not span the full window

### Step 3: Modify ContentView Layout (`NerdBook/ContentView.swift`)

In the main `VStack` of `ContentView.body`:
1. Compute `isEmptyState`: search text is empty AND all four result arrays are empty
2. Replace the current unconditional column `HStack` with a conditional:
   - If `isEmptyState` AND `wotdWord` is available: show `WordOfTheDayView`
   - Else if `isEmptyState` AND `wotdWord` is nil: show `Spacer()` (loading/no data)
   - Else: show the existing column `HStack` (search results)
3. Column headers are inside `SynonymColumnView`, so hiding the `HStack` automatically hides them (FR-005, FR-006)

### Step 4: Trigger WOTD Fetch on Launch (`NerdBook/ContentView.swift`)

Add `.onAppear { dataMuse.fetchWordOfTheDayIfNeeded() }` to the `ContentView` body or the outer `ZStack`. This fires once when the window first appears, fetching the WOTD if needed.

### Step 5: Handle Transition Back to WOTD

When the user presses ESC or clears the search field, the existing logic already clears the result arrays and search text. This naturally sets `isEmptyState = true`, which shows the WOTD again. No additional logic needed — the reactive SwiftUI binding handles it.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| RSS feed temporarily down | Low | Low | Fall back to nil state (no WOTD shown, clean empty area) |
| American Typewriter font missing | Very Low | Medium | macOS bundles it since 10.x; no action needed |
| WOTD fetch delays app feel | Low | Low | Fetch is async; UI shows empty then WOTD appears |
| Layout shift when WOTD appears | Low | Low | Use animation/transition for smooth appearance |
