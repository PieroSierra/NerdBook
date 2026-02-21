# Quickstart: Mac Word Pills

**Branch**: `003-mac-word-pills` | **Date**: 2026-02-21

## What This Feature Does

Replaces plain colored text synonyms in the Mac app's three columns (Normal, Poetic, Nerdy) with pill-shaped buttons that match the iOS style: a rounded rectangle with a pink↔blue gradient border and a staggered bounce entrance animation.

## Files to Change

| File | Change |
|------|--------|
| `Shared/SharedLogic.swift` | Make `ColorButton` cross-platform |
| `NerdBook/ContentView.swift` | Use `ColorButton` in three synonym ForEach loops |

## Change 1: `Shared/SharedLogic.swift`

Find the `#if os(iOS)` block starting around line 186. Currently it wraps `ColorButtonViewModel`, `ColorButton`, and `FrequencyURLButton` all together.

**Split the block** so that only `ColorButtonViewModel` and `FrequencyURLButton` stay inside `#if os(iOS)`, and `ColorButton` is moved outside.

Inside the `ColorButton` body, find the `.background(...)` modifier on `RoundedRectangle`:
```swift
.background(
    RoundedRectangle(cornerRadius: 10)
        .fill(Color(UIColor.systemBackground))
)
```

Replace the fill with a platform conditional:
```swift
.background(
    RoundedRectangle(cornerRadius: 10)
        .fill(
            #if os(iOS)
            Color(UIColor.systemBackground)
            #else
            Color(NSColor.windowBackgroundColor)
            #endif
        )
)
```

## Change 2: `NerdBook/ContentView.swift`

In the three ForEach loops (Normal ~line 62, Poetic ~line 88, Nerdy ~line 114), replace the current `Text + onTapGesture` pattern with `ColorButton`.

**Current (each column, example Normal):**
```swift
ForEach(dataMuse.synonyms, id: \.word) { synonym in
    Text(synonym.word)
        .font(.body)
        .foregroundColor(colorScheme == .dark ? Color.pinkColor : .blue)
        .lineLimit(1)
        .truncationMode(.tail)
        .fixedSize(horizontal: true, vertical: false)
        .onTapGesture {
            isUserSelecting = true
            query = synonym.word
            dataMuse.fetchSynonyms(query: query)
        }
}
```

**After (each column):**
```swift
ForEach(dataMuse.synonyms, id: \.word) { synonym in
    ColorButton(
        text: synonym.word,
        fontSize: 16,
        colorScheme: colorScheme,
        action: {
            isUserSelecting = true
            query = synonym.word
            dataMuse.fetchSynonyms(query: query)
        },
        onAnimationComplete: {}
    )
    .padding(.top, 2)
}
```

Repeat for `lyricalSynonyms` and `pretentiousSynonyms`. The action body is identical for all three — only the data source (`dataMuse.synonyms` / `dataMuse.lyricalSynonyms` / `dataMuse.pretentiousSynonyms`) differs.

You may also want to adjust the inner `VStack` spacing from 5 to 8 to give pills a bit more breathing room.

## Verification Checklist

- [ ] Build for macOS target — no compile errors
- [ ] Build for iOS target — no compile errors (iOS behavior unchanged)
- [ ] Search a word → all three columns show pill-shaped buttons
- [ ] Pill borders use pink→blue gradient in dark mode, blue→pink in light mode
- [ ] Pills bounce in with staggered timing on first appearance
- [ ] Searching a new word re-triggers the bounce animation
- [ ] Clicking a pill searches for that word
- [ ] No definition text appears next to any pill
- [ ] Bottom glass definition bar still works correctly
