import 'dart:async';

import 'package:flutter/material.dart';

import '../animation/delayed_animation_tween.dart';

import '../theme/g_spinner_theme.dart';

/// A loading spinner widget with expanding and fading pulse rings.
class GPulseSpinner extends StatefulWidget {
  /// Pulse ring color. Defaults to active theme primary color.
  final Color? color;

  /// Diameter of the spinner surface.
  final double size;

  /// Number of pulse rings (defaults to 3).
  final int pulseCount;

  /// Duration for one full pulse cycle.
  final Duration duration;

  /// Optional builder for custom ring elements.
  final IndexedWidgetBuilder? itemBuilder;

  /// Optional external animation controller.
  final AnimationController? controller;

  /// Screen-reader label announced while the spinner runs.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// spinner contributes no semantics node.
  final String? semanticsLabel;

  /// Creates a pulse ring spinner.
  const GPulseSpinner({
    super.key,
    this.color,
    this.size = 50.0,
    this.pulseCount = 3,
    this.duration = const Duration(milliseconds: 1500),
    this.itemBuilder,
    this.controller,
    this.semanticsLabel,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(pulseCount > 0, 'pulseCount must be greater than zero.');

  @override
  State<GPulseSpinner> createState() => _GPulseSpinnerState();
}

class _GPulseSpinnerState extends State<GPulseSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = AnimationController(vsync: this, duration: widget.duration);
      _ownsController = true;
      unawaited(_controller.repeat());
    }
  }

  @override
  void didUpdateWidget(covariant GPulseSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      _initController();
    } else if (_ownsController && widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ownsController) return;
    if (!TickerMode.valuesOf(context).enabled) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => wrapSpinnerSemantics(
    context: context,
    semanticsLabel: widget.semanticsLabel,
    child: _buildSpinner(context),
  );

  Widget _buildSpinner(BuildContext context) {
    final effectiveColor = GSpinnerTheme.resolveColor(context, widget.color);

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(widget.pulseCount, (index) {
            final animation = DelayedAnimationTween(
              delay: index / widget.pulseCount,
            ).animate(_controller);

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final progress = animation.value;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final scale = progress;

                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child:
                          widget.itemBuilder != null
                              ? widget.itemBuilder!(context, index)
                              : DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: effectiveColor.withValues(
                                    alpha: 0.6 * opacity,
                                  ),
                                  border: Border.all(
                                    color: effectiveColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
