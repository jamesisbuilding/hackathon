import 'package:flutter/material.dart';

import '../../events/events_page.dart';
import '../../profile/profile_page.dart';
import 'instagram_frame_page.dart' as instaPage;

class HoverMenu extends StatefulWidget {
  const HoverMenu({required this.navigationContext, super.key});

  /// Context that is a descendant of the app's Navigator.
  final BuildContext navigationContext;

  @override
  State<HoverMenu> createState() => _HoverMenuState();
}

class _HoverMenuState extends State<HoverMenu> {
  static const _diameter = 64.0;
  static const _barHeight = 50.0;
  static const _horizontalMargin = 16.0;
  static const _verticalSpacing = 8.0;

  Offset _offset = const Offset(24, 120);
  bool _isMenuOpen = false;

  void _navigateTo(String routeName) {
    final navContext = widget.navigationContext;
    final currentRoute = ModalRoute.of(navContext)?.settings.name;
    if (currentRoute == routeName) {
      setState(() {
        _isMenuOpen = false;
      });
      return;
    }

    setState(() {
      _isMenuOpen = false;
    });

    Navigator.of(
      navContext,
    ).pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clampedX = _offset.dx.clamp(
          0.0,
          constraints.maxWidth - _diameter,
        );
        final clampedY = _offset.dy.clamp(
          0.0,
          constraints.maxHeight - _diameter,
        );

        final showAbove =
            clampedY >= _barHeight + _verticalSpacing; // enough room on top
        final barTop = showAbove
            ? clampedY - _verticalSpacing - _barHeight
            : clampedY + _diameter + _verticalSpacing;

        return Stack(
          children: [
            Positioned(
              left: _horizontalMargin,
              right: _horizontalMargin,
              top: barTop,
              child: IgnorePointer(
                ignoring: !_isMenuOpen,
                child: AnimatedOpacity(
                  opacity: _isMenuOpen ? 1 : 0,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedScale(
                    scale: _isMenuOpen ? 1 : 0.2,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.center,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        height: _barHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _HoverMenuButton(
                              icon: Icons.home_rounded,
                              label: 'Instagram',
                              onTap: () => _navigateTo(
                                instaPage.InstagramFramePage.routeName,
                              ),
                            ),
                            _HoverMenuButton(
                              icon: Icons.event_rounded,
                              label: 'Events',
                              onTap: () => _navigateTo(EventsPage.routeName),
                            ),
                            _HoverMenuButton(
                              icon: Icons.person_rounded,
                              label: 'Profile',
                              onTap: () => _navigateTo(ProfilePage.routeName),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: clampedX,
              top: clampedY,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(
                    details.globalPosition,
                  );

                  final newX = (localPosition.dx - _diameter / 2).clamp(
                    0.0,
                    constraints.maxWidth - _diameter,
                  );
                  final newY = (localPosition.dy - _diameter / 2).clamp(
                    0.0,
                    constraints.maxHeight - _diameter,
                  );

                  setState(() {
                    _offset = Offset(newX, newY);
                  });
                },
                onTap: () {
                  setState(() {
                    _isMenuOpen = !_isMenuOpen;
                  });
                },
                child: Container(
                  width: _diameter,
                  height: _diameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withValues(alpha: 0.85),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: Icon(
                      _isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                      key: ValueKey<bool>(_isMenuOpen),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HoverMenuButton extends StatelessWidget {
  const _HoverMenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
