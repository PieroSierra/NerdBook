# Feature Specification: Word of the Day in Desktop Empty State

**Feature Branch**: `005-mac-wotd-empty-state`
**Created**: 2026-02-22
**Status**: Draft
**Input**: User description: "Bring the Word of the Day feature from the iOS widget to the NerdBook desktop app's empty state. Display WOTD centered on screen with American Typewriter font, quotation marks, and definition matching widget style. Hide column headers when empty. Refresh once per app launch or when stale (>23 hours)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See Word of the Day on App Launch (Priority: P1)

When a user opens the NerdBook desktop app without searching for anything, the empty results area displays the Word of the Day prominently. This replaces the blank/empty screen with engaging content that encourages word discovery. The word is shown in the same typographic style as the existing iOS widget: American Typewriter font with an opening curly quotation mark, a divider, and the definition beneath.

**Why this priority**: This is the core feature. Without this, the empty state remains blank and unengaging. Delivers immediate value on every app launch.

**Independent Test**: Can be fully tested by launching the desktop app without typing any search query. The WOTD should appear centered in the results area with correct styling.

**Acceptance Scenarios**:

1. **Given** the app is launched for the first time today, **When** the main window appears with no search query, **Then** the Word of the Day is displayed centered in the results area with American Typewriter font, an opening curly quotation mark, the word, a divider line, and the definition.
2. **Given** the app is showing the WOTD in the empty state, **When** the user types a search query and results appear, **Then** the WOTD is replaced by the search results and column headers become visible.
3. **Given** search results are displayed, **When** the user clears the search field (empty query, no results), **Then** the WOTD reappears in the empty state.

---

### User Story 2 - Column Headers Hidden in Empty State (Priority: P1)

When no search has been performed and the WOTD is displayed, the results table column headers ("Synonym", "Sounds Like", etc.) are hidden. This gives the WOTD a clean, uncluttered presentation. Headers reappear when the user performs a search and results are shown.

**Why this priority**: Critical to the visual design. Showing column headers above a centered WOTD would look broken and confusing.

**Independent Test**: Can be tested by observing the main window in empty state vs. after performing a search. Headers should toggle visibility accordingly.

**Acceptance Scenarios**:

1. **Given** no search query has been entered, **When** the WOTD is displayed, **Then** the column headers ("Synonym", etc.) are not visible.
2. **Given** the WOTD is displayed with hidden headers, **When** the user searches for a word and results appear, **Then** the column headers become visible above the results.

---

### User Story 3 - Daily WOTD Refresh (Priority: P2)

The Word of the Day refreshes so that each morning the user sees a new word. The app fetches the WOTD once on launch, and re-fetches if the cached word is stale (more than 23 hours old). This ensures the user sees a fresh word each day without unnecessary network requests during a session.

**Why this priority**: Important for the feature to feel "alive" and daily, but the core visual display (P1) must work first. A stale word is better than no word.

**Independent Test**: Can be tested by launching the app, noting the word, then simulating a stale timestamp (>23 hours) and relaunching. The word should change if the source has updated.

**Acceptance Scenarios**:

1. **Given** the app has never fetched a WOTD, **When** the app launches, **Then** the WOTD is fetched from the source and displayed.
2. **Given** the app was last opened less than 23 hours ago, **When** the app launches again, **Then** the previously cached WOTD is displayed without a new network request.
3. **Given** the app was last opened more than 23 hours ago, **When** the app launches, **Then** a fresh WOTD is fetched from the source.
4. **Given** the network is unavailable on launch, **When** the app tries to fetch the WOTD, **Then** the previously cached word is displayed (or a graceful empty state if no cache exists).

---

### Edge Cases

- What happens when the WOTD source is unreachable on first-ever launch? The empty state should remain clean (no error messages cluttering the UI); the WOTD area simply doesn't appear until data is available.
- What happens when the fetched word has no definition available? Display the word alone without the definition section, maintaining the quotation mark styling.
- What happens when the user has the app open across midnight? The word does not need to update mid-session; it refreshes on next launch if stale.
- What happens if the search field has text but no results were found? The WOTD should NOT appear; it only appears when the search field is empty and there are no results to show.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The desktop app MUST display the Word of the Day in the empty state (no search query, no results).
- **FR-002**: The WOTD display MUST use American Typewriter font with an opening curly double quotation mark preceding the word, matching the style of the existing iOS WOTD widget.
- **FR-003**: The WOTD display MUST include the word and its definition, separated by a horizontal divider line.
- **FR-004**: The WOTD MUST be visually centered in the results area of the main window.
- **FR-005**: The column headers (Synonym, Sounds Like, etc.) MUST be hidden when the empty state / WOTD is displayed.
- **FR-006**: The column headers MUST reappear when search results are displayed.
- **FR-007**: The app MUST fetch the WOTD once per launch, using the same source as the existing iOS widget (Merriam-Webster RSS feed for the word, definition lookup for the meaning).
- **FR-008**: The app MUST cache the fetched WOTD locally so it persists across the session.
- **FR-009**: On subsequent launches, the app MUST re-fetch the WOTD only if the cached data is older than 23 hours.
- **FR-010**: If the network is unavailable, the app MUST fall back to the most recently cached WOTD.
- **FR-011**: The WOTD display MUST transition smoothly to search results when the user begins searching, and back to WOTD when the search is cleared.

### Key Entities

- **Word of the Day**: The daily featured word including: the word itself, its definition, and a timestamp of when it was fetched. Sourced from an external daily word feed.
- **Empty State**: The application state where no search query is active and no results are displayed. This is the trigger condition for showing the WOTD.

## Assumptions

- The existing iOS widget's WOTD data-fetching logic (RSS feed parsing and definition lookup) can be reused or adapted for the desktop app.
- American Typewriter is available as a system font on macOS (it is bundled with macOS).
- The WOTD cache can be stored in-memory with a timestamp; persistence across app restarts is handled by re-fetching on launch when stale.
- The ❡ (pilcrow/lozenge) separator used in the widget for multiple definitions is acceptable for the desktop display as well.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users see a styled Word of the Day within 2 seconds of launching the app (assuming network availability).
- **SC-002**: The empty state displays zero column headers and one centered WOTD presentation.
- **SC-003**: Opening the app on consecutive mornings (>23 hours apart) shows a different word each day (matching the daily feed).
- **SC-004**: Transitioning between empty state and search results (and back) takes less than 0.5 seconds with no visual glitches.
- **SC-005**: The WOTD visual style is consistent with the existing iOS widget (same font family, quotation mark treatment, divider, and definition layout).
