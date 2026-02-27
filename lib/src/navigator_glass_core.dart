import 'dart:ui' show lerpDouble, ImageFilter;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:motor/motor.dart';

/// Wraps only [child] in a [Hero]; glass is applied outside with [startGlassSettings].
/// Use the same [heroTag] and matching [startGlassSettings] / [startBorderRadius]
/// when calling [pushGlassCoreRoute] so the shuttle can lerp from start to end glass.
///
/// Usage:
/// ```dart
/// GlassCoreHeroTrigger(
///   heroTag: 'menu',
///   startGlassSettings: LiquidGlassSettings(blur: 20),
///   startBorderRadius: 34,
///   child: YourButton(),
/// )
/// // On tap: pushGlassCoreRoute(context, heroTag: 'menu', child: MenuContent(),
/// //   startGlassSettings: ..., startBorderRadius: 34,
/// //   glassSettings: ..., borderRadius: 34);
/// ```
///
/// Trigger rect is resolved by [heroTag]; you don't need to pass [getTriggerRect]
/// unless you want a custom source. For position to follow trigger on scroll,
/// pass [scheduleRouteRebuild] from [pushGlassCoreRoute].
class GlassCoreHeroTrigger extends StatefulWidget {
  const GlassCoreHeroTrigger({
    super.key,
    required this.heroTag,
    required this.child,
    this.startGlassSettings = const LiquidGlassSettings(),
    this.startBorderRadius = 100,
  });

  final Object heroTag;
  final Widget child;
  final LiquidGlassSettings startGlassSettings;
  final double startBorderRadius;

  @override
  State<GlassCoreHeroTrigger> createState() => _GlassCoreHeroTriggerState();
}

class _GlassCoreHeroTriggerState extends State<GlassCoreHeroTrigger> {
  late final GlobalKey _triggerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _GlassCoreHeroTriggerRegistry._register(widget.heroTag, _triggerKey);
  }

  @override
  void dispose() {
    _GlassCoreHeroTriggerRegistry._unregister(widget.heroTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      key: _triggerKey,
      tag: widget.heroTag,
      transitionOnUserGestures: true,
      child: _GlassWrapper(
        borderRadius: widget.startBorderRadius,
        glassSettings: widget.startGlassSettings,
        child: GlassHeroContent(child: widget.child),
      ),
    );
  }
}

/// По [heroTag] возвращает rect триггера (для авто-позиции без getTriggerRect от пользователя).
class _GlassCoreHeroTriggerRegistry {
  static final Map<Object, GlobalKey> _keys = {};

  static void _register(Object tag, GlobalKey key) {
    _keys[tag] = key;
  }

  static void _unregister(Object tag) {
    _keys.remove(tag);
  }

  static Rect? rectFor(Object tag) {
    final key = _keys[tag];
    if (key == null) return null;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return Rect.fromLTWH(
      0,
      0,
      box.size.width,
      box.size.height,
    ).shift(box.localToGlobal(Offset.zero));
  }
}

/// Marker around the actual content so the shuttle can extract it from Hero → glass.
/// Use the same key on trigger and route if you need to match a specific content widget.
class GlassHeroContent extends StatelessWidget {
  const GlassHeroContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// From Hero.child (glass or marker), returns the inner content for the shuttle.
Widget _extractGlassHeroContent(Widget heroChild) {
  if (heroChild is _GlassWrapper) {
    final inner = heroChild.child;
    if (inner is GlassHeroContent) return inner.child;
    return inner;
  }
  if (heroChild is GlassHeroContent) return heroChild.child;
  return heroChild;
}

/// Wraps [child] in LiquidStretch → LiquidGlass → GlassGlow.
class _GlassWrapper extends StatelessWidget {
  const _GlassWrapper({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.glassSettings,
  });

  final Widget child;
  final double borderRadius;
  final LiquidGlassSettings glassSettings;

