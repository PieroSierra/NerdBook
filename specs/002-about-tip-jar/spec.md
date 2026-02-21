# Feature Specification: Add About Box with Tip Jar

**Feature Branch**: `002-about-tip-jar`
**Created**: 2026-02-20
**Status**: Draft
**Input**: User description: "Let's add an About box with a Tip Jar... We have new "i" button in the upper-right corner, that should bring up an About Box. For the about box design, please copy the About box from /SoftBurn/... same design and layout, but (1) for the text content, use the content in the NerdBookiOS About Sheet. You can take out the little toolbar at the bottom of the MacOS app that links to Datamuse (since that will be linked to from About). (2) the new About box contains iAPs for tips at 3 levels (espresso, latte, venti)... Let's copy the whole concept -- NerdBook will also have those same 3 IAPs wired in the same way. To get ready for this, I have added the image assets (coffee_large etc) already."

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - View Application Information (Priority: P1)

**Mac user** clicks the info "i" icon in the toolbar and sees a modal About dialog displaying application details: name, version, copyright, and description. The dialog has a professional design matching the app's aesthetic.

**Why this priority**: Users expect to find About information accessible and clear. This is the primary entry point for the feature.

**Independent Test**: Can be fully tested by clicking the "i" button and verifying the About dialog appears with correct app information. Delivers app context without requiring IAP functionality.

**Acceptance Scenarios**:

1. **Given** the app is running, **When** user clicks the info "i" icon in the toolbar, **Then** an About dialog appears centered on screen
2. **Given** the About dialog is open, **When** user observes the dialog, **Then** it displays: app name "NerdBook", version/build info, copyright text, and app description
3. **Given** the About dialog is open, **When** user clicks outside the dialog or closes it, **Then** the dialog dismisses gracefully

---

### User Story 2 - Support Developer via Tip Jar (Priority: P1)

**Mac user** wants to support the app developer and sees three In-App Purchase (IAP) tip options (Espresso, Latte, Venti) with corresponding coffee imagery. User can select a tip level, complete the purchase, and receive a thank-you confirmation.

**Why this priority**: IAP tip jars are a proven monetization and user appreciation mechanism. Users who want to support developers need a frictionless way to do so.

**Independent Test**: Can be fully tested by attempting a tip purchase at each tier level and verifying the purchase flow completes with thank-you feedback. Independently testable from About information display.

**Acceptance Scenarios**:

1. **Given** the About dialog is open, **When** user sees the Tip Jar section, **Then** three coffee-themed tip options are displayed (Espresso, Latte, Venti) with corresponding images
2. **Given** a tip option is visible, **When** user clicks a tip level, **Then** the system initiates the IAP purchase flow for that tier
3. **Given** a purchase completes successfully, **When** the purchase dialog closes, **Then** user sees a "Thank you!" confirmation message
4. **Given** a purchase fails, **When** an error occurs, **Then** user sees an error alert with a descriptive message

### Edge Cases

- What happens if the App Store is unavailable? System should show appropriate error message and allow user to dismiss gracefully.
- What if user cancels an in-progress tip purchase? Dialog should close and return to normal About view without side effects.
- What if user clicks the "i" button while the About dialog is already open? Dialog should remain open (no duplicate dialogs).
- What if the app has no version number in Info.plist? System should display "Version —" as fallback.

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: System MUST display an About dialog when user clicks the info "i" button in the toolbar
- **FR-002**: About dialog MUST show application name, version/build information, copyright notice, and app description
- **FR-003**: About dialog MUST display the app icon (from bundle/Assets)
- **FR-004**: About dialog MUST be modal (prevent interaction with main window while open)
- **FR-005**: About dialog MUST match the visual design and layout of SoftBurn's About window (200x200 icon, 640x400 window size, left-aligned layout with icon on left, text on right)
- **FR-006**: About dialog MUST include a Tip Jar section with three IAP options: Espresso, Latte, Venti
- **FR-007**: Each tip option MUST display the corresponding coffee image (coffee_large asset for each tier)
- **FR-008**: User MUST be able to tap a tip tier to initiate purchase via in-app purchase system
- **FR-009**: System MUST show "Thank you! Your support means a lot ❤️" alert on successful purchase
- **FR-010**: System MUST show error alert with message on failed purchase
- **FR-011**: System MUST use NerdBookiOS About Sheet content for the app description (Finding synonyms text, DataMuse credit, Merriam-Webster credit, copyright attribution)
- **FR-012**: Mac app bottom toolbar link to Datamuse MUST be removed (moved to About dialog)
- **FR-013**: About dialog MUST have an "Acknowledgements" button to show credits/attribution (if desired by user)

### Key Entities

- **About Dialog**: Modal window displaying app information and IAP tip jar
- **Tip Jar Manager**: System managing IAP purchases for three coffee-themed tiers
- **In-App Purchase (IAP)**: Transaction system for monetizing tip tiers
- **App Bundle Information**: Version, build, name, copyright from Info.plist
- **Coffee Images**: Visual assets for Espresso, Latte, Venti tiers

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: About dialog displays within 200ms of clicking "i" button (instant user perception)
- **SC-002**: All three tip tiers successfully purchasable via App Store IAP system
- **SC-003**: 100% of About information (name, version, copyright, description) displays correctly and matches app metadata
- **SC-004**: Dialog remains visible until user closes it or successfully completes purchase
- **SC-005**: Dialog can be dismissed at any time without side effects or corrupted state
- **SC-006**: Coffee imagery displays correctly for all three tip tiers (Espresso, Latte, Venti)
- **SC-007**: Thank-you and error alerts appear immediately after purchase flow completes or fails
- **SC-008**: App no longer shows Datamuse link in bottom toolbar (removed as planned)

## Assumptions

- **SoftBurn design is authoritative**: The About window in SoftBurn (640x400, icon+text layout, TipJarSection) serves as the design reference
- **Image assets provided**: User has added coffee_large and related images to Assets.xcassets
- **IAP infrastructure exists**: App is already set up for in-app purchases with the three coffee-tier products
- **Same tip JAR concept applies**: Espresso, Latte, Venti tiers and pricing strategy from SoftBurn applies to NerdBook
- **Modal dialog preferred**: About window should be modal (blocking main window interaction) based on SoftBurn pattern
- **Thank you message format**: "Thank you! Your support means a lot ❤️" matches SoftBurn user experience

## Dependencies

- **External**: SoftBurn project (design reference for AboutView, AboutWindowController, TipJarSection)
- **External**: App Store IAP system (for processing tip purchases)
- **Internal**: NerdBook app Info.plist (for version, build, app name, copyright info)
- **Internal**: NerdBookiOS ContentView (for About Sheet content text to port)
- **Internal**: Image assets (coffee_large, coffee_latte, coffee_venti - already added)

## Out of Scope

- IAP product setup in App Store Connect (assumed pre-configured)
- Detailed IAP receipt validation or purchase history tracking
- Dark mode specific styling (use system colors)
- Localization of tip descriptions
- Analytics/telemetry for purchase tracking
