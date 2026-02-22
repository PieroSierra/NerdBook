# Quickstart: Word of the Day in Desktop Empty State

**Branch**: `005-mac-wotd-empty-state` | **Date**: 2026-02-22

## Overview

Add Word of the Day display to the macOS NerdBook app's empty state. When no search is active, the results area shows the daily word in American Typewriter font with quotation marks and definition, matching the iOS widget style. Column headers are hidden in this state.

## Files to Modify

1. **`Shared/SharedData.swift`** — Add `@Published` WOTD properties (`wotdWord`, `wotdDefinition`, `wotdFetchedAt`) to `DataMuse` class. Add `fetchWordOfTheDayIfNeeded()` method that checks staleness and calls existing `fetchWordOfTheDay()` + `fetchDefinitionForWidget()`.

2. **`NerdBook/ContentView.swift`** — Add `WordOfTheDayView` (new SwiftUI view). Modify main `VStack` to conditionally show WOTD view vs column `HStack` based on empty state. Call `fetchWordOfTheDayIfNeeded()` on `.onAppear`.

## Files NOT Modified

- `WordOfTheDay/WordOfTheDay.swift` — Widget code stays untouched; we reuse its fetch functions, not its views.
- `NerdBookiOS/` — No iOS changes.

## Key Decisions

- WOTD state lives on `DataMuse` (existing ObservableObject) — no new classes.
- In-memory cache with 23-hour TTL — no UserDefaults or disk persistence.
- Conditional view swap (WOTD vs columns) — cleanest approach, hides headers automatically.
- Font sizes scaled up from widget (40pt quote, 28pt word, 16pt definition) for desktop window.
