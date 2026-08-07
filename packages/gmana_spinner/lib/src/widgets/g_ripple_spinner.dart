import 'dart:async';

import 'package:flutter/material.dart';

/// A ripple loading spinner widget with expanding concentric rings.
class GRippleSpinner extends StatefulWidget {
  /// Ripple ring color. Defaults to theme primary color.
  final Color? color;

  /// Overall size (diameter) of the ripple surface.
  final double size;

  /// Number of simultaneous ripple waves.
  final int rippleCount;

  /// Stroke width of each expanding ring.
  final double strokeWidth;

  /// Duration of one ripple expansion cycle.
  final Duration duration;

  /// Optional external animation controller.
  final AnimationController? controller;

  /// Creates a ripple ring loading spinner.
  const GRippleSpinner({
    super.key,
    this.color,
    this.size = 50.0,
    this.rippleCount = 2,
    this.strokeWidth = 3.0,
    this.duration = const Duration(milliseconds: 1500),
    this.controller,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(rippleCount > 0, 'rippleCount must be greater than zero.'),
       assert(strokeWidth > 0, 'strokeWidth must be greater than zero.');

  @override
  State<GRippleSpinner> createState() => _GRippleSpinnerState();
}

class _GRippleSpinnerState extends State<GRippleSpinner>
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
      _controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      _ownsController = true;
      unawaited(_controller.repeat());
    }
  }

  @override
  void didUpdateWidget(covariant GRippleSpinner oldWidget) {
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
    final rippleColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: List.generate(widget.rippleCount, (index) {
                final delay = index / widget.rippleCount;
                final progress = (_controller.value + delay) % 1.0;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final currentSize = widget.size * progress;

                return Center(
                  child: Container(
                    width: currentSize,
                    height: currentSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rippleColor.withValues(alpha: opacity),
                        width: widget.strokeWidth,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
