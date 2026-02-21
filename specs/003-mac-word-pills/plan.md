# Implementation Plan: Mac Word Pills

**Branch**: `003-mac-word-pills` | **Date**: 2026-02-21 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-mac-word-pills/spec.md`

## Summary

Replace plain colored `Text` synonyms on the Mac app with iOS-matching pill buttons: rounded rectangles with a gradient border and a staggered bounce entrance animation. The iOS `ColorButton` component in `Shared/SharedLogic.swift` already implements the exact required style but is guarded to `#if os(iOS)`. The primary work is making `ColorButton` cross-platform (one platform conditional for the background color), then replacing the three `ForEach` synonym loops in `NerdBook/ContentView.swift` to use `ColorButton` instead of `Text + onTapGesture`.

## Technical Context

**Language/Version**: Swift 5.9+, SwiftUI 4.0+
**Primary Dependencies**: SwiftUI (built-in), AppKit (built-in, macOS), UIKit (built-in, iOS)
**Storage**: N/A — pure UI change, no persistence
**Testing**: XCTest (existing structure, no new test cases required for this visual feature)
**Target Platform**: macOS 14.6+ (Sonoma), iOS 17.0+
**Project Type**: Native cross-platform macOS/iOS SwiftUI app
**Performance Goals**: Animation completes within 700ms per pill; no measurable impact on scroll performance
**Constraints**: Preserve existing three-column layout; no per-pill definitions on Mac; single `Shared/` source for the pill component
**Scale/Scope**: UI-only change affecting 3 ForEach loops in `NerdBook/ContentView.swift` and 1 struct in `Shared/SharedLogic.swift`

## Constitution Check

No constitution file found at `.specify/memory/constitution.md`. No gates to evaluate.

## Project Structure

### Documentation (this feature)

```text
specs/003-mac-word-pills/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (minimal — no new data)
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks — NOT created here)
```

### Source Code (files affected)

```text
Shared/
└── SharedLogic.swift        # Make ColorButton cross-platform (remove iOS-only guard)

NerdBook/
└── ContentView.swift        # Replace Text+onTapGesture with ColorButton in 3 columns
```

No new files. No other files touched.

**Structure Decision**: Existing single-project structure. This feature modifies exactly two existing files.

## Phases

### Phase 0: Research — Complete

See [research.md](./research.md) for full findings. Summary:

| Question | Finding |
|----------|---------|
| macOS equivalent of `Color(UIColor.systemBackground)` | `Color(NSColor.windowBackgroundColor)` — adapts to dark/light mode |
| `onLongPressGesture` on macOS | Works; `minimumDuration: 0.1` is short enough to trigger on normal mouse clicks |
| `.scaleEffect`, `DispatchQueue.main.asyncAfter`, `withAnimation` on macOS | Identical behavior — no changes needed |
| `RoundedRectangle + LinearGradient` stroke on macOS | Renders identically |

### Phase 1: Design

See [data-model.md](./data-model.md) — no new data models. Pure UI.

No API contracts (no network or storage changes).

See [quickstart.md](./quickstart.md) for implementation guidance.

## Implementation Tasks

### Task 1 — Make `ColorButton` cross-platform
**File**: `Shared/SharedLogic.swift`
**Change**: Move `ColorButton` struct outside the `#if os(iOS)` block. Add a platform conditional inside the struct for the background fill. Keep `FrequencyURLButton`, `ColorButtonViewModel` iOS-only.

**Before** (line 186):
```
#if os(iOS)
class ColorButtonViewModel: ObservableObject { ... }

struct ColorButton: View { ... }         // uses Color(UIColor.systemBackground)
struct FrequencyURLButton: View { ... }
#endif
```

**After**:
```
#if os(iOS)
class ColorButtonViewModel: ObservableObject { ... }
#endif

struct ColorButton: View {
    // ... same as before, except:
    // background fill becomes:
    #if os(iOS)
    Color(UIColor.systemBackground)
    #else
    Color(NSColor.windowBackgroundColor)
    #endif
}

#if os(iOS)
struct FrequencyURLButton: View { ... }
#endif
```

### Task 2 — Replace synonyms in Mac ContentView with pills
**File**: `NerdBook/ContentView.swift`
**Change**: In each of the three ForEach loops, replace:
```swift
Text(synonym.word)
    .font(.body)
    .foregroundColor(...)
    .lineLimit(1)
    .truncationMode(.tail)
    .fixedSize(horizontal: true, vertical: false)
    .onTapGesture {
        isUserSelecting = true
        query = synonym.word
        dataMuse.fetchSynonyms(query: query)
    }
```
With:
```swift
ColorButton(
    text: synonym.word,
    fontSize: 16,
    colorScheme: colorScheme,
    action: {
        isUserSelecting = true
        query = synonym.word
        dataMuse.fetchSynonyms(query: query)
    },
    onAnimationComplete: {}
)
```

The inner `VStack(alignment: .leading, spacing: 5)` should change spacing to match iOS pill row spacing (`.padding(.top, 4)` per pill, or adjust `VStack` spacing to ~8).

No new `@State` variables required — `ColorButton` manages its own animation state internally.
