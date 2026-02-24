# overlay_glass_core

Morph animation from a trigger widget into a glass overlay panel (liquid glass). You provide the trigger and overlay content — the package handles only the animation and glass effect.

![Demo](https://github.com/exeshka/overlay_glass_core/raw/main/assets/record.gif)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  overlay_glass_core: ^0.0.1
  liquid_glass_renderer: ^0.2.0-dev.4
```

Then run:

```bash
flutter pub get
```

## Simple example

```dart
import 'package:flutter/material.dart';
import 'package:overlay_glass_core/overlay_glass_core.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _controller = OverlayGlassCoreController();

  void _openMenu() {
    _controller.showOverlay(
      Container(
        width: 280,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Item 1')),
            ListTile(title: Text('Item 2')),
          ],
        ),
      ),
      endBorderRadius: 24,
      glassSettings: LiquidGlassSettings(blur: 24),
      barrierDismiss: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: OverlayGlassCore(
              controller: _controller,
              glassSettings: LiquidGlassSettings(blur: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openMenu,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text('Open menu'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

Tapping the button opens the overlay with a morph from the trigger area; tapping the dimmed barrier closes the menu.

### Variant: Navigator + Hero

Same glass look, but the “overlay” is a **route** and the transition uses **Hero**. Use when you want the panel to live in the Navigator stack (e.g. for back button or deep linking).

1. Wrap only your **content** in [GlassCoreHeroTrigger] with a `heroTag`; glass is applied outside with `startGlassSettings` / `startBorderRadius`.
2. Push the panel with [pushGlassCoreRoute] using the same `heroTag`. Pass matching `startGlassSettings` / `startBorderRadius` so the flight can lerp from start to end glass.

```dart
import 'package:overlay_glass_core/overlay_glass_core.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

// Trigger: Hero wraps only content; glass uses start* for the flight
GlassCoreHeroTrigger(
  heroTag: 'menu',
  startGlassSettings: LiquidGlassSettings(blur: 20),
  startBorderRadius: 34,
  child: InkWell(
    onTap: () => pushGlassCoreRoute(
      context,
      heroTag: 'menu',
      child: YourMenuContent(),
      startGlassSettings: LiquidGlassSettings(blur: 20),
      startBorderRadius: 34,
      glassSettings: LiquidGlassSettings(blur: 24),
      borderRadius: 34,
      barrierDismiss: true,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add),
          SizedBox(width: 8),
          Text('Open menu'),
        ],
      ),
    ),
  ),
)
```

During the flight, the naked content is wrapped in glass and animated (lerp from start to end); tap outside or pop the route to close.

## What this package does (and doesn’t)

**Animation and glass only:**

- Morph: the overlay panel expands from the trigger area with your content inside.
- Glass effect over the content (via `liquid_glass_renderer`).
- Overlay position is computed automatically (above or below the trigger, with padding from screen edges).

**No layout or UI:**

- The trigger’s look is entirely your widget passed as `child` of `OverlayGlassCore`.
- The menu’s look is entirely your widget passed as `overlay` in `showOverlay()`.
- The package does not provide lists, menu items, spacing, etc. — only the animation and glass shell.

## Known issues

- **Trigger inside a scroll.** If the trigger widget is inside scrollable content (e.g. `ListView`, `CustomScrollView`), you may see noticeable **flicker** when opening or closing the overlay. The overlay follows the trigger on scroll and morphs back to it on close; the end of the close animation can look jumpy. Prefer placing the trigger outside the scroll (e.g. in `SafeArea` at the top or bottom of the screen), or account for this in your design.

## More

A full example with multiple overlays and buttons is in the `example/` folder.
