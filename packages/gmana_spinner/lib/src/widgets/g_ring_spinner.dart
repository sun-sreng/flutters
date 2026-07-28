import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A dual-ring spinning loading indicator widget.
class GRingSpinner extends StatefulWidget {
  /// Primary ring color. Defaults to theme primary color.
  final Color? color;

  /// Secondary outer track ring color. Defaults to muted primary color.
  final Color? secondaryColor;

  /// Diameter of the spinner.
  final double size;

  /// Stroke width of the ring tracks.
  final double strokeWidth;

  /// Duration of a single rotation.
  final Duration duration;

  /// Optional external animation controller.
  final AnimationController? controller;

  /// Creates a dual-ring spinner.
  const GRingSpinner({
    super.key,
    this.color,
    this.secondaryColor,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(strokeWidth > 0, 'strokeWidth must be greater than zero.');

  @override
  State<GRingSpinner> createState() => _GRingSpinnerState();
}

class _GRingSpinnerState extends State<GRingSpinner>
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
  void didUpdateWidget(covariant GRingSpinner oldWidget) {
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
    final primary = widget.color ?? Theme.of(context).colorScheme.primary;
    final secondary =
        widget.secondaryColor ?? primary.withValues(alpha: 0.2);

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: CustomPaint(
                painter: _RingSpinnerPainter(
                  primaryColor: primary,
                  secondaryColor: secondary,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RingSpinnerPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;

  _RingSpinnerPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final foregroundPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw full background track
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw primary arc (270 degrees)
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, 1.5 * math.pi, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _RingSpinnerPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
