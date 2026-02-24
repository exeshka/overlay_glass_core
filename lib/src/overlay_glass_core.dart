import 'dart:ui' show Rect, lerpDouble;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter/widgets.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:motor/motor.dart';
part 'overlay_glass_core_controller.dart';

/// Lerps between two [LiquidGlassSettings] for morph animation.
LiquidGlassSettings lerpLiquidGlassSettings(
  LiquidGlassSettings a,
  LiquidGlassSettings b,
  double t,
) {
  return LiquidGlassSettings(
    visibility: lerpDouble(a.visibility, b.visibility, t)!,
    glassColor: Color.lerp(a.glassColor, b.glassColor, t)!,
    thickness: lerpDouble(a.thickness, b.thickness, t)!,
    blur: lerpDouble(a.blur, b.blur, t)!,
    chromaticAberration: lerpDouble(
      a.chromaticAberration,
      b.chromaticAberration,
      t,
    )!,
    lightAngle: lerpDouble(a.lightAngle, b.lightAngle, t)!,
    lightIntensity: lerpDouble(a.lightIntensity, b.lightIntensity, t)!,
    ambientStrength: lerpDouble(a.ambientStrength, b.ambientStrength, t)!,
    refractiveIndex: lerpDouble(a.refractiveIndex, b.refractiveIndex, t)!,
    saturation: lerpDouble(a.saturation, b.saturation, t)!,
  );
}

/// Computes overlay top-left from trigger: above or below so that the overlay
/// fits on screen; prefers the side that fits. [padding] from edges.
Offset _computeEndPositionFromTrigger({
  required Offset triggerOffset,
  required Size triggerSize,
  required Size overlaySize,
  required Size screenSize,
  double padding = 12,
}) {
  final pad = padding;
  final spaceAbove = triggerOffset.dy - pad;
  final spaceBelow =
      screenSize.height - pad - (triggerOffset.dy + triggerSize.height);
  final fitsBelow = overlaySize.height <= spaceBelow;
  final fitsAbove = overlaySize.height <= spaceAbove;

  double top;
  if (fitsBelow && fitsAbove) {
    final triggerInUpperHalf =
        triggerOffset.dy + triggerSize.height / 2 < screenSize.height / 2;
    if (triggerInUpperHalf) {
      top = triggerOffset.dy + triggerSize.height + pad;
    } else {
      top = triggerOffset.dy - overlaySize.height - pad;
    }
  } else if (fitsBelow) {
    top = triggerOffset.dy + triggerSize.height + pad;
  } else if (fitsAbove) {
    top = triggerOffset.dy - overlaySize.height - pad;
  } else {
    top = pad;
  }

  final minLeft = pad;
  final maxLeft = screenSize.width - overlaySize.width - pad;
  final leftRangeMin = minLeft <= maxLeft ? minLeft : maxLeft;
  final leftRangeMax = minLeft <= maxLeft ? maxLeft : minLeft;
  final left =
      (triggerOffset.dx + triggerSize.width / 2 - overlaySize.width / 2).clamp(
        leftRangeMin,
        leftRangeMax,
      );

  final minTop = pad;
  final maxTop = screenSize.height - overlaySize.height - pad;
  final topRangeMin = minTop <= maxTop ? minTop : maxTop;
  final topRangeMax = minTop <= maxTop ? maxTop : minTop;
  top = top.clamp(topRangeMin, topRangeMax);
  return Offset(left, top);
}

/// One frame of the morph: glass panel with cross-fade between [startChild] and [endChild], using [LiquidGlassSettings] directly.
class _MorphPanel extends StatelessWidget {
  const _MorphPanel({
    required this.size,
    required this.borderRadius,
    required this.progress,
    required this.startChild,
    required this.endChild,
    required this.glassSettings,
  });

