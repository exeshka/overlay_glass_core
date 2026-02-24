import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:overlay_glass_core/overlay_glass_core.dart';

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
        ),
        startBorderRadius: 34,
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
          ],
        ),
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
      ),
      startBorderRadius: 34,
      glassSettings: const LiquidGlassSettings(blur: 24, lightAngle: 12),
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
      ),
      startBorderRadius: 34,
      glassSettings: const LiquidGlassSettings(blur: 24, lightAngle: 12),
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
