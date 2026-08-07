import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An orbiting satellite loading spinner with a central core and revolving dots.
class GOrbitSpinner extends StatefulWidget {
  /// Core and satellite color. Defaults to theme primary color.
  final Color? color;

  /// Secondary color for alternating satellites.
  final Color? secondaryColor;

  /// Diameter of the total orbiting path.
  final double size;

  /// Number of orbiting satellite dots.
  final int satelliteCount;

  /// Duration of one complete orbit cycle.
  final Duration duration;

  /// Optional external animation controller.
  final AnimationController? controller;

  /// Creates an orbit spinner widget.
  const GOrbitSpinner({
    super.key,
    this.color,
    this.secondaryColor,
    this.size = 44.0,
    this.satelliteCount = 3,
    this.duration = const Duration(milliseconds: 1600),
    this.controller,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(satelliteCount > 0, 'satelliteCount must be greater than zero.');

  @override
  State<GOrbitSpinner> createState() => _GOrbitSpinnerState();
}

class _GOrbitSpinnerState extends State<GOrbitSpinner>
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
  void didUpdateWidget(covariant GOrbitSpinner oldWidget) {
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
    final secondary = widget.secondaryColor ?? primary.withValues(alpha: 0.6);
    final coreSize = widget.size * 0.25;
    final satelliteSize = widget.size * 0.18;
    final radius = (widget.size - satelliteSize) / 2;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Center Core
                Container(
                  width: coreSize,
                  height: coreSize,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                // Satellites
                ...List.generate(widget.satelliteCount, (index) {
                  final angleOffset = (2 * math.pi / widget.satelliteCount) * index;
                  final currentAngle = (_controller.value * 2 * math.pi) + angleOffset;
                  final dx = radius * math.cos(currentAngle);
                  final dy = radius * math.sin(currentAngle);
                  final dotColor = index.isEven ? primary : secondary;

                  return Transform.translate(
                    offset: Offset(dx, dy),
                    child: Container(
                      width: satelliteSize,
                      height: satelliteSize,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
