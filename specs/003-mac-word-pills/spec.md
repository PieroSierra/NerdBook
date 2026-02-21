# Feature Specification: Mac Word Pills

**Feature Branch**: `003-mac-word-pills`
**Created**: 2026-02-21
**Status**: Draft
**Input**: User description: "now let's work on bringing the ios style word pills to the MacOS app (which still uses simple underlined words). Let's match the iOS style where each word is a pill. But (for now), unlike iOS I do not want to show definitions next to each word. I just want the word pills, with the same entrance bounce animation."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Words Appear as Pills (Priority: P1)

A user searches for a word on the Mac app. Instead of plain colored text in columns, each synonym in the Normal, Poetic, and Nerdy columns appears as a styled pill button — a rounded rectangle with the app's gradient border — matching the visual style already used on iOS.

**Why this priority**: This is the core visual change. All other improvements depend on pills being rendered correctly.

**Independent Test**: Search for any word. Verify each synonym in all three columns renders as a pill with a rounded rectangle outline using the app's gradient border. Can be fully verified in isolation without the animation.

**Acceptance Scenarios**:

1. **Given** a word has been searched, **When** synonyms are displayed in the Normal column, **Then** each synonym word appears as a pill-shaped button with the app's gradient border (pink↔blue depending on dark/light mode)
2. **Given** the app is in dark mode, **When** synonyms appear, **Then** pill borders use the pink-to-blue gradient (same as iOS dark mode)
3. **Given** the app is in light mode, **When** synonyms appear, **Then** pill borders use the blue-to-pink gradient (same as iOS light mode)
4. **Given** a word pill is clicked, **When** the click resolves, **Then** the app searches for that word (same behavior as current plain-text tap)

---

### User Story 2 - Entrance Bounce Animation (Priority: P2)

When synonym results arrive, each pill animates into view with a staggered bounce: starting at a small scale, springing up slightly past full size, then settling at normal size. Pills animate with random individual delays so they feel organic rather than all appearing at once.

**Why this priority**: The animation gives the UI life and matches the iOS feel. Depends on pills existing (P1).

**Independent Test**: After a word search returns results, observe that pills scale from small → slightly-oversized → normal, with each pill starting its animation at a slightly different time.

**Acceptance Scenarios**:

1. **Given** new search results arrive, **When** pills render, **Then** each pill begins at a reduced scale (≈60% of full size) and animates to full size with an overshoot
2. **Given** multiple pills appear, **When** they animate, **Then** each pill's animation starts with a small random delay (0–350ms) so they don't all pop in simultaneously
3. **Given** the user searches a new word while pills are visible, **When** results load, **Then** all pills re-run their entrance animation for the new results
4. **Given** an animation is in progress, **When** the user clicks a pill, **Then** the click still registers and triggers a new search

---

### User Story 3 - No Definitions Displayed (Priority: P3)

Unlike the iOS implementation which shows a definition snippet next to each pill after the animation completes, the Mac version shows only the word pills with no definition text alongside them.

**Why this priority**: This is an explicit scope constraint — definitions are already shown in the bottom glass bar, so per-pill definitions are not needed on Mac.

**Independent Test**: After the bounce animation completes for all pills, verify that no definition text appears next to any pill.

**Acceptance Scenarios**:

1. **Given** the entrance animation completes, **When** any pill is fully visible, **Then** no definition text appears next to or below that pill
2. **Given** the bottom glass definition bar is showing a definition, **When** pills are visible, **Then** the bottom bar still shows the definition (unaffected by this feature)

---

### Edge Cases

- What happens when a search returns zero results for a column? The column remains empty — no pills, no placeholder.
- What happens when there are a large number of synonyms (50+)? Pills still render and animate; each column scrolls independently as before.
- What if the user searches rapidly before animations finish? Animations reset cleanly for the new result set.
- What if a synonym word is very long? The pill text fits within normal padding; extremely long words may truncate at the column width boundary.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Mac app MUST display each synonym word as a pill-shaped button using a rounded rectangle with the app's gradient border (matching iOS `ColorButton` style)
- **FR-002**: Pill buttons MUST use the same gradient direction as iOS: pink→blue in dark mode, blue→pink in light mode
- **FR-003**: Each pill MUST have a background matching the system window background (not transparent, not a solid accent color)
- **FR-004**: Pill buttons MUST be clickable and trigger a new synonym search for that word (same as current tap behavior)
- **FR-005**: Each pill MUST animate on appearance: scale starts at ~60%, springs to ~115%, then settles at 100%
- **FR-006**: Each pill's entrance animation MUST start after a random delay between 0ms and 350ms to create a staggered, organic effect
- **FR-007**: When a new search result set arrives, all pills MUST re-run their entrance animation
- **FR-008**: No definition text MUST appear adjacent to any pill on the Mac
- **FR-009**: The pill component MUST be usable from the macOS target (the existing iOS pill component is not available on macOS)
- **FR-010**: The three-column layout (Normal, Poetic, Nerdy) MUST be preserved

### Key Entities

- **Word Pill**: A pressable button displaying a single synonym word, styled with rounded corners and gradient border, with entrance animation. Has no definition display on Mac.
- **Entrance Animation**: A scale sequence (0.6 → 1.15 → 1.0) with random stagger delay applied when a pill first appears.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After a search, 100% of synonym words in all three columns render as pill buttons (zero plain text words remain)
- **SC-002**: Each pill completes its entrance animation within 700ms of the result appearing (random delay of 0–350ms + ~300ms animation)
- **SC-003**: Clicking any word pill triggers a synonym search for that word — same reliability as current plain-text click behavior
- **SC-004**: No definition text appears adjacent to any pill at any point during or after the animation
- **SC-005**: Mac pill visual style (shape, border color, background) matches the iOS pill style when both platforms display the same word results

## Assumptions

- The three-column VStack layout is preserved; pills replace plain `Text` views within each column's existing `ScrollView > VStack`.
- The macOS pill component will use the system window background color for its fill, matching `Color(UIColor.systemBackground)` on iOS.
- The `onAnimationComplete` callback from the iOS component will be present but unused (no-op), keeping the component symmetric for potential future definition display.
- Press feedback on Mac will use a standard button scale effect appropriate for macOS mouse interactions.
