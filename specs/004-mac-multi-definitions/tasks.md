# Tasks: Mac Multiple Definitions

**Input**: Design documents from `/specs/004-mac-multi-definitions/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks grouped by user story. All changes in a single file: `NerdBook/ContentView.swift`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files/structs, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- All file paths are relative to repository root

---

## Phase 1: Setup

**Purpose**: Add sheet state and prepare the definition bar for interactivity

- [x] T001 Add `@State private var showDefinitionsSheet: Bool = false` to ContentView properties in `NerdBook/ContentView.swift`
- [x] T002 Update `DefinitionBarView` to accept an `onTap: () -> Void` closure parameter and wrap its body content in a tap gesture that calls `onTap()` in `NerdBook/ContentView.swift`
- [x] T003 Update the `DefinitionBarView` call site in ContentView body to pass `onTap: { showDefinitionsSheet = true }` in `NerdBook/ContentView.swift`

**Checkpoint**: App builds, definition bar is tappable (sets state), but no sheet appears yet.

---

## Phase 2: User Story 1 — View All Definitions for a Word (Priority: P1) 🎯 MVP

**Goal**: Clicking the definition bar opens a sheet with horizontally scrollable definition cards showing all definitions for the current word.

**Independent Test**: Search "run" or "set" → click definition bar → sheet opens with multiple definition cards → scroll horizontally → dismiss sheet → main view unaffected.

### Implementation for User Story 1

- [x] T004 [P] [US1] Create `MacDefinitionCard` struct in `NerdBook/ContentView.swift` with: fixed frame (350x170), `Color(NSColor.windowBackgroundColor)` background, corner radius 15, American Typewriter font size 16, `.textSelection(.enabled)`, shadow, bouncy scale animation (0.2→1.0), tab-prefix stripping via `definition.components(separatedBy: "\t").last`, colorScheme-aware styling
- [x] T005 [P] [US1] Create `DefinitionsSheetView` struct in `NerdBook/ContentView.swift` with: `word: String` and `definitions: [String]` parameters, title in `.largeTitle.bold()`, horizontal `ScrollView(.horizontal, showsIndicators: false)` containing `LazyHStack(spacing: 20)` of `MacDefinitionCard` instances, "No definitions available." fallback when empty, dismiss button (xmark.circle.fill) as top-right overlay using `@Environment(\.dismiss)`, frame `maxWidth: .infinity, maxHeight: .infinity`
- [x] T006 [US1] Add `.sheet(isPresented: $showDefinitionsSheet)` modifier to ContentView body (on the main ZStack, after `.toolbar`), presenting `DefinitionsSheetView(word: query, definitions: dataMuse.currentDefs)` in `NerdBook/ContentView.swift`
- [x] T007 [US1] Add `// MARK: - MacDefinitionCard` and `// MARK: - DefinitionsSheetView` comments in `NerdBook/ContentView.swift` following the existing MARK pattern (place after `// MARK: - DefinitionBarView`)

**Checkpoint**: Full MVP — search a word, click definition bar, sheet opens with all definition cards, horizontal scrolling works, sheet dismisses cleanly. Build with `xcodebuild -scheme NerdBook -destination 'platform=macOS' build`.

---

## Phase 3: User Story 2 — Visual Parity with iOS Definition Cards (Priority: P2)

**Goal**: Definition cards and the definition bar match the iOS visual experience — interactive affordance on the bar, polished card appearance, dark/light mode support.

**Independent Test**: Compare Mac sheet side-by-side with iOS → cards have consistent sizing, font, animations. Hover over definition bar → pointer cursor appears. Toggle Dark Mode → cards adapt correctly.

### Implementation for User Story 2

- [x] T008 [P] [US2] Add pointer cursor on hover to `DefinitionBarView` in `NerdBook/ContentView.swift`: use `.onHover { hovering in if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() } }` on the tappable content
- [x] T009 [P] [US2] Replace `Image(systemName: "info.circle")` with `Image(systemName: "ellipsis.circle")` in `DefinitionBarView` to match the iOS affordance icon in `NerdBook/ContentView.swift`
- [x] T010 [US2] Verify Dark Mode appearance: ensure `MacDefinitionCard` uses `colorScheme` environment to adapt background and shadow colors in `NerdBook/ContentView.swift` — use `Color(NSColor.windowBackgroundColor)` (auto-adapts) and reduce shadow opacity in dark mode

**Checkpoint**: Visual parity complete — bar shows pointer cursor on hover, ellipsis icon signals interactivity, cards look correct in both light and dark mode. Run full quickstart.md manual testing checklist.

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across all user stories

- [x] T011 Build Mac target with `xcodebuild -scheme NerdBook -destination 'platform=macOS' build` — must compile with zero errors
- [ ] T012 Run full manual verification from `specs/004-mac-multi-definitions/quickstart.md` — all 9 test scenarios pass
- [ ] T013 Verify no regressions: search works, synonym columns populate, autocomplete appears, loading spinner works, existing definition bar still shows first definition

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: T001 → T002 → T003 (sequential — each depends on the previous)
- **User Story 1 (Phase 2)**: Depends on Phase 1 completion
  - T004 and T005 can run in parallel (separate structs)
  - T006 depends on T004 + T005 (wires them together)
  - T007 can run alongside T006
- **User Story 2 (Phase 3)**: Depends on Phase 2 completion (needs DefinitionBarView and MacDefinitionCard to exist)
  - T008 and T009 can run in parallel (different parts of DefinitionBarView)
  - T010 depends on T004 existing
- **Polish (Phase 4)**: Depends on all previous phases

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Setup — no dependencies on US2
- **User Story 2 (P2)**: Depends on US1 being complete (modifies views created in US1)

### Parallel Opportunities

Within Phase 2: T004 and T005 are independent structs — can be written in parallel.
Within Phase 3: T008 and T009 touch different parts of DefinitionBarView — can be done in parallel.

---

## Parallel Example: User Story 1

```text
# These two structs can be created in parallel (separate structs, no dependencies):
Task: "Create MacDefinitionCard struct in NerdBook/ContentView.swift"
Task: "Create DefinitionsSheetView struct in NerdBook/ContentView.swift"

# Then wire them together (depends on both above):
Task: "Add .sheet(isPresented:) modifier to ContentView body"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: User Story 1 (T004–T007)
3. **STOP and VALIDATE**: Build + test definition bar click → sheet → cards → dismiss
4. This delivers the core feature — users can browse all definitions

### Incremental Delivery

1. Phase 1 → Setup complete
2. Phase 2 → US1 complete → Core feature working (MVP!)
3. Phase 3 → US2 complete → Visual polish, iOS parity
4. Phase 4 → Full validation → Ready to merge

---

## Notes

- All 13 tasks modify a single file: `NerdBook/ContentView.swift`
- No changes to `Shared/SharedData.swift` — `currentDefs` is already populated
- Reference iOS implementation at `NerdBookiOS/TriggerWordsView.swift` for visual targets
- The existing `DefinitionBarView` was extracted in the recent refactor — modifications build on that clean structure
