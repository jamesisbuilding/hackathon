import 'package:flutter/material.dart';

import '../../profile/profile_page.dart';
import 'instagram_frame_page.dart';

class InstagramMenuDrawer extends StatelessWidget {
  const InstagramMenuDrawer({
    required this.currentRouteName,
    super.key,
  });

  final String currentRouteName;

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.of(context).pop();

    if (routeName == currentRouteName) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.95),
              colorScheme.secondary.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF9A9E),
                            Color(0xFFFECFEF),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Doomscroll Daycare',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Curated calm for your feed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            letterSpacing: 0.3,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
                    children: [
                      _MenuItemCard(
                        icon: Icons.home_rounded,
                        title: 'Instagram Frame',
                        subtitle: 'Your calmer scroll home',
                        isSelected:
                            currentRouteName == InstagramFramePage.routeName,
                        onTap: () => _navigateTo(
                          context,
                          InstagramFramePage.routeName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MenuItemCard(
                        icon: Icons.person_rounded,
                        title: 'Profile',
                        subtitle: 'Tune your experience',
                        isSelected: currentRouteName == ProfilePage.routeName,
                        onTap: () => _navigateTo(
                          context,
                          ProfilePage.routeName,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primary.withValues(alpha: 0.08)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.9),
                      colorScheme.secondary.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

