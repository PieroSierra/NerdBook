# Research: Mac Word Pills

**Branch**: `003-mac-word-pills` | **Date**: 2026-02-21

## Decision 1: macOS equivalent background color for `ColorButton`

**Decision**: Use `Color(NSColor.windowBackgroundColor)` on macOS inside a `#if os(iOS) / #else / #endif` block.

**Rationale**: `NSColor.windowBackgroundColor` is the semantic AppKit color for window content background; it adapts to dark/light mode automatically just like `UIColor.systemBackground` on iOS. The Mac `ContentView.swift` already uses this pattern (`Color(NSColor.windowBackgroundColor)` at line 16), confirming it is the project convention.

**Alternatives considered**:
- `Color(.windowBackground)` via `ShapeStyle` — less explicit, may behave differently
- `Color.clear` — would make pills borderless blobs in dark mode
- A fixed color constant — would not adapt to dark/light mode

---

## Decision 2: Press feedback gesture on macOS

**Decision**: Keep `onLongPressGesture(minimumDuration: 0.1, pressing:)` from the existing iOS `ColorButton` — no change needed.

**Rationale**: With `minimumDuration: 0.1`, the gesture fires during normal mouse clicks (which last well over 100ms). The `pressing:` callback fires immediately on mouse down, providing the scale-up press feedback. This is functionally equivalent to iOS behavior. The spec says to match iOS — there is no requirement for macOS-native button conventions.

**Alternatives considered**:
- Custom `ButtonStyle` with `configuration.isPressed` — more idiomatic macOS, but adds refactoring scope not requested
- Removing press feedback entirely on macOS — loses visual feedback

---

## Decision 3: Animation compatibility

**Decision**: Reuse the existing `ColorButton` animation code unchanged on macOS.

**Rationale**: All three animation primitives are platform-universal:
- `.scaleEffect(_:)` — SwiftUI modifier, same on all Apple platforms
- `DispatchQueue.main.asyncAfter(deadline:)` — Foundation, platform-agnostic
- `withAnimation(.easeOut(duration:))` — SwiftUI animation, same on all Apple platforms

The bounce sequence (0.6 → 1.15 → 1.0 with random 0–350ms stagger delay) will produce identical results on macOS.

**Alternatives considered**: None — the primitives are identical.

---

## Decision 4: Where to put the cross-platform `ColorButton`

**Decision**: Move `ColorButton` out of the `#if os(iOS)` block in `Shared/SharedLogic.swift`. Keep `ColorButtonViewModel` and `FrequencyURLButton` iOS-only.

**Rationale**: `SharedLogic.swift` is the existing home for shared UI components. `ColorButton` uses only standard SwiftUI (no UIKit except for the background color, which we handle with a conditional). `FrequencyURLButton` uses `openURL` for `nerdbook://` deep links — this URL scheme is not wired up on Mac, so keeping it iOS-only is correct. `ColorButtonViewModel` is not used in any live view (legacy/unused), so keeping it iOS-only reduces noise.

**Alternatives considered**:
- Copy `ColorButton` into `NerdBook/ContentView.swift` — creates duplication; iOS and Mac would drift
- Create a new file `Shared/PillButton.swift` — unnecessary new file for a one-struct change
- Create a `MacColorButton` struct — same duplication problem

---

## Decision 5: Animation re-trigger on new searches

**Decision**: Rely on SwiftUI's standard `ForEach` identity behavior (no explicit reset mechanism).

**Rationale**: When `dataMuse.synonyms` changes to a different word set, SwiftUI recreates views with different identities, which fires `.onAppear` and triggers the bounce animation. For the rare case where a user searches the same word twice, pills won't re-animate — this is acceptable UX (expected behavior).

The iOS app handles `animationCompletionStatus` reset to control definition display timing. Since Mac shows no per-pill definitions, there is no need for this tracking on Mac.

**Alternatives considered**:
- `@State private var searchResultID = UUID()` with `.id(searchResultID)` — forces full recreation but adds state complexity for marginal gain
- `.id(query + synonym.word)` — changes during typing, causes unintended re-animation
