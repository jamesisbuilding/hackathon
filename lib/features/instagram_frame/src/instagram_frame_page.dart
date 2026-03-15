import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/network/ping_api_client.dart';

class InstagramFramePage extends StatefulWidget {
  const InstagramFramePage({
    required this.instagramUrl,
    required this.pingClient,
    super.key,
  });

  final String instagramUrl;
  final PingApiClient pingClient;

  @override
  State<InstagramFramePage> createState() => _InstagramFramePageState();
}

class _InstagramFramePageState extends State<InstagramFramePage> {
  static const _bridgeName = 'ScrollBridge';
  static const _injectScrollListenerScript = '''
(() => {
  if (window.__doomscrollBridgeInstalled) return;
  window.__doomscrollBridgeInstalled = true;

  let lastY = window.scrollY || 0;
  let lastSentAt = 0;
  const minIntervalMs = 300;

  window.addEventListener('scroll', () => {
    const currentY = window.scrollY || 0;
    const now = Date.now();
    const isDown = currentY > lastY;

    if (isDown && now - lastSentAt >= minIntervalMs) {
      ScrollBridge.postMessage(JSON.stringify({
        event: 'thumb_down',
        direction: 'down',
        timestamp: new Date(now).toISOString(),
        scrollY: currentY
      }));
      lastSentAt = now;
    }

    lastY = currentY;
  }, { passive: true });
})();
''';

  late final WebViewController _controller;
  int _pingCount = 0;
  DateTime? _lastPingAt;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        _bridgeName,
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            await _controller.runJavaScript(_injectScrollListenerScript);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.instagramUrl));
  }

  Future<void> _onBridgeMessage(JavaScriptMessage message) async {
    final payload = _decodePayload(message.message);
    if (payload == null || payload['direction'] != 'down') {
      return;
    }

    final timestamp = DateTime.tryParse(payload['timestamp'] ?? '');
    final scrollY = (payload['scrollY'] as num?)?.toDouble();
    if (timestamp == null || scrollY == null) {
      return;
    }

    try {
      await widget.pingClient.sendScrollDownPing(
        timestamp: timestamp,
        scrollY: scrollY,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _pingCount += 1;
        _lastPingAt = timestamp.toLocal();
      });
    } catch (_) {
      // Ignore ping errors to keep scrolling smooth.
    }
  }

  Map<String, dynamic>? _decodePayload(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pingText = _lastPingAt == null
        ? 'No scroll-down ping sent yet'
        : 'Last ping: ${_lastPingAt!.toIso8601String()}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Frame'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.4),
            child: Text('Pings sent: $_pingCount  |  $pingText'),
          ),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
