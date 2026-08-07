import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A dual-ring loading spinner with two concentric arcs rotating in opposite directions.
class GDualRingSpinner extends StatefulWidget {
  /// Outer ring color. Defaults to theme primary color.
  final Color? color;

  /// Inner ring color. Defaults to theme secondary or primary with reduced opacity.
  final Color? secondaryColor;

  /// Overall size (diameter) of the spinner.
  final double size;

  /// Stroke width for both rings.
  final double strokeWidth;

  /// Duration for one complete rotation cycle.
  final Duration duration;

  /// Optional external animation controller.
  final AnimationController? controller;

  /// Creates a dual-ring spinner with counter-rotating arcs.
  const GDualRingSpinner({
    super.key,
    this.color,
    this.secondaryColor,
    this.size = 40.0,
    this.strokeWidth = 3.5,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(strokeWidth > 0, 'strokeWidth must be greater than zero.');

  @override
  State<GDualRingSpinner> createState() => _GDualRingSpinnerState();
}

class _GDualRingSpinnerState extends State<GDualRingSpinner>
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
  void didUpdateWidget(covariant GDualRingSpinner oldWidget) {
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
        widget.secondaryColor ??
        widget.color?.withValues(alpha: 0.6) ??
        Theme.of(context).colorScheme.secondary;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _DualRingSpinnerPainter(
                progress: _controller.value,
                primaryColor: primary,
                secondaryColor: secondary,
                strokeWidth: widget.strokeWidth,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DualRingSpinnerPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;

  _DualRingSpinnerPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer ring (clockwise)
    final outerRadius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final outerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final outerAngle = progress * 2 * math.pi;
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    canvas.drawArc(outerRect, outerAngle, math.pi * 0.75, false, outerPaint);

    // Inner ring (counter-clockwise)
    final innerRadius = outerRadius - strokeWidth * 1.5;
    if (innerRadius > 0) {
      final innerPaint = Paint()
        ..color = secondaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final innerAngle = -progress * 2 * math.pi;
      final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
      canvas.drawArc(innerRect, innerAngle, math.pi * 0.75, false, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DualRingSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
