import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'package:overlay_glass_core/overlay_glass_core.dart';

import 'navigator_demo_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final OverlayGlassCoreController _menuController =
      OverlayGlassCoreController();
  final OverlayGlassCoreController _topController =
      OverlayGlassCoreController();

  static const double _kMenuWidth = 280;

  void _showMenu(OverlayGlassCoreController controller, Widget overlay) {
    controller.showOverlay(
      overlay,
      endBorderRadius: 34,
      glassSettings: const LiquidGlassSettings(blur: 24, lightAngle: 12),
    );
  }

  Widget _buildCreateOverlay() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _kMenuWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _createHeader(),
            _divider(),
            _quickActions(),
            _divider(),
            _menuItem(icon: CupertinoIcons.search, label: 'Find in Note'),
            _menuItem(icon: CupertinoIcons.folder, label: 'Move Note'),
            _menuItem(icon: CupertinoIcons.clock, label: 'Recent Notes'),
            _menuItem(icon: CupertinoIcons.number, label: 'Math Results'),
            _menuItem(
              icon: CupertinoIcons.square_grid_3x2,
              label: 'Lines and Grids',
            ),
            _menuItem(
              icon: CupertinoIcons.doc_on_doc,
              label: 'Attachment View',
            ),
            _menuItem(
              icon: CupertinoIcons.delete,
              label: 'Delete',
              labelColor: const Color(0xFFFF3B30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOverlay(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _kMenuWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'More',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
            ),
            _divider(),
            _menuItem(
              icon: CupertinoIcons.arrow_up_arrow_down,
              label: 'Sort by Date',
            ),
            _menuItem(
              icon: CupertinoIcons.square_grid_2x2,
              label: 'View as Grid',
            ),
            _menuItem(
              icon: CupertinoIcons.folder_badge_plus,
              label: 'Manage Folders',
            ),
            _menuItem(icon: CupertinoIcons.gear, label: 'Settings'),
            _menuItem(icon: CupertinoIcons.question_circle, label: 'Help'),
            _menuItem(
              icon: CupertinoIcons.rectangle_stack,
              label: 'Navigator + Hero demo',
              onTap: () {
                _topController.close();
                _menuController.close();
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const NavigatorDemoPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOverlay() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _kMenuWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Share',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
            ),
            _divider(),
            _menuItem(icon: CupertinoIcons.share, label: 'Share Note'),
            _menuItem(icon: CupertinoIcons.arrow_up_doc, label: 'Export PDF'),
            _menuItem(icon: CupertinoIcons.mail, label: 'Send by Email'),
            _menuItem(icon: CupertinoIcons.link, label: 'Copy Link'),
          ],
        ),
      ),
    );
  }

  Widget _buildNewOverlay() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _kMenuWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _menuItem(icon: CupertinoIcons.doc_plaintext, label: 'New Note'),
            _menuItem(icon: CupertinoIcons.folder, label: 'New Folder'),
            _menuItem(icon: CupertinoIcons.viewfinder, label: 'Scan Document'),
            _menuItem(icon: CupertinoIcons.camera, label: 'Take Photo'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _kMenuWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Search',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
            ),
            _divider(),
            _menuItem(icon: CupertinoIcons.doc_text, label: 'In this note'),
            _menuItem(icon: CupertinoIcons.clock, label: 'Recent searches'),
            _menuItem(icon: CupertinoIcons.tag, label: 'By tag'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOverlay() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _kMenuWidth,
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

  Widget _buildNewsOverlay() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _kMenuWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'What\'s New',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
            ),
            _divider(),
            _menuItem(
              icon: CupertinoIcons.sparkles,
              label: 'New templates',
              subtitle: 'Try the latest',
            ),
            _menuItem(
              icon: CupertinoIcons.paintbrush,
              label: 'Custom themes',
              subtitle: 'Just added',
            ),
            _menuItem(
              icon: CupertinoIcons.share,
              label: 'Collaboration',
              subtitle: 'Coming soon',
            ),
          ],
        ),
      ),
    );
  }

  Widget _createHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Create',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'New note, folder, scan…',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 14,
              letterSpacing: -0.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1, color: Colors.white.withOpacity(0.12)),
    );
  }

  Widget _quickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _quickAction(CupertinoIcons.viewfinder, 'Scan'),
          _quickAction(CupertinoIcons.pin, 'Pin'),
          _quickAction(CupertinoIcons.lock, 'Lock'),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: Colors.white.withOpacity(0.92),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                    child: OverlayGlassCore(
                      glassSettings: const LiquidGlassSettings(
                        blur: 22,
                        lightAngle: 18,
                        lightIntensity: 0.35,
                      ),
                      controller: _topController,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _glassButton(
                              icon: CupertinoIcons.add_circled_solid,
                              label: 'New',
                              onTap: () =>
                                  _showMenu(_topController, _buildNewOverlay()),
                            ),
                            _glassButton(
                              icon: CupertinoIcons.search,
                              onTap: () => _showMenu(
                                _topController,
                                _buildSearchOverlay(),
                              ),
                            ),
                            _glassButton(
                              icon: CupertinoIcons.gear,
                              onTap: () => _showMenu(
                                _topController,
                                _buildSettingsOverlay(),
                              ),
                            ),
                            _glassButton(
                              icon: CupertinoIcons.star_fill,
                              onTap: () => _showMenu(
                                _topController,
                                _buildNewsOverlay(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _noteTile('Meeting notes', 'Mon 10:30'),
                    _noteTile('Ideas for project', 'Sun'),
                    _noteTile('Shopping list', 'Sat'),
                    _noteTile('Travel plans', 'Fri'),
                    _noteTile('Quick reminder', 'Thu'),
                  ]),
                ),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: OverlayGlassCore(
                  glassSettings: const LiquidGlassSettings(
                    blur: 22,
                    lightAngle: 18,
                    lightIntensity: 0.35,
                  ),
                  controller: _menuController,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _glassButton(
                          icon: CupertinoIcons.square_arrow_down,
                          label: 'Create',
                          onTap: () =>
                              _showMenu(_menuController, _buildCreateOverlay()),
                        ),
                        _glassButton(
                          icon: CupertinoIcons.add,
                          onTap: () =>
                              _showMenu(_menuController, _buildCreateOverlay()),
                        ),
                        _glassButton(
                          icon: CupertinoIcons.share,
                          onTap: () =>
                              _showMenu(_menuController, _buildShareOverlay()),
                        ),
                        _glassButton(
                          icon: CupertinoIcons.ellipsis,
                          onTap: () =>
                              _showMenu(_menuController, _buildMoreOverlay(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget _noteTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.055),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.doc_text,
                    color: Colors.white.withOpacity(0.55),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.96),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 14,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.white.withOpacity(0.25),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    String? label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(34),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.92), size: 22),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
