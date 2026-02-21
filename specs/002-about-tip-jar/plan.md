# Implementation Plan: Add About Box with Tip Jar

**Branch**: `002-about-tip-jar` | **Date**: 2026-02-20 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-about-tip-jar/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Add an About dialog modal to the NerdBook Mac app that launches from the info "i" icon in the toolbar. The dialog displays app information (name, version, copyright, description) using NerdBookiOS content, and includes a Tip Jar section with three IAP tiers (Espresso, Latte, Venti) matching the SoftBurn implementation. The design reuses SoftBurn's proven AboutView pattern with TipJarSection for IAP integration.

## Technical Context

**Language/Version**: Swift 5.9 (Xcode 15+)
**Primary Dependencies**: SwiftUI, AppKit (macOS frameworks), StoreKit 2 (in-app purchases)
**Storage**: N/A (no persistent storage; IAP handled by App Store)
**Testing**: XCTest (UI testing for dialog, IAP purchase flow testing)
**Target Platform**: macOS 14.6 (Sonoma) → macOS 26 (Tahoe) with Liquid Glass
**Project Type**: macOS desktop app (multi-target: NerdBook Mac + iOS + Widget)
**Performance Goals**: Dialog displays within 200ms, IAP purchase flow seamless
**Constraints**: Must maintain Liquid Glass toolbar integration; IAP must use existing App Store setup
**Scale/Scope**: Single modal window; 3 fixed IAP tiers; 640x400 dialog size

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

✓ **No constitution file exists** - Standard SwiftUI/AppKit patterns apply:
- ✓ Single responsibility: About dialog + Tip Jar IAP (isolated feature)
- ✓ No architectural violations: Reuses SoftBurn proven pattern
- ✓ No new dependencies: Uses only standard Apple frameworks
- ✓ Backward compatible: Works on macOS 14.6+ (graceful IAP handling on older systems)
- ✓ Modal dialog appropriate: Follows macOS UI conventions

**GATE PASSES** - Ready for Phase 0 research

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
NerdBook.xcodeproj/
├── NerdBook/                 # macOS app target (PRIMARY MODIFICATIONS)
│   ├── NerdBookApp.swift         # Wire info button action (already done)
│   ├── ContentView.swift         # Keep info button (already done)
│   ├── AboutView.swift           # NEW - Modal dialog view (copy SoftBurn pattern)
│   ├── TipJarSection.swift       # NEW - IAP section view (copy SoftBurn pattern)
│   ├── TipJarManager.swift       # NEW - IAP manager (copy SoftBurn pattern)
│   └── Assets.xcassets/
│       └── coffee_large.imageset # Already added by user
│
├── NerdBookiOS/              # iOS app target (NO CHANGES)
│   └── ContentView.swift
│
└── Shared/                   # Shared code (optional: share TipJarManager if needed)
    └── TipJarManager.swift   # Could be extracted to Shared
```

**Structure Decision**: Xcode project with multi-target structure. Modifications isolated to NerdBook (Mac) target. Will copy AboutView and TipJarSection directly from SoftBurn as reference implementation. TipJarManager can be copied with minor adaptations for NerdBook IAP product IDs.

## Complexity Tracking

No violations detected - feature uses proven SoftBurn patterns.

---

## Phase 0: Research & Resolution

### All Clarifications Resolved

✓ **Design Reference**: SoftBurn AboutView is authoritative
  - Decision: Copy AboutView.swift structure (icon 200x200, window 640x400, HStack layout)
  - Rationale: Proven production design; same aesthetic for consistency
  - Alternatives considered: Custom design (rejected - SoftBurn already proven)

✓ **Content Source**: NerdBookiOS About Sheet is authoritative
  - Decision: Use exact text from NerdBookiOS About Sheet (Finding synonyms description, credits, copyright)
  - Rationale: Already tested, consistent across platforms
  - Alternatives considered: Write new content (rejected - reuse proven content)

✓ **IAP Implementation**: Copy SoftBurn TipJarManager pattern
  - Decision: Use TipJarManager.swift with Espresso/Latte/Venti structure, adapt product IDs for NerdBook
  - Rationale: Proven IAP flow, tested error handling, alerts
  - Alternatives considered: Build custom IAP flow (rejected - unnecessary complexity)

✓ **Modal Dialog**: Use SwiftUI @State + .sheet() or similar pattern
  - Decision: Use standard SwiftUI presentation for modal (matches ContentView info button already in place)
  - Rationale: Standard macOS pattern; integrates with existing toolbar info button
  - Alternatives considered: WindowGroup/Scene-level (rejected - overkill for single dialog)

✓ **Toolbar Integration**: Info button already wired in previous feature
  - Decision: Connect info button to trigger About dialog presentation
  - Rationale: Info button created in 001-mac-window-cleanup; button is ready
  - Alternatives considered: New button (rejected - info button already designed for this)

### Research Output

**No NEEDS CLARIFICATION markers remain.** All decisions documented with rationale.

---

## Phase 1: Design & Contracts

### 1. Data Model

**About Dialog State**
```
@State var showAboutDialog: Bool = false
```
- Managed by ContentView
- Set to true when info button tapped
- Set to false when dialog dismissed or IAP completes

**Tip Jar Manager**
```
class TipJarManager: ObservableObject {
  @Published var products: [Product] = []
  @Published var isPurchasing: Bool = false

