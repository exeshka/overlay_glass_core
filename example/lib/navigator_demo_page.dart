import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:overlay_glass_core/overlay_glass_core.dart';
import 'package:screen_corner_radius/screen_corner_radius.dart';

/// Demo page for the Navigator + Hero variant: trigger opens a glass panel
/// as a route (pushGlassCoreRoute) with Hero transition.
class NavigatorDemoPage extends StatefulWidget {
  const NavigatorDemoPage({super.key});

  @override
  State<NavigatorDemoPage> createState() => _NavigatorDemoPageState();
}

class _NavigatorDemoPageState extends State<NavigatorDemoPage> {
  static const String _heroTag = 'navigator_glass_menu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    CupertinoIcons.back,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Navigator + Hero',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildTrigger(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Text(
                    'Tap the glass button. Panel position follows trigger (scroll to see).',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrigger(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: GlassCoreHeroTrigger(
        heroTag: _heroTag,
        startGlassSettings: const LiquidGlassSettings(
          blur: 22,
          lightAngle: 18,
          lightIntensity: 0.35,
          glassColor: Colors.black,
        ),
        startBorderRadius: 34,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _openMenu(context),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(CupertinoIcons.square_arrow_down),
                ),
              ),
              GestureDetector(
                onTap: () => _openMenu2(context),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(CupertinoIcons.square_arrow_down),
                ),
              ),
              GestureDetector(
                onTap: () => openModalSheet(context),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(CupertinoIcons.money_dollar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openModalSheet(BuildContext context) async {
    final ScreenRadius? screenRadius = await ScreenCornerRadius.get();

    if (screenRadius == null) {
      return;
    }

    final size = MediaQuery.sizeOf(context);
    const collapsedHeight = 280.0;
    const collapsedPadding = 8.0;
    final initialRect = Rect.fromLTWH(
      collapsedPadding,
      size.height - collapsedHeight - collapsedPadding,
      size.width - 2 * collapsedPadding,
      collapsedHeight,
    );
    final panelRectNotifier = ValueNotifier<Rect?>(initialRect);
    const collapsedGlass = LiquidGlassSettings(
      blur: 22,
      lightAngle: 18,
      lightIntensity: 0.35,
      glassColor: Colors.black,
    );
    const expandedGlass = LiquidGlassSettings(
      blur: 24,
      lightAngle: 0,
      lightIntensity: 0,
      glassColor: Colors.red,
      chromaticAberration: 0,
    );
    final glassSettingsNotifier = ValueNotifier<LiquidGlassSettings>(
      collapsedGlass,
    );

    pushGlassCoreRoute(
      context,
      heroTag: _heroTag,
      startGlassSettings: collapsedGlass,
      startBorderRadius: 34,
      glassSettings: collapsedGlass,
      panelRectNotifier: panelRectNotifier,
      glassSettingsNotifier: glassSettingsNotifier,
      positionPadding: 0,
      borderRadius: screenRadius.bottomLeft - 8,
      barrierDismiss: true,
      child: _DraggableModalSheetContent(
        panelRectNotifier: panelRectNotifier,
        glassSettingsNotifier: glassSettingsNotifier,
        startGlassSettings: collapsedGlass,
        endGlassSettings: expandedGlass,
        borderRadius: screenRadius.bottomLeft - 8,
      ),
    );
  }

  void _openMenu2(BuildContext context) {
    pushGlassCoreRoute(
      context,
      heroTag: _heroTag,
      startGlassSettings: const LiquidGlassSettings(
        blur: 22,
        lightAngle: 18,
        lightIntensity: 0.35,
        glassColor: Colors.black,
      ),
      startBorderRadius: 34,
      glassSettings: const LiquidGlassSettings(
        blur: 24,
        lightAngle: 12,
        glassColor: Colors.black,
      ),
      barrierDismiss: true,
      child: _buildSettingsOverlay(),
    );
  }

  Widget _buildSettingsOverlay() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 178,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _menuItem(icon: CupertinoIcons.person, label: 'Account'),
            _menuItem(icon: CupertinoIcons.bell, label: 'Notifications'),
            _menuItem(icon: CupertinoIcons.lock, label: 'Privacy'),
            _menuItem(icon: CupertinoIcons.arrow_2_circlepath, label: 'Sync'),
            _menuItem(icon: CupertinoIcons.question_circle, label: 'Help'),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    String? subtitle,
    Color? labelColor,
    VoidCallback? onTap,
  }) {
    final color = labelColor ?? Colors.white.withOpacity(0.9);
    final iconColor = labelColor ?? Colors.white.withOpacity(0.7);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.43,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    pushGlassCoreRoute(
      context,
      heroTag: _heroTag,
      startGlassSettings: const LiquidGlassSettings(
        blur: 22,
        lightAngle: 18,
        lightIntensity: 0.35,
        glassColor: Colors.black,
      ),
      startBorderRadius: 34,
      glassSettings: const LiquidGlassSettings(
        blur: 24,
        lightAngle: 12,
        glassColor: Colors.blue,
      ),
      barrierDismiss: true,

      child: _buildMenuContent(),
    );
  }

  Widget _buildMenuContent() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _menuHeader(),
          _menuDivider(),
          _navMenuItem(CupertinoIcons.search, 'Find in Note'),
          _navMenuItem(CupertinoIcons.folder, 'Move Note'),
          _navMenuItem(CupertinoIcons.clock, 'Recent Notes'),
          _navMenuItem(CupertinoIcons.gear, 'Settings'),
          _navMenuItem(
            CupertinoIcons.delete,
            'Delete',
            labelColor: const Color(0xFFFF3B30),
          ),
        ],
      ),
    );
  }

  Widget _menuHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Menu (route)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This panel is a Navigator route with Hero.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1, color: Colors.white.withOpacity(0.12)),
    );
  }

  Widget _navMenuItem(IconData icon, String label, {Color? labelColor}) {
    final color = labelColor ?? Colors.white.withOpacity(0.9);
    final iconColor = labelColor ?? Colors.white.withOpacity(0.7);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1B2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
            Color(0xFF0A0E27),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      ),
    );
  }
}

