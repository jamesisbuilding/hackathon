import 'package:flutter/material.dart';

import '../core/network/ping_api_client.dart';
import '../features/instagram_frame/instagram_frame.dart';

class DoomscrollDaycareApp extends StatelessWidget {
  const DoomscrollDaycareApp({super.key});

  static const _defaultPingEndpoint = String.fromEnvironment(
    'SCROLL_PING_ENDPOINT',
    defaultValue: 'https://httpbin.org/post',
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
      home: InstagramFramePage(
        instagramUrl: _instagramUrl,
        pingClient: pingClient,
      ),
    );
  }
}