  enum TipTier {
    case espresso    // Low tier
    case latte       // Medium tier
    case venti       // High tier
  }
}
```
- Manages StoreKit 2 IAP transactions
- Observes purchase state changes
- Handles error states

### 2. UI Component Contracts

**AboutView Contract**
```
Input:  ContentView state with showAboutDialog: Bool
Output: Modal dialog displaying:
  - App icon (NSApp.applicationIconImage, 200x200)
  - App name "NerdBook"
  - Version/build info
  - Copyright text
  - About description
  - TipJarSection component
  - Acknowledgements button (optional)

Dialog size: 640x400 pixels
Modal behavior: Blocks main window interaction
Dismiss: User closes dialog or purchase completes
```

**TipJarSection Contract**
```
Input:  TipJarManager instance
Output: Displays 3 coffee-themed IAP options:
  - Espresso (coffee_large image)
  - Latte (coffee_large image)
  - Venti (coffee_large image)

Each tier shows:
  - Coffee image
  - Tier name
  - Price
  - Purchase button

On purchase:
  - Show thank-you alert on success
  - Show error alert on failure
```

**TipJarManager Contract**
```
Input:  Product ID strings for three tiers (Espresso, Latte, Venti)
Output:
  - Fetch available products from App Store
  - Handle purchase requests
  - Emit success/error signals
  - Manage purchase state

Integration:
  - Uses StoreKit 2 APIs
  - Handles App Store communication
  - Error handling with user-facing messages
```

### 3. Implementation Files

**File 1: NerdBook/AboutView.swift** (NEW)
- Copy structure from SoftBurn/Views/About/AboutView.swift
- Adapt:
  - Property: `let onAcknowledgements: () -> Void` → optional callback
  - Content: Replace SoftBurn text with NerdBook content from spec
  - Products: Use NerdBook IAP product IDs
- Size: ~100-120 lines (following SoftBurn pattern)

**File 2: NerdBook/TipJarSection.swift** (NEW)
- Copy from SoftBurn/Views/About/TipJarSection.swift
- Adapt: Product IDs for NerdBook IAP tiers
- Size: ~80-100 lines (following SoftBurn pattern)

**File 3: NerdBook/TipJarManager.swift** (NEW)
- Copy from SoftBurn/ViewModels/TipJarManager.swift
- Adapt:
  - Product ID strings: Use NerdBook IAP product IDs (from App Store Connect)
  - Error messages: Keep as-is (generic)
- Size: ~150-200 lines (following SoftBurn pattern)

**File 4: NerdBook/ContentView.swift** (MODIFY)
- Add @State var showAboutDialog: Bool = false
- Update info button action to: `showAboutDialog = true`
- Add .sheet(isPresented: $showAboutDialog) { AboutView(...) }
- Changes: ~5-10 lines added

### 4. Quickstart

**Step 1**: Copy SoftBurn files as reference
- Read SoftBurn/Views/About/AboutView.swift
- Read SoftBurn/Views/About/TipJarSection.swift
- Read SoftBurn/ViewModels/TipJarManager.swift

**Step 2**: Create AboutView.swift in NerdBook
- Structure: Copy SoftBurn pattern
- Content: Update with NerdBook description (from spec)
- Images: Use coffee_large assets (already added)

**Step 3**: Create TipJarSection.swift in NerdBook
- Structure: Copy SoftBurn pattern
- Product IDs: Update to NerdBook IAP identifiers

**Step 4**: Create TipJarManager.swift in NerdBook
- Structure: Copy SoftBurn pattern
- Product IDs: Map to NerdBook tiers (Espresso, Latte, Venti)

**Step 5**: Update ContentView.swift
- Add showAboutDialog @State
- Wire info button to show dialog
- Add .sheet() modifier for AboutView

**Step 6**: Build & Test
- Build for macOS 14.6+ and Tahoe
- Click info button → About dialog appears
- Dialog displays correctly with all content
- Tip Jar section shows 3 coffee options

### 5. Artifact Output

✓ **research.md** - All decisions documented (above)
✓ **data-model.md** - Not needed (no persistent data model)
✓ **contracts/** - Component contracts documented (above)
✓ **quickstart.md** - Developer guide generated (above)

---

## Next Phase

**Phase 2 (Tasks)** will be generated by `/speckit.tasks` command and will create:
- **tasks.md**: Actionable, ordered task list with dependencies
- Each task will map to implementation steps above
- Task dependencies: AboutView → TipJarSection → TipJarManager → ContentView integration
