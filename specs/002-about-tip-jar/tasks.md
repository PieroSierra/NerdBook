# Tasks: Add About Box with Tip Jar

**Input**: Design documents from `/specs/002-about-tip-jar/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story. Both user stories (US1 and US2) are P1 priority and can be implemented together since they share the same AboutView component.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Project Reference & Review)

**Purpose**: Review SoftBurn reference implementation to understand proven patterns

- [x] T001 Review SoftBurn AboutView implementation in SoftBurn project to understand modal dialog pattern, layout (icon 200x200, window 640x400), and HStack structure
- [x] T002 Review SoftBurn TipJarSection implementation to understand IAP tier display pattern (Espresso, Latte, Venti) and coffee imagery layout
- [x] T003 Review SoftBurn TipJarManager implementation to understand StoreKit 2 IAP flow, product fetching, purchase handling, and error management
- [x] T004 Verify NerdBook project builds successfully on macOS 14.6+ before making modifications

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create core IAP manager that both user stories depend on

**⚠️ CRITICAL**: TipJarManager must be complete before any UI components can be implemented

- [x] T005 Create TipJarManager.swift in NerdBook/ with StoreKit 2 imports, Product fetching, purchase handling, and state management (@Published properties)

---

## Phase 3: User Story 1 - View Application Information (Priority: P1) 🎯 MVP

**Goal**: Display About dialog with app information when info button is clicked

**Independent Test**: Click info "i" button in toolbar and verify About dialog appears with correct app name, version, copyright, and description

### Implementation for User Story 1

- [x] T006 [P] [US1] Create AboutView.swift in NerdBook/ with modal dialog structure: 640x400 window, 200x200 app icon, HStack layout (icon left, text right), displaying app name "NerdBook", version info, copyright text, and description from NerdBookiOS About Sheet
- [x] T007 [P] [US1] Create TipJarSection.swift in NerdBook/ with UI for three IAP tiers: display Espresso, Latte, Venti options with coffee_large images, tier names, prices (fetched from TipJarManager), and purchase buttons (initially disabled until TipJarManager integration)
- [x] T008 [US1] Modify ContentView.swift to add @State var showAboutDialog: Bool = false at the top of the view
- [x] T009 [US1] Update ContentView.swift info button action in toolbar to set showAboutDialog = true
- [x] T010 [US1] Add .sheet(isPresented: $showAboutDialog) { AboutView(...) } modifier to ContentView to present AboutView as modal
- [ ] T011 [US1] Build and verify About dialog displays correctly when info button is clicked, shows all required information, and closes properly when dismissed
- [ ] T012 [US1] Test on macOS 14.6 (Sonoma) and macOS 26 (Tahoe) to verify dialog compatibility

**Checkpoint**: User Story 1 (View App Information) is complete and independently testable

---

## Phase 4: User Story 2 - Support Developer via Tip Jar (Priority: P1)

**Goal**: Enable in-app purchases through TipJarSection with user confirmation and thank-you feedback

**Independent Test**: Click each tip tier in the About dialog (Espresso, Latte, Venti), complete purchase flow, and verify thank-you alert appears; attempt failed purchase to verify error handling

### Implementation for User Story 2

- [x] T013 [P] [US2] Wire TipJarManager to TipJarSection in AboutView: pass @StateObject var tipJarManager to TipJarSection and display fetched product prices
- [x] T014 [P] [US2] Implement purchase button actions in TipJarSection: connect each tip tier button to TipJarManager.purchase(product:) method
- [x] T015 [US2] Add purchase state management to AboutView: track isPurchasing state and show loading indicator while purchase is in progress
- [x] T016 [US2] Implement success alert in TipJarSection: show "Thank you! Your support means a lot ❤️" alert after successful purchase completion
- [x] T017 [US2] Implement error alert in TipJarSection: show error message alert if purchase fails with appropriate user-facing description
- [x] T018 [US2] Add App Store availability check in TipJarManager: gracefully handle case where App Store is unavailable and show appropriate error to user
- [ ] T019 [US2] Build and test Tip Jar IAP flow: initiate purchase on each tier, verify purchase dialog appears, confirm thank-you alert on success
- [ ] T020 [US2] Test error scenarios: cancel in-progress purchase, verify App Store unavailable handling, test network error recovery

**Checkpoint**: User Story 2 (Tip Jar IAP) is complete and independently testable

---

## Phase 5: Integration & Cleanup

**Purpose**: Remove deprecated UI elements and ensure cohesive integration

- [x] T021 [P] Remove Datamuse link from ContentView.swift bottom toolbar (lines with "Powered by https://www.datamuse.com/") since About dialog now contains all attribution information
- [x] T022 [P] Verify Datamuse and other attribution links are accessible from About dialog via Acknowledgements button or description text in AboutView.swift
- [ ] T023 Perform full end-to-end test: launch app → click info button → view About dialog → view Tip Jar section → cancel or complete purchase → dismiss dialog → verify main UI functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Verification, documentation, and final validation

- [ ] T024 [P] Verify code follows NerdBook project style conventions (SwiftUI patterns, property organization, naming consistency)
- [ ] T024 [P] Build for macOS 14.6 (Sonoma), macOS 15 (Sequoia), macOS 26 (Tahoe) to ensure backward compatibility
- [ ] T025 Validate against plan.md quickstart guide: each of 6 steps (1. Review SoftBurn → 2. AboutView → 3. TipJarSection → 4. TipJarManager → 5. ContentView → 6. Build & Test) is complete and verified
- [ ] T026 Update project documentation if needed to reflect removal of Datamuse toolbar link and addition of About dialog feature
- [ ] T027 Confirm all feature specification success criteria met: dialog displays within 200ms, all tiers purchasable, 100% of About info correct, coffee imagery displays correctly, alerts appear immediately

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately (reference review tasks)
- **Foundational (Phase 2)**: Depends on Setup completion - TipJarManager MUST be complete before UI work (BLOCKS Phase 3 & 4)
- **User Story 1 (Phase 3)**: Depends on Foundational completion - AboutView and TipJarSection UI scaffolding (no IAP wiring yet)
- **User Story 2 (Phase 4)**: Depends on Phase 3 AND Foundational (TipJarManager) - IAP wiring and purchase flow
- **Integration (Phase 5)**: Depends on Phase 3 & 4 completion
- **Polish (Phase 6)**: Depends on all previous phases

### Within Each User Story

- Phase 1: Reference review for understanding patterns
- Phase 2: TipJarManager (foundational, required by both stories)
- Phase 3: AboutView creation, TipJarSection UI scaffolding, ContentView integration → **Story 1 independent and testable**
- Phase 4: TipJarManager wiring, IAP flow, alerts, error handling → **Story 2 independent and testable**
- Phase 5: Remove Datamuse link, verify integration
- Phase 6: Final validation and documentation

### Parallel Opportunities

**Within Phase 1 (Setup)**:
- All review tasks [P] can run in parallel (independent reference documents)

**Within Phase 3 (User Story 1)**:
- T006 (AboutView creation) and T007 (TipJarSection UI) can run in parallel [P] (different files, no dependencies)
- T008-T012 must run sequentially (ContentView modifications depend on created components)

**Within Phase 4 (User Story 2)**:
- T013 (TipJarManager wiring) and T014 (purchase buttons) can run in parallel [P] (both wiring concerns)
- T015-T020 follow sequentially (state management → success/error handling → testing)

**Independent User Stories**:
- Once Foundational (Phase 2) is complete, Phase 3 and Phase 4 CAN theoretically run in parallel by different developers
- However, they share AboutView container, so T008-T010 (ContentView) should complete before Phase 4 proceeds

---

## Parallel Example: User Story 1

```bash
# After Phase 2 (TipJarManager) is complete, launch User Story 1 components:
Task: "Create AboutView.swift" [T006]
Task: "Create TipJarSection.swift" [T007]

