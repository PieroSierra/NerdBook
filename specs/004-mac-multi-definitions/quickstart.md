# Quickstart: Mac Multiple Definitions

## Prerequisites

- Xcode 16+ (for macOS 26 / Tahoe Liquid Glass APIs, with fallback for earlier)
- macOS 15+ development target
- The project builds and runs on the `004-mac-multi-definitions` branch

## Build & Run

```bash
# Build Mac target
xcodebuild -scheme NerdBook -destination 'platform=macOS' build

# Or open in Xcode
open NerdBook.xcodeproj
# Select "NerdBook" scheme → Run (Cmd+R)
```

## Manual Testing Checklist

1. **Search a word** with multiple definitions (e.g., "run", "set", "light", "bank")
2. **Verify definition bar** appears at bottom with first definition
3. **Click the definition bar** → sheet should open
4. **Scroll horizontally** through definition cards
5. **Select text** in a card → should be copyable
6. **Dismiss the sheet** → main view should be unchanged
7. **Test Dark Mode** (System Settings → Appearance → Dark) → cards/sheet should adapt
8. **Search a word with one definition** (e.g., "quixotic") → sheet shows single card gracefully
9. **Hover over definition bar** → cursor should change to pointer

## Key Files

| File | What changes |
|------|-------------|
| `NerdBook/ContentView.swift` | Add `DefinitionsSheetView`, `MacDefinitionCard`, sheet state, clickable bar |
| `Shared/SharedData.swift` | No changes (data already available) |

## Reference: iOS Implementation

| iOS File | Mac Equivalent |
|----------|---------------|
| `NerdBookiOS/TriggerWordsView.swift` → `TriggersSheetView` | `DefinitionsSheetView` (definitions only, no trigger words) |
| `NerdBookiOS/TriggerWordsView.swift` → `DefinitionCard` | `MacDefinitionCard` (adapted for AppKit colors) |
