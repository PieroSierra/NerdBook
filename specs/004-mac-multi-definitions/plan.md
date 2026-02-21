# Implementation Plan: Mac Multiple Definitions

**Branch**: `004-mac-multi-definitions` | **Date**: 2026-02-21 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-mac-multi-definitions/spec.md`

## Summary

Add multiple definitions browsing to the Mac app. The existing definition bar becomes clickable, opening a macOS sheet with horizontally scrollable definition cards — matching the iOS experience. No API or data model changes needed; `currentDefs` is already populated by the shared `DataMuse` class.

## Technical Context

**Language/Version**: Swift 5.9+, SwiftUI 4.0+
**Primary Dependencies**: SwiftUI (built-in), AppKit (built-in, macOS)
**Storage**: N/A (in-memory `@Published` properties on existing `DataMuse` ObservableObject)
**Testing**: Manual verification (Xcode build + run); no unit test framework currently in project
**Target Platform**: macOS 13+ (with macOS 26 Liquid Glass enhancement via `nerdBookGlassEffect()`)
**Project Type**: Mobile (dual-target: macOS + iOS, shared data layer)
**Performance Goals**: Smooth 60fps horizontal scrolling of definition cards
**Constraints**: Must not modify `Shared/SharedData.swift`; all changes in `NerdBook/ContentView.swift`
**Scale/Scope**: Single file change, ~80 lines of new code (2 new structs + state wiring)

## Constitution Check

*No constitution file found. No gates to evaluate.*

## Project Structure

### Documentation (this feature)

```text
specs/004-mac-multi-definitions/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output — research findings
├── data-model.md        # Phase 1 output — data model (no changes needed)
├── quickstart.md        # Phase 1 output — build & test instructions
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
NerdBook/
├── ContentView.swift        # ← ONLY file modified (add DefinitionsSheetView, MacDefinitionCard, state + wiring)
├── NerdBookApp.swift         # Glass effect extensions (read-only reference)
├── AboutView.swift
├── AboutWindowController.swift
└── ...

Shared/
├── SharedData.swift          # DataMuse class with currentDefs (NO CHANGES)
├── SharedLogic.swift         # ColorButton, Triangle, etc. (NO CHANGES)
└── WaveView.swift

NerdBookiOS/
├── TriggerWordsView.swift    # iOS DefinitionCard reference (read-only)
└── ...
```

**Structure Decision**: Single-file change in existing `NerdBook/ContentView.swift`. New views (`DefinitionsSheetView`, `MacDefinitionCard`) are added as structs in the same file, following the existing pattern where all Mac views live in ContentView.swift. This was recently refactored to use extracted subviews with MARK comments.

## Implementation Details

### Step 1: Add sheet state to ContentView

Add `@State private var showDefinitionsSheet: Bool = false` alongside existing state properties.

**File**: `NerdBook/ContentView.swift` — ContentView struct properties
**Traces**: FR-002

### Step 2: Make DefinitionBarView clickable

Modify `DefinitionBarView` to accept an `onTap` closure. In ContentView, pass a closure that sets `showDefinitionsSheet = true`. Add pointer cursor on hover and replace the `info.circle` icon with `ellipsis.circle` to signal more content.

**File**: `NerdBook/ContentView.swift` — `DefinitionBarView` struct
**Traces**: FR-001, FR-008

### Step 3: Create MacDefinitionCard

New struct adapted from iOS `DefinitionCard`:
- Fixed size 350x170 (slightly larger than iOS 300x150)
- Uses `Color(NSColor.windowBackgroundColor)` instead of `UIColor.systemBackground`
- Bouncy scale animation on appear (matching iOS: `scale 0.2 → 1.0`)
- American Typewriter font, text selection enabled
- Dark/light mode support via `colorScheme`
- Rounded corners (15pt) with subtle shadow

**File**: `NerdBook/ContentView.swift` — new struct after `DefinitionBarView`
**Traces**: FR-003, FR-004, FR-006, FR-007

### Step 4: Create DefinitionsSheetView

New struct containing:
- Title (the searched word) in `.largeTitle.bold()`
- Horizontal `ScrollView(.horizontal)` with `LazyHStack` of `MacDefinitionCard` instances
- "No definitions available" fallback text
- Dismiss button (X icon, top-right overlay)
- Uses `nerdBookGlassEffect()` or material background

**File**: `NerdBook/ContentView.swift` — new struct after `MacDefinitionCard`
**Traces**: FR-002, FR-003, FR-005

### Step 5: Wire sheet presentation in ContentView body

Add `.sheet(isPresented: $showDefinitionsSheet)` to the main ZStack, passing `dataMuse.currentDefs` and `query` to `DefinitionsSheetView`.

**File**: `NerdBook/ContentView.swift` — ContentView body
**Traces**: FR-002, SC-001

### Step 6: Add MARK comments for new views

Add `// MARK: - DefinitionsSheetView` and `// MARK: - MacDefinitionCard` following the existing MARK pattern.

**File**: `NerdBook/ContentView.swift`
**Traces**: Code organization (continuation of recent refactor)

## Verification

1. `xcodebuild -scheme NerdBook -destination 'platform=macOS' build` — zero errors
2. Run app → search "run" → definition bar appears → click → sheet opens with multiple cards
3. Horizontal scroll through cards works smoothly
4. Text selection works in cards
5. Sheet dismisses cleanly
6. Toggle Dark Mode — cards adapt
7. Search word with 1 definition → single card, no layout issues
8. Existing features (search, autocomplete, synonym columns) unaffected
