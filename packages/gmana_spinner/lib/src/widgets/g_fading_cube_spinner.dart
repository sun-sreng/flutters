import 'dart:async';

import 'package:flutter/material.dart';

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

  /// Creates a 2x2 fading cube spinner.
  const GFadingCubeSpinner({
    super.key,
    this.color,
    this.size = 40.0,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  }) : assert(size > 0, 'size must be greater than zero.');

  @override
  State<GFadingCubeSpinner> createState() => _GFadingCubeSpinnerState();
}

class _GFadingCubeSpinnerState extends State<GFadingCubeSpinner>
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
  void didUpdateWidget(covariant GFadingCubeSpinner oldWidget) {
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

  double _getCubeOpacity(double progress, double delay) {
    final v = (progress - delay) % 1.0;
    if (v < 0.5) {
      return v * 2.0;
    } else {
      return (1.0 - v) * 2.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubeColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final cubeSize = widget.size * 0.42;

    const delays = [0.0, 0.25, 0.75, 0.5]; // Top-Left, Top-Right, Bottom-Left, Bottom-Right

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCube(cubeSize, cubeColor, _getCubeOpacity(_controller.value, delays[0])),
                    _buildCube(cubeSize, cubeColor, _getCubeOpacity(_controller.value, delays[1])),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCube(cubeSize, cubeColor, _getCubeOpacity(_controller.value, delays[2])),
                    _buildCube(cubeSize, cubeColor, _getCubeOpacity(_controller.value, delays[3])),
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
