# Tasks: Word of the Day in Desktop Empty State

**Input**: Design documents from `/specs/005-mac-wotd-empty-state/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Not requested in feature specification. No test tasks included.

**Organization**: Tasks grouped by user story. US1 and US2 (both P1) are combined — the conditional view swap that shows WOTD inherently hides column headers.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Foundational (WOTD Data Layer)

**Purpose**: Add Word of the Day state and fetch logic to the shared data layer. Blocks all UI work.

- [x] T001 Add `@Published` WOTD properties (`wotdWord: String?`, `wotdDefinition: String?`, `wotdFetchedAt: Date?`) to the `DataMuse` class in `Shared/SharedData.swift`
- [x] T002 Add `fetchWordOfTheDayIfNeeded()` method to `DataMuse` in `Shared/SharedData.swift` — checks if `wotdFetchedAt` is nil or >23 hours stale, then calls existing `fetchWordOfTheDay()` + `fetchDefinitionForWidget()` free functions, updates `@Published` properties on main thread

**Checkpoint**: DataMuse now exposes WOTD data reactively. No UI changes yet.

---

## Phase 2: User Stories 1 & 2 — WOTD Display + Hidden Headers (Priority: P1) 🎯 MVP

**Goal**: When no search is active, show the Word of the Day centered in the results area with American Typewriter styling. Column headers are hidden automatically because the column HStack is swapped out.

**Independent Test**: Launch app without searching — WOTD should appear centered. Type a search — columns and headers should appear. Clear search / press ESC — WOTD should reappear.

### Implementation

- [x] T003 [US1] Create `WordOfTheDayView` struct in `NerdBook/ContentView.swift` — centered `VStack` with: opening curly quote `"` in American Typewriter ~40pt (gray), word in American Typewriter ~28pt (bold), gray `Rectangle` divider (height: 1, opacity: 0.4), definition in American Typewriter ~16pt (secondary color, multi-line), max width ~500pt
- [x] T004 [US1] [US2] Add `isEmptyState` computed condition in `ContentView` body in `NerdBook/ContentView.swift` — true when search text is empty AND all four result arrays (`synonyms`, `lyricalSynonyms`, `pretentiousSynonyms`, `soundsLikeWords`) are empty
- [x] T005 [US1] [US2] Replace the unconditional 4-column `HStack` in `ContentView.body` in `NerdBook/ContentView.swift` with a conditional: if `isEmptyState` and `wotdWord != nil`, show `WordOfTheDayView`; otherwise show the existing column `HStack`
- [x] T006 [US1] Add `.onAppear { dataMuse.fetchWordOfTheDayIfNeeded() }` to the outer `ZStack` in `ContentView.body` in `NerdBook/ContentView.swift`

**Checkpoint**: MVP complete — WOTD shows on launch, hides when searching, reappears when cleared. Column headers hidden in empty state.

---

## Phase 3: User Story 3 — Daily WOTD Refresh (Priority: P2)

**Goal**: The WOTD refreshes across app launches so the user sees a new word each morning. Graceful fallback when offline.

**Independent Test**: Launch app and note the word. Quit and relaunch within 23 hours — same word, no network call. Simulate stale timestamp (>23 hours) and relaunch — new word fetched.

### Implementation

- [x] T007 [US3] Verify staleness logic in `fetchWordOfTheDayIfNeeded()` in `Shared/SharedData.swift` — confirm it skips fetch when `wotdFetchedAt` is less than 23 hours old and re-fetches when stale
- [x] T008 [US3] Add offline fallback in `fetchWordOfTheDayIfNeeded()` in `Shared/SharedData.swift` — if fetch fails and cached `wotdWord` exists, preserve the cached values (don't nil them out)

**Checkpoint**: WOTD refreshes daily across launches, gracefully handles network failures.

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Visual refinement and edge case handling

- [x] T009 Add a subtle fade-in animation when the WOTD appears after fetch completes in `NerdBook/ContentView.swift`
- [x] T010 Handle edge case: word with no definition — display word without definition section in `WordOfTheDayView` in `NerdBook/ContentView.swift`
- [x] T011 Verify the WOTD view looks correct at different window sizes (min 680x420 and larger) in `NerdBook/ContentView.swift`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Foundational)**: No dependencies — start immediately
- **Phase 2 (US1+US2)**: Depends on Phase 1 completion (needs WOTD data properties)
- **Phase 3 (US3)**: Depends on Phase 1 completion (staleness logic is in the fetch method)
- **Phase 4 (Polish)**: Depends on Phase 2 completion (needs the WOTD view to exist)

### User Story Dependencies

- **US1+US2 (P1)**: Depends on T001, T002 — core MVP, implement first
- **US3 (P2)**: Depends on T002 — largely covered by the fetch method, mostly verification
- US3 is partially implemented in Phase 1 (the staleness check is part of `fetchWordOfTheDayIfNeeded`). Phase 3 tasks are verification and hardening.

### Within Each Phase

- T001 before T002 (properties before method using them)
- T003 before T005 (view before conditional that references it)
- T004 before T005 (condition before conditional that uses it)
- T003 and T004 can run in parallel (different code sections)

### Parallel Opportunities

- T003 and T004 can be done in parallel (view creation vs condition logic, different code sections)
- Phase 3 (US3) tasks are independent of Phase 2 UI tasks (different files)
- T009, T010, T011 in Polish phase are independent of each other

---

## Implementation Strategy

### MVP First (User Stories 1+2)

1. Complete Phase 1: Add WOTD state to DataMuse (T001, T002)
2. Complete Phase 2: WOTD view + conditional swap (T003–T006)
3. **STOP and VALIDATE**: Launch app, verify WOTD appears, search works, ESC returns to WOTD
4. This is a shippable MVP

### Incremental Delivery

1. Phase 1 → Data layer ready
2. Phase 2 → MVP: WOTD in empty state with hidden headers
3. Phase 3 → Staleness verification and offline hardening
4. Phase 4 → Animation, edge cases, responsive layout

---

## Notes

- Only 2 source files are modified: `Shared/SharedData.swift` and `NerdBook/ContentView.swift`
- No new files created — follows existing project conventions
- The existing `fetchWordOfTheDay()` and `fetchDefinitionForWidget()` free functions are reused, not duplicated
- Column headers hide automatically because the entire column `HStack` is swapped out — no separate hide/show logic needed
- ESC/clear behavior already resets result arrays and search text, so WOTD reappears reactively