/// Модалка в примере: тянем вверх — панель роута растёт, отступы и стекло плавно меняются.
/// [panelRectNotifier] и [glassSettingsNotifier] обновляются при драге.
class _DraggableModalSheetContent extends StatefulWidget {
  const _DraggableModalSheetContent({
    required this.panelRectNotifier,
    required this.glassSettingsNotifier,
    required this.startGlassSettings,
    required this.endGlassSettings,
    required this.borderRadius,
  });

  final ValueNotifier<Rect?> panelRectNotifier;
  final ValueNotifier<LiquidGlassSettings> glassSettingsNotifier;
  final LiquidGlassSettings startGlassSettings;
  final LiquidGlassSettings endGlassSettings;
  final double borderRadius;

  @override
  State<_DraggableModalSheetContent> createState() =>
      _DraggableModalSheetContentState();
}

class _DraggableModalSheetContentState
    extends State<_DraggableModalSheetContent>
    with SingleTickerProviderStateMixin {
  static const double _collapsedHeight = 280;
  static const double _collapsedPadding = 8;

  double _expansion = 0.0;
  late AnimationController _snapController;
  double _snapStart = 0;
  double _snapTarget = 0;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _snapController.addListener(() {
      if (_snapController.isAnimating) setState(() {});
    });
    _snapController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _expansion = _snapTarget;
        _snapController.reset();
      }
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  double get _effectiveExpansion {
    if (_snapController.isAnimating) {
      final t = Curves.easeOutCubic.transform(_snapController.value);
      return _snapStart + t * (_snapTarget - _snapStart);
    }
    return _expansion;
  }

  void _snapTo(double target) {
    _snapStart = _expansion;
    _snapTarget = target;
    _snapController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screenHeight = size.height;
    final exp = _effectiveExpansion;

    final height = _collapsedHeight + exp * (screenHeight - _collapsedHeight);
    final horizontalPadding = _collapsedPadding * (1 - exp);
    final bottomPadding = _collapsedPadding * (1 - exp);
    final rect = Rect.fromLTWH(
      horizontalPadding,
      screenHeight - height - bottomPadding,
      size.width - 2 * horizontalPadding,
      height,
    );
    final glass = lerpLiquidGlassSettings(
      widget.startGlassSettings,
      widget.endGlassSettings,
      exp,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.panelRectNotifier.value != rect) {
        widget.panelRectNotifier.value = rect;
      }
      widget.glassSettingsNotifier.value = glass;
    });

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (_snapController.isAnimating) return;
        setState(() {
          _expansion -= details.delta.dy / screenHeight;
          _expansion = _expansion.clamp(0.0, 1.0);
        });
      },
      onVerticalDragEnd: (details) {
        if (_snapController.isAnimating) return;
        final threshold = 0.5;
        final target = _expansion >= threshold ? 1.0 : 0.0;
        _snapTo(target);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Явная высота вместо Expanded — нет overflow в shuttle Hero.
          final maxH = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : _collapsedHeight;
          final contentHeight = (maxH - 12 - 4 - 12).clamp(
            0.0,
            double.infinity,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: contentHeight,
                child: Center(
                  child: Text(
                    'Потяни вверх — панель растёт, отступы → 0',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
