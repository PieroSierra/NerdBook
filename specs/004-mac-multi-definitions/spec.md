# Feature Specification: Mac Multiple Definitions

**Feature Branch**: `004-mac-multi-definitions`
**Created**: 2026-02-21
**Status**: Draft
**Input**: User description: "Add multiple definitions support to Mac app — make the definition bar clickable, opening a sheet with horizontal definition cards (matching the iOS experience)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View All Definitions for a Word (Priority: P1)

A user searches for a word and sees the first definition in the bottom definition bar. They want to see all available definitions. They click anywhere on the definition bar and a sheet opens, displaying all definitions as horizontally scrollable cards. They can swipe or scroll through the cards to read each definition, then dismiss the sheet to return to the main view.

**Why this priority**: Core feature — without this, users only ever see one definition per word on Mac, while iOS already supports browsing all definitions.

**Independent Test**: Can be fully tested by searching any word with multiple definitions (e.g., "run", "set", "light") and clicking the definition bar to verify all definitions appear as cards.

**Acceptance Scenarios**:

1. **Given** a word has been searched and definitions are available, **When** the user clicks anywhere on the definition bar, **Then** a sheet opens showing all definitions as horizontal cards.
2. **Given** the definitions sheet is open, **When** the user scrolls horizontally, **Then** additional definition cards are revealed smoothly.
3. **Given** the definitions sheet is open, **When** the user dismisses the sheet (close button or standard macOS dismiss gesture), **Then** the sheet closes and the main view is unaffected.
4. **Given** a word has only one definition, **When** the user clicks the definition bar, **Then** the sheet opens showing a single definition card (no empty space or confusing layout).

---

### User Story 2 - Visual Parity with iOS Definition Cards (Priority: P2)

The definition cards in the Mac sheet should look and feel consistent with the iOS version — each card has a fixed size, uses a readable font, supports text selection, and animates in with a subtle entrance effect. The sheet itself uses a material/translucent background consistent with macOS design language.

**Why this priority**: Ensures cross-platform consistency. Users who switch between iPhone and Mac should recognize the same interaction pattern.

**Independent Test**: Can be tested visually by comparing the Mac sheet side-by-side with the iOS sheet to verify card sizing, font style, text selectability, and animation behavior match.

**Acceptance Scenarios**:

1. **Given** the definitions sheet is open, **When** definition cards are displayed, **Then** each card has a consistent fixed size, readable typography, and rounded corners.
2. **Given** the definitions sheet is open, **When** the user selects text within a definition card, **Then** the text can be copied.
3. **Given** the definitions sheet opens, **When** cards appear, **Then** they animate in with a subtle scale/bounce effect.

---

### Edge Cases

- What happens when a word has no definitions? The definition bar does not appear (existing behavior), so the sheet cannot be opened — no change needed.
- What happens when the definition text is very long? The card should accommodate longer text with internal scrolling or text wrapping, not clip content.
- What happens when there are many definitions (e.g., 10+)? The horizontal scroll should handle any number of cards smoothly.
- How does the sheet look in Dark Mode? Cards and backgrounds should respect the system color scheme, matching the existing app theming.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The entire definition bar at the bottom of the Mac app MUST be clickable/tappable.
- **FR-002**: Clicking the definition bar MUST open a macOS sheet presenting all definitions for the current word.
- **FR-003**: Definitions in the sheet MUST be displayed as horizontally scrollable cards.
- **FR-004**: Each definition card MUST support text selection so users can copy definitions.
- **FR-005**: The sheet MUST be dismissible via a close button or standard macOS sheet dismissal.
- **FR-006**: Definition cards MUST animate in with a subtle entrance effect (scale/bounce).
- **FR-007**: The sheet and cards MUST respect Dark Mode and Light Mode.
- **FR-008**: The definition bar MUST visually indicate it is interactive (e.g., cursor change to pointer on hover, or a subtle affordance like an ellipsis icon).

### Key Entities

- **Definition**: A text string describing the meaning of a word. A word can have zero or more definitions. The data is already fetched and stored by the existing API integration (`currentDefs` array).
- **Definition Bar**: The existing bottom overlay in the Mac app that currently shows the first definition. Will become the entry point for the sheet.
- **Definitions Sheet**: A new macOS sheet containing a horizontal carousel of definition cards.
- **Definition Card**: A styled container showing a single definition with fixed dimensions, rounded corners, and entrance animation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can access all definitions for any searched word within one click from the main view.
- **SC-002**: The definitions sheet displays correctly with 1 to 15+ definitions without layout issues.
- **SC-003**: Definition card appearance on Mac is visually consistent with the iOS definition cards.
- **SC-004**: The feature works correctly in both Light Mode and Dark Mode.
- **SC-005**: No regressions — existing search, synonym columns, autocomplete, and single-definition display continue to work as before.

## Assumptions

- The Mac DataMuse class already fetches and stores multiple definitions in `currentDefs` — no API changes are needed.
- The first definition shown in the bar (`currentDefinition`) continues to be displayed as-is; the sheet provides access to all definitions.
- The Mac sheet will use standard macOS sheet presentation.
- Card sizing will be adapted from the iOS 300x150 to be appropriate for Mac window sizes (may be slightly larger).
- The iOS trigger words sheet also shows "trigger words" — for this Mac feature, we focus only on the definitions carousel. Trigger words are out of scope unless explicitly requested later.
