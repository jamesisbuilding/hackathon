import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    required this.onTap,
    required this.label,
    super.key,
    this.isLoading = false,
    this.buttons = const [],
    this.collapseSignal = 0,
  });

  final VoidCallback onTap;
  final String label;
  final bool isLoading;
  final List<Widget> buttons;
  final int collapseSignal;

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton> {
  bool _expanded = false;

  double get _height => _expanded ? 44 + (widget.buttons.length * 58) : 40;

  double get _width => _expanded
      ? 50
      : widget.isLoading
          ? 40
          : 100;

  void _toggleExpanded({required bool value}) {
    setState(() => _expanded = value);
  }

  void _handleTap() {
    if (_expanded) {
      return;
    }
    widget.onTap();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collapseSignal != widget.collapseSignal && _expanded) {
      _toggleExpanded(value: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: () {
        if (!_expanded) {
          _toggleExpanded(value: true);
        }
      },
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          thickness: 20,
          blur: 10,
          glassColor: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.2,
              ),
        ),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: 50),
          child: IntrinsicHeight(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: const Cubic(0.175, 0.885, 0.32, 1.1),
              height: _height,
              width: _width,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 40,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: IntrinsicHeight(
                            child: Column(
                              spacing: 8,
                              children: [
                                _MiniActionButton(
                                  onTap: () => _toggleExpanded(value: false),
                                  icon: Icons.close,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                ...widget.buttons.map(
                                  (button) => SizedBox(
                                    height: 42,
                                    width: 42,
                                    child: Center(child: button),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : widget.isLoading
                      ? SpinKitPianoWave(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          size: 12,
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: DelayedDisplay(
                              slidingBeginOffset: const Offset(0, 0),
                              child: Text(
                                widget.label,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.onTap,
    required this.icon,
  });

  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
