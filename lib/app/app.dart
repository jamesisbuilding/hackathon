import 'package:flutter/material.dart';

import '../core/network/events_api_client.dart';
import '../core/network/ping_api_client.dart';
import '../core/notifications/notification_service.dart';
import '../features/events/events_page.dart';
import '../features/instagram_frame/instagram_frame.dart';
import '../features/launch_video/launch_video.dart';
import '../features/profile/profile_page.dart';

class DoomscrollDaycareApp extends StatefulWidget {
  const DoomscrollDaycareApp({super.key});

  static const _defaultPingEndpoint = String.fromEnvironment(
    'SCROLL_PING_ENDPOINT',
    defaultValue: 'http://10.0.10.93:8000/tap-events',
  );

  static const _eventsEndpoint = String.fromEnvironment(
    'EVENTS_ENDPOINT',
    defaultValue: 'http://10.0.10.93:8000/get-events',
  );

  static const _instagramUrl = String.fromEnvironment(
    'INSTAGRAM_URL',
    defaultValue: 'https://www.instagram.com/',
  );

  static const _launchRoute = '/launch';

  @override
  State<DoomscrollDaycareApp> createState() => _DoomscrollDaycareAppState();
}

class _DoomscrollDaycareAppState extends State<DoomscrollDaycareApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  late final PingApiClient _pingClient;
  late final EventsApiClient _eventsClient;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pingClient = PingApiClient(
      endpoint: DoomscrollDaycareApp._defaultPingEndpoint,
    );
    _eventsClient = EventsApiClient(
      endpoint: DoomscrollDaycareApp._eventsEndpoint,
    );

    NotificationService.instance
        .initialize(eventsClient: _eventsClient, navigatorKey: _navigatorKey)
        .then((_) {
          NotificationService.instance.startPolling();
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.instance.stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      NotificationService.instance.stopPolling();
    } else if (state == AppLifecycleState.resumed) {
      NotificationService.instance.startPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Doomscroll Daycare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          background: Colors.white,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      initialRoute: DoomscrollDaycareApp._launchRoute,
      routes: {
        DoomscrollDaycareApp._launchRoute: (context) => LaunchVideoGate(
          child: InstagramFramePage(
            instagramUrl: DoomscrollDaycareApp._instagramUrl,
            pingClient: _pingClient,
          ),
        ),
        InstagramFramePage.routeName: (context) => InstagramFramePage(
          instagramUrl: DoomscrollDaycareApp._instagramUrl,
          pingClient: _pingClient,
        ),
        EventsPage.routeName: (context) =>
            EventsPage(eventsClient: _eventsClient),
        ProfilePage.routeName: (context) => const ProfilePage(),
      },
    );
  }
}
