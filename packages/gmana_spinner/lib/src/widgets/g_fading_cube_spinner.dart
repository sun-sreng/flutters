import 'package:flutter/material.dart';

import '../animation/spinner_controller_mixin.dart';
import '../theme/g_spinner_theme.dart';

/// A 2x2 grid of fading and scaling cubes loading spinner widget.
class GFadingCubeSpinner extends StatefulWidget {
  /// Cube color. Defaults to active theme primary color.
  final Color? color;

  /// Overall size of the grid container.
  final double size;

  /// Duration of one full animation cycle.
  final Duration duration;

  /// Optional external animation controller.
  final AnimationController? controller;

  /// Screen-reader label announced while the spinner runs.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// spinner contributes no semantics node.
  final String? semanticsLabel;

  /// Creates a 2x2 fading cube spinner.
  const GFadingCubeSpinner({
    super.key,
    this.color,
    this.size = 40.0,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
    this.semanticsLabel,
  }) : assert(size > 0, 'size must be greater than zero.');

  @override
  State<GFadingCubeSpinner> createState() => _GFadingCubeSpinnerState();
}

class _GFadingCubeSpinnerState extends State<GFadingCubeSpinner>
    with SingleTickerProviderStateMixin, SpinnerControllerMixin {
  @override
  AnimationController? controllerOf(GFadingCubeSpinner widget) =>
      widget.controller;

  @override
  Duration durationOf(GFadingCubeSpinner widget) => widget.duration;

  double _getCubeOpacity(double progress, double delay) {
    final v = (progress - delay) % 1.0;
    if (v < 0.5) {
      return v * 2.0;
    } else {
      return (1.0 - v) * 2.0;
    }
  }

  @override
  Widget build(BuildContext context) => wrapSpinnerSemantics(
    context: context,
    semanticsLabel: widget.semanticsLabel,
    child: _buildSpinner(context),
  );

  Widget _buildSpinner(BuildContext context) {
    final cubeColor = GSpinnerTheme.resolveColor(context, widget.color);
    final cubeSize = widget.size * 0.42;

    const delays = [
      0.0,
      0.25,
      0.75,
      0.5,
    ]; // Top-Left, Top-Right, Bottom-Left, Bottom-Right

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCube(
                      cubeSize,
                      cubeColor,
                      _getCubeOpacity(controller.value, delays[0]),
                    ),
                    _buildCube(
                      cubeSize,
                      cubeColor,
                      _getCubeOpacity(controller.value, delays[1]),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCube(
                      cubeSize,
                      cubeColor,
                      _getCubeOpacity(controller.value, delays[2]),
                    ),
                    _buildCube(
                      cubeSize,
                      cubeColor,
                      _getCubeOpacity(controller.value, delays[3]),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCube(double size, Color color, double opacity) {
    final clampedOpacity = opacity.clamp(0.1, 1.0);
    return Opacity(
      opacity: clampedOpacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.15),
        ),
      ),
    );
  }
}
