import 'dart:math';

import 'package:flutter/material.dart';

import '../animation/spinner_controller_mixin.dart';
import '../painters/wave_spinner_painter.dart';
import '../theme/g_spinner_theme.dart';

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

  /// Screen-reader label announced while the spinner runs.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// spinner contributes no semantics node.
  final String? semanticsLabel;

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
    this.semanticsLabel,
  }) : assert(size > 0, 'size must be greater than zero.');

  @override
  State<GWaveSpinner> createState() => _GWaveSpinnerState();
}

class _GWaveSpinnerState extends State<GWaveSpinner>
    with SingleTickerProviderStateMixin, SpinnerControllerMixin {
  @override
  AnimationController? controllerOf(GWaveSpinner widget) => widget.controller;

  @override
  Duration durationOf(GWaveSpinner widget) => widget.duration;

  @override
  Widget build(BuildContext context) => wrapSpinnerSemantics(
    context: context,
    semanticsLabel: widget.semanticsLabel,
    child: _buildSpinner(context),
  );

  Widget _buildSpinner(BuildContext context) {
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
                  controller: controller,
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