  final Size size;
  final double borderRadius;
  final double progress;
  final Widget startChild;
  final Widget endChild;
  final LiquidGlassSettings glassSettings;

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    return Align(
      alignment: Alignment.topLeft,
      child: LiquidStretch(
        child: LiquidGlass.withOwnLayer(
          shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
          settings: glassSettings,
          child: GlassGlow(
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: OverflowBox(
                    maxWidth: size.width * 2,
                    maxHeight: size.height * 2,
                    minHeight: 0,
                    minWidth: 0,
                    alignment: Alignment.topLeft,
                    child: startChild,
                  ),
                ),
                Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: ClipRect(
                    child: OverflowBox(
                      maxWidth: size.width * 2,
                      maxHeight: size.height * 2,
                      minHeight: 0,
                      minWidth: 0,
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: endChild,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Callback to get current trigger rect in global coordinates. Used so overlay can follow trigger when it's in a scrollable.
typedef TriggerRectCallback = Rect? Function();

/// Overlay layer: barrier + morph animation (lerp of size, position, border radius). Uses [SingleMotionBuilder] (motor) for open/close.
/// When [getTriggerRect] is provided, overlay position is updated every frame from it so the overlay follows the trigger (e.g. when scrolling).
class _OverlayMorphLayer extends StatefulWidget {
  const _OverlayMorphLayer({
    required this.triggerOffset,
    required this.triggerSize,
    required this.triggerChild,
    required this.overlayChild,
    required this.endRect,
    this.endPosition,
    this.overlayPadding = 0,
    required this.startBorderRadius,
    required this.endBorderRadius,
    required this.startGlassSettings,
    required this.endGlassSettings,
    required this.barrierDismiss,
    required this.onClose,
    required this.onRemove,
    this.closeRequested,
    this.onOpenAnimationStarted,
    this.getTriggerRect,
    this.scheduleOverlayRebuild,
  });

  final Offset triggerOffset;
  final Size triggerSize;
  final Widget triggerChild;
  final Widget overlayChild;
  final Rect endRect;

  /// When null, end position is computed from trigger (above or below). When set, used as overlay top-left.
  final Offset? endPosition;
  final double overlayPadding;
  final double startBorderRadius;
  final double endBorderRadius;
  final LiquidGlassSettings startGlassSettings;
  final LiquidGlassSettings endGlassSettings;
  final bool barrierDismiss;
  final VoidCallback onClose;
  final VoidCallback onRemove;
  final ValueListenable<bool>? closeRequested;
  final VoidCallback? onOpenAnimationStarted;

  /// If set, called each build to get current trigger rect in global coordinates. Overlay follows this position (e.g. when trigger is in a scrollable).
  final TriggerRectCallback? getTriggerRect;

  /// When [getTriggerRect] is set, called each frame to request overlay rebuild so position can follow the trigger.
  final VoidCallback? scheduleOverlayRebuild;

  @override
  State<_OverlayMorphLayer> createState() => _OverlayMorphLayerState();
}

class _OverlayMorphLayerState extends State<_OverlayMorphLayer> {
  double _motionTarget = 1.0;
  bool _closing = false;
  final GlobalKey _overlayContentKey = GlobalKey();
  Size? _measuredOverlaySize;

  @override
  void initState() {
    super.initState();
    widget.closeRequested?.addListener(_onCloseRequested);
    WidgetsBinding.instance.addPostFrameCallback(_measureOverlayContent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onOpenAnimationStarted?.call();
    });
  }

  void _measureOverlayContent([_]) {
    final box =
        _overlayContentKey.currentContext?.findRenderObject() as RenderBox?;
    final size = box?.size;
    if (size != null && size != _measuredOverlaySize && mounted) {
      setState(() => _measuredOverlaySize = size);
    }
  }

  @override
  void dispose() {
    widget.closeRequested?.removeListener(_onCloseRequested);
    super.dispose();
  }

  void _onCloseRequested() {
    if (widget.closeRequested?.value == true) _startClose();
  }

  void _startClose() {
    if (_closing) return;
    _closing = true;
    widget.onClose();
    setState(() => _motionTarget = 0);
  }

  void _onMotionStatusChanged(AnimationStatus status) {
    // print('status: $status');
    // Motor reports .dismissed when animation reaches initial (from) value, i.e. 0 when closing
    if (_motionTarget != 0) return;
    if (status != AnimationStatus.completed &&
        status != AnimationStatus.dismissed)
      return;
    if (!mounted) return;

    widget.onRemove();
  }

  Rect _effectiveEndRect(
    Size screenSize, {
    Offset? triggerOffset,
    Size? triggerSize,
  }) {
    final offset = triggerOffset ?? widget.triggerOffset;
    final size = triggerSize ?? widget.triggerSize;
    final overlaySize = _measuredOverlaySize ?? size;
    final topLeft =
        widget.endPosition ??
        _computeEndPositionFromTrigger(
          triggerOffset: offset,
          triggerSize: size,
          overlaySize: overlaySize,
          screenSize: screenSize,
          padding: widget.overlayPadding,
        );
    return Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      overlaySize.width,
      overlaySize.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final overlayBox = context.findRenderObject() as RenderBox?;
    final origin = overlayBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    final Offset currentTriggerOffset;
    final Size currentTriggerSize;
    if (widget.getTriggerRect != null) {
      final rect = widget.getTriggerRect!();
      if (rect != null) {
        currentTriggerOffset = rect.topLeft;
        currentTriggerSize = rect.size;
      } else {
        currentTriggerOffset = widget.triggerOffset;
        currentTriggerSize = widget.triggerSize;
      }
    } else {
      currentTriggerOffset = widget.triggerOffset;
      currentTriggerSize = widget.triggerSize;
    }

    final startLocal = currentTriggerOffset - origin;
    final endRect = _effectiveEndRect(
      screenSize,
      triggerOffset: currentTriggerOffset,
      triggerSize: currentTriggerSize,
    );
    final endLocal = endRect.topLeft - origin;

    if (widget.getTriggerRect != null &&
        widget.scheduleOverlayRebuild != null &&
        mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.scheduleOverlayRebuild?.call();
      });
    }

    return Stack(
      children: [
        if (widget.barrierDismiss)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _closing,
              child: GestureDetector(
                onTap: _startClose,
                onHorizontalDragStart: (_) => _startClose(),
                onVerticalDragStart: (_) => _startClose(),
                behavior: HitTestBehavior.opaque,
              ),
            ),
          ),
        // Measure overlay content actual size from key (offstage)
        Positioned(
          left: 0,
          top: 0,
          child: Offstage(
            child: UnconstrainedBox(
              alignment: Alignment.topLeft,
              child: KeyedSubtree(
                key: _overlayContentKey,
                child: widget.overlayChild,
              ),
            ),
          ),
        ),
        SingleMotionBuilder(
          value: _motionTarget,
          from: 0,
          motion: Motion.smoothSpring(
            duration: const Duration(milliseconds: 400),
          ),

          onAnimationStatusChanged: _onMotionStatusChanged,
          builder: (context, t, _) {
            final size = Size.lerp(currentTriggerSize, endRect.size, t)!;
            final offset = Offset.lerp(startLocal, endLocal, t)!;
            // Use same curve as motion so radius stays in sync; easeInOut for smooth radius change
            final tRadius = Curves.easeInOut.transform(t);
            final radius = lerpDouble(
              widget.startBorderRadius,
              widget.endBorderRadius,
              tRadius,
            )!.clamp(0.0, 1000.0);

            final glassSettings = lerpLiquidGlassSettings(
              widget.startGlassSettings,
              widget.endGlassSettings,
              t,
            );

            final screenSize = MediaQuery.sizeOf(context);
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              width: size.width.clamp(0, screenSize.width),
              height: size.height.clamp(0, screenSize.height),
              child: IgnorePointer(
                ignoring: _closing,
                child: _MorphPanel(
                  size: size,
                  borderRadius: radius,
                  progress: t,
                  startChild: widget.triggerChild,
                  endChild: widget.overlayChild,
                  glassSettings: glassSettings,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Widget that owns the morph overlay. Takes a [controller] and a [child] (trigger).
/// All morph animation runs here. Call [OverlayGlassCoreController.showOverlay] to open;
/// overlay accepts [LiquidGlassSettings], end border radius, and optional position (auto if null).
class OverlayGlassCore extends StatefulWidget {
  const OverlayGlassCore({
    super.key,
    required this.controller,
    required this.child,
    required this.glassSettings,
  });

  final OverlayGlassCoreController controller;
  final LiquidGlassSettings glassSettings;
  final Widget child;

  @override
  State<OverlayGlassCore> createState() => _OverlayGlassCoreState();
}

class _OverlayGlassCoreState extends State<OverlayGlassCore> {
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  final ValueNotifier<bool> _closeRequested = ValueNotifier(false);
  final ValueNotifier<bool> _triggerHidden = ValueNotifier(false);
  Widget? _cachedTriggerContent;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
  }

  @override
  void didUpdateWidget(covariant OverlayGlassCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach(this);
      widget.controller._attach(this);
    }
    if (oldWidget.child != widget.child) {
      _cachedTriggerContent = null;
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    _overlayEntry?.remove();
    _closeRequested.dispose();
    _triggerHidden.dispose();
    super.dispose();
  }

  void showOverlay({
    required Widget overlay,
    required double endBorderRadius,
    required LiquidGlassSettings glassSettings,
    Offset? position,
    Size? overlaySize,
    required double startBorderRadius,
    required double padding,
    required bool barrierDismiss,
  }) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    final triggerBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final triggerOffset = triggerBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final triggerSize = triggerBox?.size ?? Size.zero;

    Rect? getTriggerRect() {
      final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return null;
      final offset = box.localToGlobal(Offset.zero);
      return Rect.fromLTWH(
        offset.dx,
        offset.dy,
        box.size.width,
        box.size.height,
      );
    }

    _closeRequested.value = false;
    _triggerHidden.value = true;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenSize = MediaQuery.sizeOf(context);
        final endRect = Rect.fromLTWH(
          0,
          0,
          screenSize.width,
          screenSize.height,
        );
        return _OverlayMorphLayer(
          triggerOffset: triggerOffset,
          triggerSize: triggerSize,
          triggerChild: widget.child,
          overlayChild: overlay,
          endRect: endRect,
          endPosition: position,
          overlayPadding: padding,
          startBorderRadius: startBorderRadius,
          endBorderRadius: endBorderRadius,
          startGlassSettings: widget.glassSettings,
          endGlassSettings: glassSettings,
          barrierDismiss: barrierDismiss,
          onClose: () {
            closeOverlay();
          },
          onRemove: () {
            _overlayEntry?.remove();
            _triggerHidden.value = false;

            _overlayEntry = null;
          },
          closeRequested: _closeRequested,
          onOpenAnimationStarted: () {},
          getTriggerRect: getTriggerRect,
          scheduleOverlayRebuild: () {
            _overlayEntry?.markNeedsBuild();
          },
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void closeOverlay() {
    _closeRequested.value = true;
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  Widget _buildTriggerContent() {
    _cachedTriggerContent ??= LiquidStretch(
      child: LiquidGlass.withOwnLayer(
        shape: LiquidRoundedSuperellipse(borderRadius: 100),
        settings: widget.glassSettings,
        child: GlassGlow(child: widget.child),
      ),
    );
    return _cachedTriggerContent!;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _triggerHidden,
      builder: (context, isHidden, child) {
        return KeyedSubtree(
          key: _triggerKey,
          child: IgnorePointer(
            ignoring: isHidden,
            child: Opacity(opacity: isHidden ? 0 : 1, child: child),
          ),
        );
      },
      child: _buildTriggerContent(),
    );
  }
}
