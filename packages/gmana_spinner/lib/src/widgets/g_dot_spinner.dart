import 'dart:async';

import 'package:flutter/material.dart';

import '../animation/delayed_animation_tween.dart';

/// A customizable loading spinner with animated scaling dots.
///
/// Example:
/// ```dart
/// GDotSpinner(
///   size: 50.0,
///   color: Colors.blue,
///   dotCount: 3,
///   duration: Duration(milliseconds: 1200),
/// )
/// ```
///
/// When [itemBuilder] is provided, [color] is ignored.
class GDotSpinner extends StatefulWidget {
  /// Dot color. Defaults to the active theme primary color.
  ///
  /// Ignored when [itemBuilder] is provided.
  final Color? color;

  /// Height of the spinner. Individual dots use half this size.
  final double size;

  /// Number of animated dots.
  final int dotCount;

  /// Optional builder for custom dot widgets.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration for one full animation cycle.
  final Duration duration;

  /// Optional external controller.
  ///
  /// When provided, the caller owns disposal **and** playback. The widget will
  /// use it as-is and will not call `repeat()`, `stop()`, or `dispose()` on it.
  final AnimationController? controller;

  /// Creates a pulsing-dot spinner.
  const GDotSpinner({
    super.key,
    this.color,
    this.size = 50.0,
    this.dotCount = 3,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(dotCount > 0, 'dotCount must be greater than zero.');

  @override
  State<GDotSpinner> createState() => _GDotSpinnerState();
}

class _GDotSpinnerState extends State<GDotSpinner>
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
  void didUpdateWidget(covariant GDotSpinner oldWidget) {
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
    return Center(
      child: SizedBox(
        width: widget.size * 2,
        height: widget.size,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.dotCount, (index) {
            return ScaleTransition(
              scale: DelayedAnimationTween(
                delay: index / widget.dotCount,
              ).animate(_controller),
              child: SizedBox(
                width: widget.size * 0.5,
                height: widget.size * 0.5,
                child: _buildDot(index),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return widget.itemBuilder != null
        ? widget.itemBuilder!(context, index)
        : DecoratedBox(
          decoration: BoxDecoration(
            color: widget.color ?? Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        );
  }
}
