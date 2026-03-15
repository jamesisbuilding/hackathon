import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LaunchVideoGate extends StatefulWidget {
  const LaunchVideoGate({
    required this.child,
    super.key,
    this.videoAssetPath = 'assets/video.mp4',
    this.fadeDuration = const Duration(milliseconds: 650),
  });

  final Widget child;
  final String videoAssetPath;
  final Duration fadeDuration;

  @override
  State<LaunchVideoGate> createState() => _LaunchVideoGateState();
}

class _LaunchVideoGateState extends State<LaunchVideoGate> {
  VideoPlayerController? _controller;
  VoidCallback? _listener;
  Timer? _videoLayerRemovalTimer;
  bool _showMainView = false;
  bool _isVideoReady = false;
  bool _removeVideoLayer = false;

  @override
  void initState() {
    super.initState();
    _initializeAndPlay();
  }

  Future<void> _initializeAndPlay() async {
    final controller = VideoPlayerController.asset(widget.videoAssetPath);
    _controller = controller;

    try {
      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();
    } catch (_) {
      _revealMainView();
      return;
    }

    _listener = () {
      final value = controller.value;
      if (!value.isInitialized || _showMainView) {
        return;
      }

      final hasCompleted = value.position >= value.duration;
      if (hasCompleted) {
        _revealMainView();
      }
    };

    controller.addListener(_listener!);

    if (!mounted) {
      return;
    }
    setState(() => _isVideoReady = true);
  }

  void _revealMainView() {
    if (!mounted || _showMainView) {
      return;
    }

    setState(() => _showMainView = true);
    _videoLayerRemovalTimer?.cancel();
    _videoLayerRemovalTimer = Timer(widget.fadeDuration, () {
      if (!mounted) {
        return;
      }
      setState(() => _removeVideoLayer = true);
    });
  }

  @override
  void dispose() {
    if (_listener != null && _controller != null) {
      _controller!.removeListener(_listener!);
    }
    _videoLayerRemovalTimer?.cancel();
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final hasVideoLayer = !_removeVideoLayer && controller != null && _isVideoReady;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedOpacity(
          opacity: _showMainView ? 1 : 0,
          duration: widget.fadeDuration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
        IgnorePointer(
          ignoring: _showMainView,
          child: AnimatedOpacity(
            opacity: _showMainView ? 0 : 1,
            duration: widget.fadeDuration,
            curve: Curves.easeIn,
            child: hasVideoLayer
                ? ColoredBox(
                    color: Colors.black,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
