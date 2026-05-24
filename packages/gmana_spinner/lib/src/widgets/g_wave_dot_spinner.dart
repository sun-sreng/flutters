import 'dart:async';

import 'package:flutter/material.dart';

import '../animation/dot_animation_config.dart';
import 'g_wave_dot_spinner_dot.dart';

/// A customizable loading spinner with a wave-like animation of scaling dots.
///
/// Example:
/// ```dart
/// GWaveDotSpinner(
///   size: 50.0,
///   color: Colors.blue,
///   dotCount: 5,
/// )
/// ```
class GWaveDotSpinner extends StatefulWidget {
  /// Width and height of the spinner.
  final double size;

  /// Dot color. Defaults to the active theme primary color.
  final Color? color;

  /// Number of dots in the wave.
  final int dotCount;

  /// Duration for one full animation cycle.
  final Duration duration;

  /// Optional external controller.
  ///
  /// When provided, the caller owns disposal **and** playback. The widget will
  /// use it as-is and will not call `repeat()`, `stop()`, or `dispose()` on it.
  final AnimationController? controller;

  /// Creates a wave-ripple dot spinner.
  const GWaveDotSpinner({
    super.key,
    required this.size,
    this.color,
    this.dotCount = 5,
    this.duration = const Duration(milliseconds: 1600),
    this.controller,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(dotCount > 0, 'dotCount must be greater than zero.');

  @override
  State<GWaveDotSpinner> createState() => _GWaveDotSpinnerState();
}

class _GWaveDotSpinnerState extends State<GWaveDotSpinner>
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
  void didUpdateWidget(covariant GWaveDotSpinner oldWidget) {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.dotCount, (index) {
          return GWaveDotSpinnerDot(
            config: DotAnimationConfig.forIndex(
              index: index,
              dotCount: widget.dotCount,
              baseSize: widget.size,
              isEven: index % 2 == 1,
            ),
            size: widget.size,
            color: widget.color ?? Theme.of(context).colorScheme.primary,
            controller: _controller,
          );
        }),
      ),
    );
  }
}