  @override
  Widget build(BuildContext context) {
    return LiquidStretch(
      child: LiquidGlass.withOwnLayer(
        shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
        settings: glassSettings,
        child: GlassGlow(
          child: Material(color: Colors.transparent, child: child),
        ),
      ),
    );
  }
}

/// Вычисляет top-left панели от триггера: выше или ниже, чтобы влезало в экран.
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

LiquidGlassSettings _lerpGlassSettings(
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

/// Текущий t анимации Hero flight (0..1). Обновляется маршрутом каждый кадр,
/// т.к. анимация в [flightShuttleBuilder] в ряде случаев не тикает (Flutter #53523).
final ValueNotifier<double> _glassHeroFlightT = ValueNotifier(0.0);

/// Pushes a full-screen route that shows [child] inside a glass panel.
/// The transition uses [Hero]: the source must be a [GlassCoreHeroTrigger]
/// (or any [Hero] with the same [heroTag]) on the previous route.
///
/// [startGlassSettings] / [startBorderRadius] — must match the trigger so the
/// flight can lerp from start to end. Omit to use [glassSettings]/[borderRadius] for both.
/// [barrierDismiss] — tap outside the panel to pop (default true).
/// [position] — top-left of the opened panel. If null, computed from [triggerOffset]/[triggerSize]
/// (like overlay) or default padding from top-left.
/// [triggerOffset], [triggerSize] — when [position] is null, used to compute panel position
/// (above/below trigger, centered horizontally). [positionPadding] — padding from screen edges (default 12).
/// [getTriggerRect] — when set, position is recomputed on every rebuild (e.g. when trigger moves on scroll).
/// [scheduleRouteRebuild] — call with a callback; when that callback is invoked, the route rebuilds and reads [getTriggerRect] again.
/// [panelRectNotifier] — when set, panel position and size are taken from [ValueListenable.value] on each
/// rebuild; route subscribes and rebuilds when the notifier changes. Use to resize/reposition the panel on the fly (e.g. drag-to-expand).
/// [glassSettingsNotifier] — when set, panel glass is taken from [ValueListenable.value]; use to animate glass on the fly (e.g. with panel resize).
Future<T?> pushGlassCoreRoute<T>(
  BuildContext context, {
  required Object heroTag,
  required Widget child,
  LiquidGlassSettings glassSettings = const LiquidGlassSettings(blur: 24),
  double borderRadius = 34,
  LiquidGlassSettings? startGlassSettings,
  double? startBorderRadius,
  Curve flightCurve = Curves.easeInOutCubic,
  Motion? flightMotion,
  bool barrierDismiss = true,
  bool fullScreen = true,
  Offset? position,
  Offset? triggerOffset,
  Size? triggerSize,
  Rect? Function()? getTriggerRect,
  void Function(void Function() markNeedsBuild)? scheduleRouteRebuild,
  ValueListenable<Rect?>? panelRectNotifier,
  ValueListenable<LiquidGlassSettings>? glassSettingsNotifier,
  double positionPadding = 12,
}) {
  final startGlass = startGlassSettings ?? glassSettings;
  final startRadius = startBorderRadius ?? borderRadius;
  final motion = flightMotion ?? CupertinoMotion.smooth();
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      maintainState: true,
      transitionDuration: const Duration(milliseconds: 550),
      reverseTransitionDuration: const Duration(milliseconds: 550),
      // transitionDuration: const Duration(milliseconds: 2000),
      // reverseTransitionDuration: const Duration(milliseconds: 2000),
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: flightCurve,
              reverseCurve: flightCurve,
            );

            return _GlassCoreRoutePage<T>(
              heroTag: heroTag,
              position: position,
              triggerOffset: triggerOffset,
              triggerSize: triggerSize,
              getTriggerRect: getTriggerRect,
              scheduleRouteRebuild: scheduleRouteRebuild,
              panelRectNotifier: panelRectNotifier,
              glassSettingsNotifier: glassSettingsNotifier,
              positionPadding: positionPadding,
              startGlassSettings: startGlass,
              startBorderRadius: startRadius,
              endGlassSettings: glassSettings,
              endBorderRadius: borderRadius,
              flightCurve: flightCurve,
              flightMotion: motion,
              barrierDismiss: barrierDismiss,
              fullScreen: fullScreen,
              routeAnimation: curved,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
      // transitionsBuilder:
      //     (
      //       BuildContext context,
      //       Animation<double> animation,
      //       Animation<double> secondaryAnimation,
      //       Widget child,
      //     ) {
      //       // Явно перестраиваем каждый кадр — иначе анимация тикает только 0 и 1.
      //       return SingleMotionBuilder(
      //         value: animation.value,
      //         motion: CupertinoMotion.bouncy(),
      //         builder: (context, value, child) {
      //           return child!;
      //         },
      //         child: child,
      //       );
      //     },
    ),
  );
}

