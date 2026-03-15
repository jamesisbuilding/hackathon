import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/events_api_client.dart';
import '../../features/events/events_page.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  EventsApiClient? _eventsClient;
  GlobalKey<NavigatorState>? _navigatorKey;
  Timer? _pollingTimer;
  EventsPayload? _cachedPayload;

  static const _channelId = 'events_channel';
  static const _channelName = 'New Events';
  static const _channelDescription = 'Notifications for new Doomscroll events';

  Future<void> initialize({
    required EventsApiClient eventsClient,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _eventsClient = eventsClient;
    _navigatorKey = navigatorKey;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;

        final eventId = int.tryParse(payload);
        if (eventId == null) return;

        _handleNotificationTap(eventId);
      },
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    _pollingTimer?.cancel();
    if (_eventsClient == null) return;

    _pollingTimer = Timer.periodic(interval, (_) {
      _checkForNewEvents();
    });

    // Run once immediately.
    _checkForNewEvents();
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkForNewEvents() async {
    final client = _eventsClient;
    if (client == null) return;

    try {
      // TODO: Replace with real UID from profile when available.
      const uid = 'user-callflow';
      final payload = await client.fetchEvents(uid: uid);

      final previous = _cachedPayload;
      _cachedPayload = payload;

      if (previous == null) {
        return;
      }

      final previousIds = previous.events.map((e) => e.id).toSet();
      final newEvents =
          payload.events.where((event) => !previousIds.contains(event.id));

      for (final event in newEvents) {
        await _showEventNotification(event);
      }
    } catch (_) {
      // Silently ignore polling errors; UI will handle explicit loads.
    }
  }

  Future<void> _showEventNotification(Event event) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails();

    final details = const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final title = event.eventTitle.isNotEmpty
        ? event.eventTitle
        : event.eventName.isNotEmpty
            ? event.eventName
            : 'New event';

    final body = event.eventDescription.isNotEmpty
        ? event.eventDescription
        : 'Tap to view details.';

    await _plugin.show(
      event.id,
      title,
      body,
      details,
      payload: event.id.toString(),
    );
  }

  void _handleNotificationTap(int eventId) {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil(
      EventsPage.routeName,
      (route) => false,
      arguments: EventNavigationArgs(eventId: eventId),
    );
  }
}

