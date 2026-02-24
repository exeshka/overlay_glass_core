part of 'overlay_glass_core.dart';

/// Controller for [OverlayGlassCore]. Only way to show the overlay is [showOverlay].
class OverlayGlassCoreController {
  _OverlayGlassCoreState? _host;

  void _attach(_OverlayGlassCoreState host) {
    _host = host;
  }

  void _detach(_OverlayGlassCoreState host) {
    if (_host == host) _host = null;
  }

  /// Shows the overlay with morph animation from the trigger to the given content.
  ///
  /// [overlay] — widget shown inside the glass panel after the morph.
  /// [endBorderRadius] — corner radius at the end of the morph (target panel look).
  /// [glassSettings] — direct [LiquidGlassSettings] for the glass effect; if null, defaults are used.
  /// [position] — top-left of the overlay in global coordinates; if null, position is computed automatically (e.g. below trigger, clamped to screen).
  /// [overlaySize] — size of the overlay panel; required when [position] is null for auto-positioning; can be omitted when [position] is set (then a default or measured size is used).
  void showOverlay(
    Widget overlay, {
    required double endBorderRadius,
    LiquidGlassSettings? glassSettings,
    Offset? position,
    Size? overlaySize,
    double startBorderRadius = 1000,
    double padding = 12,
    bool barrierDismiss = true,
  }) {
    _host?.showOverlay(
      overlay: overlay,
      endBorderRadius: endBorderRadius,
      glassSettings: glassSettings ?? const LiquidGlassSettings(),
      position: position,
      overlaySize: overlaySize,
      startBorderRadius: startBorderRadius,
      padding: padding,
      barrierDismiss: barrierDismiss,
    );
  }

  /// Closes the current overlay (starts close animation, then removes the overlay entry).
  void close() {
    _host?.closeOverlay();
  }
}
