import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/g_spinner_theme.dart';

/// A loading spinner with two chasing dots rotating and scaling around a center.
class GChasingDotsSpinner extends StatefulWidget {
  /// Color of the chasing dots. Defaults to theme primary color.
  final Color? color;

  /// Overall diameter of the spinner container.
  final double size;

  /// Duration of one full rotation cycle.
  final Duration duration;

  /// Optional external animation controller.
  final AnimationController? controller;

  /// Screen-reader label announced while the spinner runs.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// spinner contributes no semantics node.
  final String? semanticsLabel;

  /// Creates a chasing dots spinner widget.
  const GChasingDotsSpinner({
    super.key,
    this.color,
    this.size = 40.0,
    this.duration = const Duration(milliseconds: 1400),
    this.controller,
    this.semanticsLabel,
  }) : assert(size > 0, 'size must be greater than zero.');

  @override
  State<GChasingDotsSpinner> createState() => _GChasingDotsSpinnerState();
}

class _GChasingDotsSpinnerState extends State<GChasingDotsSpinner>
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
  void didUpdateWidget(covariant GChasingDotsSpinner oldWidget) {
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
    final dotColor = GSpinnerTheme.resolveColor(context, widget.color);
    final dotSize = widget.size * 0.6;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dot 1 (top-scaled)
                  Positioned(
                    top: 0,
                    child: Transform.scale(
                      scale:
                          0.4 +
                          0.6 * math.sin(_controller.value * math.pi).abs(),
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  // Dot 2 (bottom-scaled, phase shifted)
                  Positioned(
                    bottom: 0,
                    child: Transform.scale(
                      scale:
                          0.4 +
                          0.6 * math.cos(_controller.value * math.pi).abs(),
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: dotColor.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
