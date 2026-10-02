import 'package:flutter/material.dart';

import '../animation/dot_animation_config.dart';
import '../animation/spinner_controller_mixin.dart';
import '../theme/g_spinner_theme.dart';
import 'g_wave_dot_spinner_dot.dart';

/// A customizable loading spinner with a wave-like animation of scaling dots.
///
/// Example:
/// ```dart
/// GWaveDotSpinner(
///   size: 50.0,
///   color: Colors.blue,
///   dotCount: 5,
/// )
/// ```
class GWaveDotSpinner extends StatefulWidget {
  /// Width and height of the spinner.
  final double size;

  /// Dot color. Defaults to the active theme primary color.
  final Color? color;

  /// Number of dots in the wave.
  final int dotCount;

  /// Duration for one full animation cycle.
  final Duration duration;

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

  /// Creates a wave-ripple dot spinner.
  const GWaveDotSpinner({
    super.key,
    required this.size,
    this.color,
    this.dotCount = 5,
    this.duration = const Duration(milliseconds: 1600),
    this.controller,
    this.semanticsLabel,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(dotCount > 0, 'dotCount must be greater than zero.');

  @override
  State<GWaveDotSpinner> createState() => _GWaveDotSpinnerState();
}

class _GWaveDotSpinnerState extends State<GWaveDotSpinner>
    with SingleTickerProviderStateMixin, SpinnerControllerMixin {
  @override
  AnimationController? controllerOf(GWaveDotSpinner widget) =>
      widget.controller;

  @override
  Duration durationOf(GWaveDotSpinner widget) => widget.duration;

  @override
  Widget build(BuildContext context) => wrapSpinnerSemantics(
    context: context,
    semanticsLabel: widget.semanticsLabel,
    child: _buildSpinner(context),
  );

  Widget _buildSpinner(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.dotCount, (index) {
          return GWaveDotSpinnerDot(
            config: DotAnimationConfig.forIndex(
              index: index,
              dotCount: widget.dotCount,
              baseSize: widget.size,
              isEven: index % 2 == 1,
            ),
            size: widget.size,
            color: GSpinnerTheme.resolveColor(context, widget.color),
            controller: controller,
          );
        }),
      ),
    );
  }
}
