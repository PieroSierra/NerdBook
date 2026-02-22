# Research: Word of the Day in Desktop Empty State

**Branch**: `005-mac-wotd-empty-state` | **Date**: 2026-02-22

## R1: WOTD Data Fetching on macOS

**Decision**: Reuse existing `fetchWordOfTheDay()` and `fetchDefinitionForWidget()` free functions from `Shared/SharedData.swift`.

**Rationale**: These functions are already shared code (not iOS-gated), use FeedKit for RSS parsing and URLSession for DataMuse API calls. They work on macOS without modification.

**Alternatives considered**:
- New DataMuse endpoint: Unnecessary, the RSS + definition combo is proven in the widget.
- Embedding WOTD in the existing `DataMuse.fetchSynonyms()` flow: Would conflate search logic with WOTD; keeping them separate is cleaner.

## R2: Staleness / Caching Strategy

**Decision**: Store WOTD in-memory on the `DataMuse` ObservableObject with a `Date` timestamp. On launch, check if timestamp is >23 hours old (or nil). If stale, re-fetch. No disk persistence needed beyond the session.

**Rationale**: The user's requirement is "if I open the app every morning, the WOTD has changed." Since the app re-launches each morning, an in-memory cache with a 23-hour TTL satisfies this. The fetch is fast (<1s) and happens once per launch at most.

**Alternatives considered**:
- UserDefaults persistence: Would survive force-quit/relaunch within same day, but adds complexity for minimal gain. The RSS feed returns the same word all day anyway.
- Timer-based refresh: User explicitly said mid-session refresh isn't needed; launch-time check suffices.

## R3: Empty State Detection

**Decision**: The empty state is defined as: search text field is empty AND all four result arrays (`synonyms`, `lyricalSynonyms`, `pretentiousSynonyms`, `soundsLikeWords`) are empty. This is the condition for showing WOTD and hiding column headers.

**Rationale**: Matches the user's description: "where there is no word being searched for or results shown." When the user types and gets results, WOTD hides. When they clear/ESC, WOTD reappears.

**Alternatives considered**:
- Tracking a separate `hasSearched` boolean: Fragile, would need reset logic. Checking emptiness of arrays + text field is simpler and reactive.

## R4: Visual Style Matching

**Decision**: Replicate the widget's `WordOfTheDayEntryView` layout for the desktop, scaled up for the larger window. Use American Typewriter font at larger sizes (~40pt quote, ~28pt word, ~16pt definition). Center the content in the results area rather than left-aligning like the widget.

**Rationale**: The widget uses small/medium sizing (12-30pt) for constrained widget frames. The desktop window (~680x420) needs proportionally larger typography. Centering matches the "displayed in the center of the screen" requirement.

**Alternatives considered**:
- Exact pixel-match of widget: Would look tiny and lost in the larger window.
- Different font: User explicitly requested American Typewriter to match the widget.

## R5: Column Header Hiding

**Decision**: Wrap the existing 4-column `HStack` (containing `SynonymColumnView` instances) in a conditional that checks the empty state. When empty, show `WordOfTheDayView` instead. The column headers are part of each `SynonymColumnView`, so hiding the entire `HStack` hides them.

**Rationale**: Clean swap — one view or the other. No need to independently hide/show headers vs content since they're in the same container.

**Alternatives considered**:
- Overlay WOTD on top of hidden columns: More complex, same visual result.
- Separate header row from content: Would require refactoring `SynonymColumnView`, unnecessary.
