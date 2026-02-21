# Research: Mac Multiple Definitions

## R1: Data Layer Availability

**Decision**: No API or data model changes needed — reuse existing `currentDefs: [String]` on the shared `DataMuse` class.

**Rationale**: The shared `Shared/SharedData.swift` already fetches definitions via `https://api.datamuse.com/words?sp=QUERY&md=d`, parses them (splitting by `\t` to strip part-of-speech prefix), and stores the full array in `currentDefs`. The Mac app already consumes `currentDefinition` (first item) for the bar. The array is populated and ready.

**Alternatives considered**:
- Separate Mac-specific fetch: Unnecessary — shared class already does this.
- Store definitions on `Word` entities instead: Would require restructuring; `currentDefs` is simpler for the current use case.

## R2: macOS Sheet Presentation

**Decision**: Use SwiftUI `.sheet(isPresented:)` modifier, matching the iOS approach.

**Rationale**: Standard SwiftUI pattern, works on macOS 13+. The iOS app uses `.sheet(isPresented: $appState.showingTriggerSheet)` with `.presentationDetents([.medium, .large])`. On macOS, sheets present as attached modal panels by default, which is the expected Mac behavior. No need for `NSPanel` or custom window management.

**Alternatives considered**:
- `.popover()`: Too small for a card carousel, dismisses on outside click.
- Custom `NSWindow`/`NSPanel`: Over-engineered for this use case.
- `.fullScreenCover()`: Not standard on macOS.

## R3: DefinitionCard Portability (iOS → Mac)

**Decision**: Create a Mac-specific `DefinitionCard` in `ContentView.swift` (where all Mac views live), adapting the iOS version.

**Rationale**: The iOS `DefinitionCard` uses `UIColor.systemBackground` and `.presentationBackground(.thickMaterial)` which are iOS-only APIs. The Mac version needs `NSColor.windowBackgroundColor` (or `Color(NSColor.windowBackgroundColor)`) and can use `.nerdBookGlassEffect()` for consistency with the existing definition bar. Card dimensions should be slightly larger (350x170) to suit Mac window sizes.

**Alternatives considered**:
- Shared cross-platform `DefinitionCard`: Would require `#if os()` blocks throughout, adding complexity for minimal gain since the two are in different targets.
- Exact same 300x150 size: Feels too small on Mac screens.

## R4: Interactivity Affordance on Definition Bar

**Decision**: Add `.onTapGesture` to the whole definition bar, plus a pointer cursor on hover and an ellipsis icon (matching iOS).

**Rationale**: The iOS definition bar has an `Image(systemName: "ellipsis.circle")` icon and uses `.onTapGesture`. On Mac, we should additionally show a pointer cursor on hover (`.cursor(.pointingHand)` on macOS 26+ or `NSCursor.pointingHand` via `.onHover`), as this is expected Mac UX for clickable elements. The existing `Image(systemName: "info.circle")` in the bar can be replaced with `"ellipsis.circle"` or kept — user preference.

**Alternatives considered**:
- Button wrapping: Adds button chrome which conflicts with the glass effect styling.
- Only cursor change, no icon: Insufficient discoverability.
