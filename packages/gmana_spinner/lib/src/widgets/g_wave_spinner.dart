import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../painters/wave_spinner_painter.dart';

/// A circular spinner with an optional animated wave fill.
class GWaveSpinner extends StatefulWidget {
  /// Active arc color.
  final Color color;

  /// Background arc color.
  final Color trackColor;

  /// Fill wave color.
  final Color waveColor;

  /// Maximum width and height.
  final double size;

  /// Duration for one full animation cycle.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  /// Optional centered child.
  final Widget? child;

  /// Optional external controller.
  ///
  /// When provided, the caller owns disposal **and** playback. The widget will
  /// use it as-is and will not call `repeat()`, `stop()`, or `dispose()` on it.
  final AnimationController? controller;

  /// Creates a circular wave spinner.
  const GWaveSpinner({
    super.key,
    required this.color,
    this.trackColor = const Color(0x68757575),
    this.waveColor = const Color(0x68757575),
    this.size = 50,
    this.duration = const Duration(milliseconds: 3000),
    this.curve = Curves.decelerate,
    this.child,
    this.controller,
  }) : assert(size > 0, 'size must be greater than zero.');

  @override
  State<GWaveSpinner> createState() => _GWaveSpinnerState();
}

class _GWaveSpinnerState extends State<GWaveSpinner>
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
  void didUpdateWidget(covariant GWaveSpinner oldWidget) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size.square(
          min(min(constraints.maxWidth, constraints.maxHeight), widget.size),
        );
        final childMaxSize = Size.square(widget.size * 0.7);
        return SizedBox.fromSize(
          size: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: size,
                painter: WaveSpinnerPainter(
                  size: size,
                  color: widget.color,
                  trackColor: widget.trackColor,
                  waveColor: widget.waveColor,
                  curve: widget.curve,
                  hasChild: widget.child != null,
                  controller: _controller,
                ),
              ),
              if (widget.child != null)
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tight(childMaxSize),
                    child: widget.child,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