class _GlassCoreRoutePage<T> extends StatefulWidget {
  const _GlassCoreRoutePage({
    required this.heroTag,
    required this.position,
    this.triggerOffset,
    this.triggerSize,
    this.getTriggerRect,
    this.scheduleRouteRebuild,
    this.panelRectNotifier,
    this.glassSettingsNotifier,
    this.positionPadding = 12,
    required this.startGlassSettings,
    required this.startBorderRadius,
    required this.endGlassSettings,
    required this.endBorderRadius,
    required this.flightCurve,
    required this.flightMotion,
    required this.barrierDismiss,
    required this.fullScreen,
    required this.routeAnimation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Object heroTag;
  final Offset? position;
  final Offset? triggerOffset;
  final Size? triggerSize;
  final Rect? Function()? getTriggerRect;
  final void Function(void Function() markNeedsBuild)? scheduleRouteRebuild;
  final ValueListenable<Rect?>? panelRectNotifier;
  final ValueListenable<LiquidGlassSettings>? glassSettingsNotifier;
  final double positionPadding;
  final LiquidGlassSettings startGlassSettings;
  final double startBorderRadius;
  final LiquidGlassSettings endGlassSettings;
  final double endBorderRadius;
  final Curve flightCurve;
  final Motion flightMotion;
  final bool barrierDismiss;
  final bool fullScreen;
  final Animation<double> routeAnimation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  State<_GlassCoreRoutePage<T>> createState() => _GlassCoreRoutePageState<T>();
}

class _GlassCoreRoutePageState<T> extends State<_GlassCoreRoutePage<T>> {
  final GlobalKey _panelKey = GlobalKey();
  Size? _panelSize;

  VoidCallback? _panelRectListener;

  @override
  void initState() {
    super.initState();
    if (widget.scheduleRouteRebuild != null) {
      widget.scheduleRouteRebuild!(() {
        if (mounted) setState(() {});
      });
    }
    final notifier = widget.panelRectNotifier;
    if (notifier != null) {
      _panelRectListener = () {
        if (mounted) setState(() {});
      };
      notifier.addListener(_panelRectListener!);
    }
    final glassNotifier = widget.glassSettingsNotifier;
    if (glassNotifier != null) {
      _glassSettingsListener = () {
        if (mounted) setState(() {});
      };
      glassNotifier.addListener(_glassSettingsListener!);
    }
  }

  VoidCallback? _glassSettingsListener;

  @override
  void dispose() {
    if (_panelRectListener != null) {
      widget.panelRectNotifier?.removeListener(_panelRectListener!);
    }
    if (_glassSettingsListener != null) {
      widget.glassSettingsNotifier?.removeListener(_glassSettingsListener!);
    }
    super.dispose();
  }

  void _measurePanel() {
    final box = _panelKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize && mounted) {
      final size = box.size;
      if (_panelSize != size) setState(() => _panelSize = size);
    }
  }

  /// Якорь: переданная [position], [panelRectNotifier].value или rect триггера (GlassCoreHeroTrigger).
  /// По размеру открытой панели определяем, куда её разместить.
  Offset _effectivePosition(BuildContext context) {
    final panelRect = widget.panelRectNotifier?.value;
    if (panelRect != null) return panelRect.topLeft;
    if (widget.position != null) return widget.position!;

    final screenSize = MediaQuery.sizeOf(context);
    final pad = widget.positionPadding;

    final Offset triggerOffset;
    final Size triggerSize;
    Rect? rect = widget.getTriggerRect?.call();
    if (rect == null) {
      rect = _GlassCoreHeroTriggerRegistry.rectFor(widget.heroTag);
    }
    if (rect != null) {
      triggerOffset = rect.topLeft;
      triggerSize = rect.size;
    } else if (widget.triggerOffset != null && widget.triggerSize != null) {
      triggerOffset = widget.triggerOffset!;
      triggerSize = widget.triggerSize!;
    } else {
      return Offset(pad, pad + 56);
    }

    final overlaySize =
        _panelSize ??
        Size(
          screenSize.width - 2 * pad,
          (screenSize.height * 0.6).clamp(100.0, screenSize.height - 2 * pad),
        );

    return _computeEndPositionFromTrigger(
      triggerOffset: triggerOffset,
      triggerSize: triggerSize,
      overlaySize: overlaySize,
      screenSize: screenSize,
      padding: pad,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePosition = _effectivePosition(context);
    final dynamicRect = widget.panelRectNotifier?.value;
    WidgetsBinding.instance.addPostFrameCallback((_) => _measurePanel());
    final hero = Hero(
      tag: widget.heroTag,
      transitionOnUserGestures: true,
      createRectTween: (begin, end) =>
          _CurvedRectTween(begin: begin, end: end, curve: widget.flightCurve),

      flightShuttleBuilder:
          (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            final fromContent = _extractGlassHeroContent(
              (fromHeroContext.widget as Hero).child,
            );
            final toContent = _extractGlassHeroContent(
              (toHeroContext.widget as Hero).child,
            );
            final isPush = flightDirection == HeroFlightDirection.push;
            return ValueListenableBuilder(
              valueListenable: animation,
              builder: (BuildContext context, double value, Widget? _) {
                final t = value.clamp(0.0, 1.0);
                // Incoming content (e.g. modal) visible earlier: opacity ~1 by ~40% of flight.
                final toOpacityCurve = Curves.easeOut.transform(t);
                final fromOpacity = (1 - t).clamp(0.0, 1.0);
                final toOpacity = toOpacityCurve.clamp(0.0, 1.0);
                final radius =
                    widget.startBorderRadius +
                    (widget.endBorderRadius - widget.startBorderRadius) * t;
                final glassSettings = _lerpGlassSettings(
                  widget.startGlassSettings,
                  widget.endGlassSettings,
                  t,
                );
                final incomingScale = lerpDouble(2.94, 1.0, t)!;
                final outgoingScale = lerpDouble(1.0, 2.94, t)!;
                final toScale = isPush ? incomingScale : outgoingScale;
                final fromScale = isPush ? outgoingScale : incomingScale;
                final blurContentFrom = !isPush
                    ? lerpDouble(50, 0, t)!
                    : lerpDouble(0, 50, t)!;
                final blurContentTo = isPush
                    ? lerpDouble(50, 0, t)!
                    : lerpDouble(0, 50, t)!;

                final shuttleSize = MediaQuery.sizeOf(context);
                return _ShuttleWithMeasuredContent(
                  shuttleSize: shuttleSize,
                  toContent: toContent,
                  fromContent: fromContent,
                  isPush: isPush,
                  toOpacity: toOpacity,
                  fromOpacity: fromOpacity,
                  toScale: toScale,
                  fromScale: fromScale,
                  blurContentTo: blurContentTo,
                  blurContentFrom: blurContentFrom,
                  glassSettings: glassSettings,
                  radius: radius,
                  endBorderRadius: widget.endBorderRadius,
                );
              },
            );
          },
      child: _GlassWrapper(
        key: _panelKey,
        borderRadius: widget.endBorderRadius,
        glassSettings:
            widget.glassSettingsNotifier?.value ?? widget.endGlassSettings,
        child: GlassHeroContent(
          child: Material(color: Colors.transparent, child: widget.child),
        ),
      ),
    );
    final positionedChild = dynamicRect != null
        ? SizedBox(
            width: dynamicRect.width,
            height: dynamicRect.height,
            child: hero,
          )
        : hero;
    return _GlassHeroFlightTSync(
      routeAnimation: widget.routeAnimation,
      child: Stack(
        children: [
          if (widget.barrierDismiss)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
              ),
            ),
          Positioned(
            top: effectivePosition.dy,
            left: effectivePosition.dx,
            child: positionedChild,
          ),
        ],
      ),
    );
  }
}

