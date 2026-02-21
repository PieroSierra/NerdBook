# Tasks: Mac Word Pills

**Input**: Design documents from `/specs/003-mac-word-pills/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, quickstart.md ✓

## Phase 1: Foundational — Cross-platform ColorButton

**Purpose**: Make `ColorButton` available on macOS. Blocks all user story work.

- [x] T001 [US1] Make `ColorButton` cross-platform in `Shared/SharedLogic.swift` — move struct outside `#if os(iOS)` guard and add platform conditional for background color (`Color(UIColor.systemBackground)` on iOS, `Color(NSColor.windowBackgroundColor)` on macOS). Keep `ColorButtonViewModel` and `FrequencyURLButton` iOS-only.

**Checkpoint**: `ColorButton` compiles for both macOS and iOS targets before proceeding.

---

## Phase 2: User Story 1 — Words Appear as Pills (Priority: P1) 🎯 MVP

**Goal**: Replace plain `Text + onTapGesture` synonyms in all three Mac columns with `ColorButton` pills.

**Independent Test**: Search any word → all three columns show pill-shaped buttons with gradient borders.

### Implementation

- [x] T002 [US1] Replace Normal synonyms in `NerdBook/ContentView.swift` (~line 62): change `ForEach(dataMuse.synonyms)` loop body from `Text + onTapGesture` to `ColorButton(text:fontSize:colorScheme:action:onAnimationComplete:)`
- [x] T003 [US1] Replace Poetic synonyms in `NerdBook/ContentView.swift` (~line 88): change `ForEach(dataMuse.lyricalSynonyms)` loop body to `ColorButton`
- [x] T004 [US1] Replace Nerdy synonyms in `NerdBook/ContentView.swift` (~line 114): change `ForEach(dataMuse.pretentiousSynonyms)` loop body to `ColorButton`

**Checkpoint**: Search a word → all three columns show pills. Clicking a pill triggers a new search.

---

## Phase 3: User Story 2 — Entrance Bounce Animation (Priority: P2)

**Goal**: Verify animation fires correctly on macOS (animation is already inside `ColorButton.onAppear`).

**Independent Test**: After search, observe staggered bounce animation in each column.

### Implementation

- [x] T005 [US2] Verify `ColorButton.onAppear` animation fires on macOS — check random stagger delay (0–350ms) and scale sequence (0.6 → 1.15 → 1.0) work correctly. If SwiftUI view identity causes issues with re-animation, adjust `VStack` spacing in each column to `8` to ensure visual correctness.

**Checkpoint**: Pills animate in with stagger on first load and on each new search.

---

## Phase 4: User Story 3 — No Definitions Displayed (Priority: P3)

**Goal**: Confirm no definition text appears alongside pills on Mac.

**Independent Test**: After animation completes, no definition text visible next to pills.

### Implementation

- [x] T006 [US3] Verify no definition text is emitted by the `ColorButton` calls (all `onAnimationComplete: {}` are no-ops). No code changes expected — this is a confirmation task.

**Checkpoint**: Pills show only word text. Bottom glass definition bar still works.

---

## Phase 5: Polish

- [x] T007 [P] Build both macOS and iOS targets and confirm zero compile errors
- [x] T008 [P] Adjust inner `VStack` spacing in each column from `5` to `8` for better pill breathing room

---

## Dependencies & Execution Order

- **T001** (Foundational): Must complete before T002–T004
- **T002, T003, T004** (Phase 2): Can run in parallel — different ForEach blocks, no state conflicts
- **T005** (Phase 3): Runs after T002–T004 (animation only visible when pills exist)
- **T006** (Phase 4): Runs concurrently with T005 — just a verification
- **T007, T008** (Polish): After T002–T006
