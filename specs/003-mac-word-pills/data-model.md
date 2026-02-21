# Data Model: Mac Word Pills

**Branch**: `003-mac-word-pills` | **Date**: 2026-02-21

## Overview

This feature introduces no new data models, no new entities, and no storage changes. It is a pure UI rendering change.

## Existing Entities Used (Unchanged)

### `Word` (from `Shared/SharedData.swift`)

The existing `Word` model is consumed unchanged by the pill buttons.

| Field | Type | Usage |
|-------|------|-------|
| `word` | `String` | Displayed as the pill label; used as the tap action query |
| `defs` | `[String]?` | Not used on Mac (no per-pill definitions) |
| `frequency` | `Double?` | Not used on Mac (no frequency-based sizing for synonym pills) |

### `DataMuse` (from `Shared/SharedData.swift`)

Observable object providing synonym arrays. Consumed unchanged.

| Property | Type | Usage |
|----------|------|-------|
| `synonyms` | `[Word]` | Normal column pills |
| `lyricalSynonyms` | `[Word]` | Poetic column pills |
| `pretentiousSynonyms` | `[Word]` | Nerdy column pills |

## View-Local State Changes

The Mac `ContentView` gains no new `@State` variables. `ColorButton` manages its own animation state (`@State private var scale` and `@State private var isPressed`) internally.

## Component: `ColorButton` (modified)

The `ColorButton` struct in `SharedLogic.swift` is modified to become cross-platform. Its interface is unchanged:

```
ColorButton(
    text: String,
    fontSize: CGFloat,
    colorScheme: ColorScheme,
    action: () -> Void,
    onAnimationComplete: () -> Void    // no-op on Mac
)
```

Internal change: the `.background(...)` fill switches between `Color(UIColor.systemBackground)` (iOS) and `Color(NSColor.windowBackgroundColor)` (macOS) via platform conditional compilation.
