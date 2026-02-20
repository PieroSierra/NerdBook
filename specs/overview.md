# NerdBook Project Overview

## Executive Summary

NerdBook is a cross-platform (macOS/iOS) word lookup application that provides synonyms categorized by style (Normal, Lyrical, Pretentious), plus rhymes, sound-alikes, and related words. The project has diverged significantly between platforms—iOS has received focused development with advanced features, while the macOS app has bit-rotted and no longer compiles.

**Current Status:** Mac app broken (5 compilation errors). iOS app fully functional with advanced features.

---

## Current Build Issues (Critical)

### Mac App Compilation Errors

The macOS `NerdBook` target fails to build with **5 critical errors**:

#### 1. **Duplicate Color Extensions** (4 errors)
- **Location:** `NerdBook/ContentView.swift:5-10` and `Shared/SharedLogic.swift:14-21`
- **Issue:** Color extensions (`lightShadow`, `darkShadow`, `background`, `neumorphictextColor`) are defined in both files
- **Root Cause:** Shared code wasn't properly modularized when iOS development took precedence
- **Solution:** Remove duplicate definitions from `NerdBook/ContentView.swift`; keep only in `Shared/SharedLogic.swift`

#### 2. **Duplicate Preview Provider** (1 error)
- **Location:** `NerdBook/ContentView.swift:393` and `Shared/WaveView.swift:144`
- **Issue:** `ContentView_Previews` struct declared in both files
- **Root Cause:** WaveView.swift incorrectly has a preview provider for `ContentView`
- **Solution:** Remove or rename the preview provider in `WaveView.swift` to `WaveView_Previews`

---

## Project Structure

```
NerdBook/
├── NerdBook/                  # macOS app target (BROKEN)
│   ├── NerdBookApp.swift      # Entry point (partially implemented)
│   ├── ContentView.swift      # Main UI (has duplicates, needs fix)
│   ├── Assets.xcassets
│   └── Preview Content/
├── NerdBookiOS/               # iOS app target (WORKING)
│   ├── NerdBookiOSApp.swift   # Entry point with URL handling
│   ├── ContentView.swift      # Feature-rich main UI
│   ├── SharedData.swift       # iOS-specific wrapper
│   ├── SheetView.swift        # Definition/details sheet
│   ├── TriggerWordsView.swift # Word association view
│   └── Info.plist
├── Shared/                    # Shared code (but not fully)
│   ├── SharedData.swift       # API client (DataMuse) & models ✓
│   ├── SharedLogic.swift      # UI helpers, colors, layouts ✓
│   └── WaveView.swift         # Audio-reactive wave (for rap mode) ✓
├── WordOfTheDay/              # Widget extension
│   ├── WordOfTheDayControl.swift
│   ├── WordOfTheDayLiveActivity.swift
│   └── WordOfTheDayBundle.swift
├── Tests/
│   ├── NerdBookTests/
│   ├── NerdBookiOSTests/
│   └── UITests
└── NerdBook.xcodeproj
```

---

## Feature Parity Gap (Mac vs iOS)

### iOS Has (Mac Lacks)
1. **Multiple Definitions** – Shows all definitions for a word with toggleable view
2. **Word Clouds** – Visual "trigger words" associations (frequency-based sizing)
3. **Rap Mode** – Audio-reactive wave visualization (uses microphone)
4. **URL Scheme Handling** – `nerdbook://` and `triggerword://` deep linking
5. **Half-Sheet UI** – Definition/details overlay
6. **Segmented Controls** – Tab-like navigation between word types
7. **Frequency-based Styling** – Button sizes scale with word frequency

### Both Have
- Synonym lookup (normal/lyrical/pretentious categorization)
- Sound-alike words
- Autocomplete suggestions
- Dark mode support
- Neumorphic design system

### Mac-Only UI Elements (Outdated)
- Hardcoded 600x400 min window size
- Basic three-column layout
- Commented-out translucent window code
- Manual text field focus management

---

## Code Quality & Architecture Issues

