import 'dart:async';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../core/network/ping_api_client.dart';
import 'instagram_menu_drawer.dart';

class InstagramFramePage extends StatefulWidget {
  const InstagramFramePage({
    required this.instagramUrl,
    required this.pingClient,
    super.key,
  });

  static const routeName = '/instagram-frame';

  final String instagramUrl;
  final PingApiClient pingClient;

  @override
  State<InstagramFramePage> createState() => _InstagramFramePageState();
}

class _InstagramFramePageState extends State<InstagramFramePage> {
  static const _bridgeName = 'ScrollBridge';
  static const _flushIntervalSeconds = 10;

  static const _injectVideoFixScript = '''
(() => {
  if (window.__videoFixInstalled) return;
  window.__videoFixInstalled = true;

  const noop = () => Promise.resolve();
  Element.prototype.requestFullscreen       = noop;
  Element.prototype.webkitRequestFullscreen = noop;
  Element.prototype.webkitEnterFullscreen   = noop;
  document.exitFullscreen        = noop;
  document.webkitExitFullscreen  = noop;

  ['fullscreenchange','webkitfullscreenchange','mozfullscreenchange'].forEach(evt => {
    document.addEventListener(evt, e => e.stopImmediatePropagation(), true);
  });

  function patchVideo(video) {
    if (video.__patched) return;
    video.__patched = true;
    video.setAttribute('playsinline', '');
    video.setAttribute('webkit-playsinline', '');
    video.style.pointerEvents = 'auto';
    const originalPlay = video.play.bind(video);
    video.play = function (...args) {
      this.setAttribute('playsinline', '');
      this.setAttribute('webkit-playsinline', '');
      return originalPlay(...args);
    };
  }

  document.querySelectorAll('video').forEach(patchVideo);

  const observer = new MutationObserver((mutations) => {
    for (const m of mutations) {
      for (const node of m.addedNodes) {
        if (node.nodeType !== 1) continue;
        if (node.tagName === 'VIDEO') patchVideo(node);
        node.querySelectorAll?.('video').forEach(patchVideo);
      }
    }
  });
  observer.observe(document.documentElement, { childList: true, subtree: true });
})();
''';

  static const _topics = [
    'education',
    'movie',
    'music',
    'sport',
    'food',
    'travel',
    'fashion',
    'technology',
    'gaming',
    'news',
    'comedy',
    'fitness',
  ];

  final String _randomTopic = _topics[Random().nextInt(_topics.length)];

  late final WebViewController _controller;

  // Tap buffer — flushed every 10 s
  final List<Map<String, dynamic>> _pendingTaps = [];
  Timer? _flushTimer;

  // UI feedback
  int _pingCount = 0;
  DateTime? _lastPingAt;

  // Touch tracking
  double? _touchStartY;
  bool _hasFiredForThisTouch = false;

  @override
  void initState() {
    super.initState();

    _flushTimer = Timer.periodic(
      const Duration(seconds: _flushIntervalSeconds),
      (_) => _flushTaps(),
    );

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(_bridgeName, onMessageReceived: _onBridgeMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            await _controller.runJavaScript(_injectVideoFixScript);
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            final isInstagram =
                uri.host.contains('instagram.com') ||
                uri.host.contains('cdninstagram.com') ||
                uri.host.contains('fbcdn.net');

            if (!isInstagram) return NavigationDecision.prevent;

            final base = Uri.tryParse(widget.instagramUrl);
            final isVideoDeepLink =
                (uri.path.contains('/video/') || uri.path.contains('/reel/')) &&
                request.isMainFrame &&
                base != null &&
                uri.path != base.path;

            if (isVideoDeepLink) return NavigationDecision.prevent;

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.instagramUrl));
  }

  @override
  void dispose() {
    _flushTimer?.cancel();
    // Flush any remaining taps before leaving the page
    if (_pendingTaps.isNotEmpty) _flushTaps();
    super.dispose();
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    // Kept for future use.
  }

  /// Called on every detected scroll-down gesture — just buffers the tap.
  void _recordScrollDown() {
    final tapAt = DateTime.now().millisecondsSinceEpoch;
    dev.log('Tap = ${{'tapped_at': tapAt, 'topic': _randomTopic}}');
    _pendingTaps.add({'tapped_at': tapAt, 'topic': _randomTopic});
  }

  /// Sends the current buffer to the API and clears it.
  Future<void> _flushTaps() async {
    if (_pendingTaps.isEmpty) return;

    // Snapshot and clear immediately so new taps during the await go to a
    // fresh buffer rather than being sent twice.
    final batch = List<Map<String, dynamic>>.from(_pendingTaps);
    _pendingTaps.clear();

    final timestamp = DateTime.now();
    try {
      await widget.pingClient.sendScrollDownPing(uid: "test1", taps: batch);
      if (!mounted) return;
      setState(() {
        _pingCount += batch.length;
        _lastPingAt = timestamp;
      });
    } catch (_) {
      // On failure, put them back so they're retried next flush.
      _pendingTaps.insertAll(0, batch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Frame'),
      ),
      drawer: const InstagramMenuDrawer(
        currentRouteName: InstagramFramePage.routeName,
      ),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          _touchStartY = event.position.dy;
          _hasFiredForThisTouch = false;
        },
        onPointerMove: (event) {
          if (_touchStartY == null) return;
          if (_hasFiredForThisTouch) return;

          final dy = event.position.dy - _touchStartY!;
          if (dy < -10) {
            _hasFiredForThisTouch = true;
            _recordScrollDown(); // synchronous, no async needed
          }
        },
        onPointerUp: (_) {
          _touchStartY = null;
          _hasFiredForThisTouch = false;
        },
        onPointerCancel: (_) {
          _touchStartY = null;
          _hasFiredForThisTouch = false;
        },
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