# These can run simultaneously (different files, both use TipJarManager from Phase 2)
# Then sequence ContentView integration (T008-T010)
# Then build and test (T011-T012)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only - About Dialog)

1. Complete Phase 1: Setup (reference review)
2. Complete Phase 2: Foundational (TipJarManager creation)
3. Complete Phase 3: User Story 1 (About dialog with app info)
4. **STOP and VALIDATE**: Verify About dialog displays correctly when "i" button clicked
5. Deploy/demo About information if ready

### Incremental Delivery: Add IAP After Dialog Works

6. Complete Phase 4: User Story 2 (Tip Jar IAP purchases)
7. **VALIDATE**: Verify IAP purchase flow works end-to-end
8. Complete Phase 5: Integration cleanup (remove Datamuse link)
9. Complete Phase 6: Polish and final validation
10. **SHIP**: Both stories complete and working together

### Suggested Approach for This Feature

**Since both stories are P1 and tightly integrated**:
- Implement Phase 1-2-3 together to get About dialog working
- Then immediately add Phase 4 (IAP) since TipJarSection already exists
- Phase 5-6 are final cleanup and validation
- **Total dependency chain**: Setup → TipJarManager → AboutView/TipJarSection → IAP wiring → cleanup

---

## Notes

- [P] tasks = different files, no sequential dependencies
- [Story] label (US1, US2) maps task to specific user story for traceability
- Each user story should be independently completable and testable at checkpoints
- TipJarManager (Phase 2) is the critical path blocking all UI work
- AboutView can display without Tip Jar IAP working (Phase 3 is independent)
- Tip Jar IAP adds value to Phase 3 (Phase 4 depends on Phase 3 existing)
- Commit after each task or logical group (e.g., after T005, T007, T010, T020, etc.)
- Stop at Phase 3 checkpoint to demo About dialog before adding IAP complexity
- Test on multiple macOS versions (Sonoma, Sequoia, Tahoe) to catch compatibility issues
