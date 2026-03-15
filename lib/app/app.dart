import 'package:flutter/material.dart';

import '../core/network/ping_api_client.dart';
import '../features/instagram_frame/instagram_frame.dart';
import '../features/profile/profile_page.dart';

class DoomscrollDaycareApp extends StatelessWidget {
  const DoomscrollDaycareApp({super.key});

  static const _defaultPingEndpoint = String.fromEnvironment(
    'SCROLL_PING_ENDPOINT',
    defaultValue: 'http://10.0.10.93:8000/tap-events',
  );

  static const _instagramUrl = String.fromEnvironment(
    'INSTAGRAM_URL',
    defaultValue: 'https://www.instagram.com/',
  );

  @override
  Widget build(BuildContext context) {
    final pingClient = PingApiClient(endpoint: _defaultPingEndpoint);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doomscroll Daycare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      initialRoute: InstagramFramePage.routeName,
      routes: {
        InstagramFramePage.routeName: (context) => InstagramFramePage(
              instagramUrl: _instagramUrl,
              pingClient: pingClient,
            ),
        ProfilePage.routeName: (context) => const ProfilePage(),
      },
    );
  }
}
