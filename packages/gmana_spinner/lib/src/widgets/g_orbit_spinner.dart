import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animation/spinner_controller_mixin.dart';
import '../theme/g_spinner_theme.dart';

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

  /// Screen-reader label announced while the spinner runs.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// spinner contributes no semantics node.
  final String? semanticsLabel;

  /// Creates an orbit spinner widget.
  const GOrbitSpinner({
    super.key,
    this.color,
    this.secondaryColor,
    this.size = 44.0,
    this.satelliteCount = 3,
    this.duration = const Duration(milliseconds: 1600),
    this.controller,
    this.semanticsLabel,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(satelliteCount > 0, 'satelliteCount must be greater than zero.');

  @override
  State<GOrbitSpinner> createState() => _GOrbitSpinnerState();
}

class _GOrbitSpinnerState extends State<GOrbitSpinner>
    with SingleTickerProviderStateMixin, SpinnerControllerMixin {
  @override
  AnimationController? controllerOf(GOrbitSpinner widget) => widget.controller;

  @override
  Duration durationOf(GOrbitSpinner widget) => widget.duration;

  @override
  Widget build(BuildContext context) => wrapSpinnerSemantics(
    context: context,
    semanticsLabel: widget.semanticsLabel,
    child: _buildSpinner(context),
  );

  Widget _buildSpinner(BuildContext context) {
    final primary = GSpinnerTheme.resolveColor(context, widget.color);
    final secondary = GSpinnerTheme.resolveSecondaryColor(
      context,
      widget.secondaryColor,
      primary.withValues(alpha: 0.6),
    );
    final coreSize = widget.size * 0.25;
    final satelliteSize = widget.size * 0.18;
    final radius = (widget.size - satelliteSize) / 2;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: controller,
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
                  final angleOffset =
                      (2 * math.pi / widget.satelliteCount) * index;
                  final currentAngle =
                      (controller.value * 2 * math.pi) + angleOffset;
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
