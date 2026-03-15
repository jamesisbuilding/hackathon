import 'package:flutter/material.dart';

import '../instagram_frame/src/menu.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Stack(
          children: [
            Column(
              children: [
                // to receive the uid from user
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.16),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.10),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(letterSpacing: 0.5),
                      cursorColor: Theme.of(context).colorScheme.primary,
                      decoration: InputDecoration(
                        labelText: 'Enter your UID',
                        labelStyle:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                ),
                        hintText: 'e.g. 1234-5678-ABCD',
                        hintStyle:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                ),
                        prefixIcon: const Icon(Icons.verified_user_rounded),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.85),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.4,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            HoverMenu(navigationContext: context),
          ],
        ),
      ),
    );
  }
}