/// Синхронизирует [routeAnimation] в [_glassHeroFlightT] каждый кадр,
/// чтобы shuttle мог плавно анимироваться (обход Flutter #53523).
/// Обновление в listener, не в build(), чтобы не вызывать markNeedsBuild во время build.
class _GlassHeroFlightTSync extends StatefulWidget {
  const _GlassHeroFlightTSync({
    required this.routeAnimation,
    required this.child,
  });

  final Animation<double> routeAnimation;
  final Widget child;

  @override
  State<_GlassHeroFlightTSync> createState() => _GlassHeroFlightTSyncState();
}

class _GlassHeroFlightTSyncState extends State<_GlassHeroFlightTSync> {
  void _onTick() {
    _glassHeroFlightT.value = widget.routeAnimation.value.clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    widget.routeAnimation.addListener(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onTick());
  }

  @override
  void didUpdateWidget(covariant _GlassHeroFlightTSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeAnimation != widget.routeAnimation) {
      oldWidget.routeAnimation.removeListener(_onTick);
      widget.routeAnimation.addListener(_onTick);
      WidgetsBinding.instance.addPostFrameCallback((_) => _onTick());
    }
  }

  @override
  void dispose() {
    widget.routeAnimation.removeListener(_onTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Rect tween that applies a curve to the Hero's flight bounds
/// (so изменение размеров/позиции между первым и вторым виджетом — нелинейное).
class _CurvedRectTween extends RectTween {
  _CurvedRectTween({super.begin, super.end, required this.curve});

  final Curve curve;

  @override
  Rect? lerp(double t) => super.lerp(curve.transform(t));
}

/// Shuttle с измерением реального размера toContent/fromContent после layout.
class _ShuttleWithMeasuredContent extends StatefulWidget {
  const _ShuttleWithMeasuredContent({
    required this.shuttleSize,
    required this.toContent,
    required this.fromContent,
    required this.isPush,
    required this.toOpacity,
    required this.fromOpacity,
    required this.toScale,
    required this.fromScale,
    required this.blurContentTo,
    required this.blurContentFrom,
    required this.glassSettings,
    required this.radius,
    required this.endBorderRadius,
  });

  final Size shuttleSize;
  final Widget toContent;
  final Widget fromContent;
  final bool isPush;
  final double toOpacity;
  final double fromOpacity;
  final double toScale;
  final double fromScale;
  final double blurContentTo;
  final double blurContentFrom;
  final LiquidGlassSettings glassSettings;
  final double radius;
  final double endBorderRadius;

  @override
  State<_ShuttleWithMeasuredContent> createState() =>
      _ShuttleWithMeasuredContentState();
}

class _ShuttleWithMeasuredContentState
    extends State<_ShuttleWithMeasuredContent> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _GlassWrapper(
        borderRadius: widget.endBorderRadius,
        glassSettings: widget.glassSettings,
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.all(
            Radius.elliptical(widget.radius, widget.radius),
          ),
          child: IgnorePointer(
            ignoring: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    fit: StackFit.loose,
                    children: [
                      Positioned(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: widget.blurContentTo,
                            sigmaY: widget.blurContentTo,
                          ),
                          child: Opacity(
                            opacity: widget.isPush
                                ? widget.toOpacity
                                : widget.fromOpacity,
                            child: Transform.scale(
                              alignment: Alignment.center,
                              scale: widget.toScale,
                              child: OverflowBox(
                                maxWidth: double.infinity,
                                maxHeight: double.infinity,
                                minHeight: 0,
                                minWidth: 0,
                                child: widget.toContent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: widget.blurContentFrom,
                            sigmaY: widget.blurContentFrom,
                          ),
                          child: Opacity(
                            opacity: widget.isPush
                                ? widget.fromOpacity
                                : widget.toOpacity,
                            child: Transform.scale(
                              alignment: Alignment.topLeft,
                              scale: widget.fromScale,
                              child: SizedBox(
                                child: OverflowBox(
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity,
                                  minHeight: 0,
                                  minWidth: 0,
                                  child: widget.fromContent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Измеряет размер [child] после layout и передаёт в [onSize] (в post-frame, чтобы можно было setState).
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onSize, required super.child});

  final void Function(Size) onSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onSize: onSize);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onSize = onSize;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize({void Function(Size)? onSize}) : _onSize = onSize;

  void Function(Size)? _onSize;
  set onSize(void Function(Size)? value) {
    if (_onSize != value) _onSize = value;
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child!.layout(constraints, parentUsesSize: true);
    size = child!.size;
    final measuredSize = size;
    final callback = _onSize;
    if (callback != null) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => callback(measuredSize),
      );
    }
  }
}