### Shared Code Management
- **SharedLogic.swift** – Color definitions, shapes, button styles, flow layout ✓ Good
- **SharedData.swift** – DataMuse API client, Word model ✓ Good
- **WaveView.swift** – Contains iOS-specific `AudioManager` (shouldn't be in "Shared" folder)

### Duplication & Debt
- Color extensions repeated in `NerdBook/ContentView.swift` (should be deleted)
- Preview providers in multiple files causing conflicts
- Mac app has stripped-down version of iOS features (not refactored, just cut)
- iOS-specific code (AudioManager) in "Shared" folder

### Missing Shared Components
- No shared ViewModel for DataMuse state
- No platform-specific view adapters
- No shared URL scheme definitions

---

## API Dependencies

### Datamuse API
- **Endpoints Used:**
  - `/words?rel_syn={query}&md=d,s,f` – Synonyms with definitions & frequency
  - `/words?sl={query}&md=f` – Sound-alike words
  - `/words?sp={query}&md=d` – Word definitions
  - `/words?rel_trg={query}&md=f` – Related/trigger words
  - `/sug?s={input}` – Autocomplete suggestions

### Third-Party Dependencies
- **FeedKit** (via SPM) – Parses Merriam-Webster Word of the Day RSS feed
- **AVFoundation** – Audio input for wave visualization (iOS/macOS)

---

## Build & Target Configuration

### Targets
1. **NerdBook** – macOS app (BROKEN, needs fixes)
2. **NerdBookiOS** – iOS app (working)
3. **WordOfTheDay** – WidgetKit extension (iOS/macOS)
4. **NerdBookTests**, **NerdBookiOSTests**, **UITests** – Empty/minimal

### Platform Requirements
- macOS 14.6+ (Sonoma)
- iOS 17.0+ (inferred from code)
- Swift 5.0+
- SwiftUI 4.0+

---

## Performance Observations

### Potential Issues
1. **Audio Tap Processing** – `AudioManager` runs tap on every audio buffer (expensive, not throttled)
2. **Network Calls** – No request debouncing for synonym fetches (debouncing only on suggestions)
3. **UI Responsiveness** – Three parallel API calls on each search (synonyms, sounds-like, definitions)
4. **Memory Leaks** – `AudioManager` singleton never stopped, tap remains active

### Optimization Opportunities
- Batch API requests or implement caching
- Add request throttling/debouncing globally
- Profile audio processing overhead
- Implement image/result caching

---

## Gaps & TODO Items

### Immediate (Critical)
1. ✅ Fix Mac app compilation (remove duplicates)
2. ✅ Clean up shared code module structure
3. ✅ Ensure Mac app compiles and runs

### Short Term (Feature Parity)
1. Port iOS definitions UI to Mac
2. Add word cloud/trigger words to Mac
3. Implement URL scheme handling for Mac
4. Add segmented control navigation

### Medium Term (Polish)
1. Implement liquidGlass effect (mentioned in objectives)
2. Add "Tip Jar" IAP (from Softburn project)
3. Build out unit tests
4. Profile and optimize network/audio performance

### Long Term (Architecture)
1. Refactor to MVVM pattern with shared ViewModels
2. Implement proper dependency injection
3. Add error handling UI (currently just silent failures)
4. Create platform-specific adapters for code reuse

---

## Recommended Approach

### Phase 1: Stabilize (1-2 hours)
1. Fix the 5 compilation errors
   - Remove duplicate Color extensions from Mac's ContentView
   - Fix ContentView_Previews conflict
2. Verify Mac app runs and basic search works
3. Commit: "Fix Mac app compilation"

### Phase 2: Refactor Shared Code (2-3 hours)
1. Audit target membership in Xcode (which files build for which targets)
2. Move iOS-only code (AudioManager, WaveView) to iOS target
3. Create clean separation: `Shared` = truly cross-platform
4. Create `MacApp` and `iOSApp` folders for platform-specific UI
5. Commit: "Refactor shared code architecture"

### Phase 3: Feature Parity (4-6 hours)
1. Port definitions display to Mac (from iOS SheetView)
2. Port trigger words/word cloud (uses existing code)
3. Add Mac's deep linking support
4. Update Mac UI to match iOS design system
5. Commit: "Add feature parity with iOS"

### Phase 4: Polish (2-4 hours)
1. Implement liquidGlass effect on both platforms
2. Add IAP tip jar infrastructure
3. Optimize audio/network performance
4. Commit: "Add liquidGlass effect and IAP"

---

## Key Files to Know

| File | Purpose | Status |
|------|---------|--------|
| `Shared/SharedData.swift` | DataMuse API client | ✓ Well-designed, reusable |
| `Shared/SharedLogic.swift` | UI components & colors | ⚠️ Works but needs isolation |
| `NerdBook/ContentView.swift` | Mac main view | ❌ Has duplicates, needs cleanup |
| `NerdBookiOS/ContentView.swift` | iOS main view | ✓ Feature-rich, good pattern |
| `Shared/WaveView.swift` | Wave visualization | ⚠️ iOS-only, shouldn't be "Shared" |
| `WordOfTheDay/*.swift` | Widget code | ✓ Independent, uses shared APIs |

---

## Questions for User

1. **Tip Jar**: When should this be added? (Phase 1? After Mac is stable?)
2. **liquidGlass Effect**: Specific implementation style in mind? (Metal shaders? SwiftUI blur layers?)
3. **Priority**: Mac stability > feature parity > polish, correct?
4. **Timeline**: Any hard deadlines or preferred iteration speed?
