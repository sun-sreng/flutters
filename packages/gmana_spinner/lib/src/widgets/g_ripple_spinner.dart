import 'package:flutter/material.dart';

import '../animation/spinner_controller_mixin.dart';
import '../theme/g_spinner_theme.dart';

/// A ripple loading spinner widget with expanding concentric rings.
class GRippleSpinner extends StatefulWidget {
  /// Ripple ring color. Defaults to theme primary color.
  final Color? color;

  /// Overall size (diameter) of the ripple surface.
  final double size;

  /// Number of simultaneous ripple waves.
  final int rippleCount;

  /// Stroke width of each expanding ring.
  final double strokeWidth;

  /// Duration of one ripple expansion cycle.
  final Duration duration;

  /// Optional external animation controller.
  final AnimationController? controller;

  /// Screen-reader label announced while the spinner runs.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// spinner contributes no semantics node.
  final String? semanticsLabel;

  /// Creates a ripple ring loading spinner.
  const GRippleSpinner({
    super.key,
    this.color,
    this.size = 50.0,
    this.rippleCount = 2,
    this.strokeWidth = 3.0,
    this.duration = const Duration(milliseconds: 1500),
    this.controller,
    this.semanticsLabel,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(rippleCount > 0, 'rippleCount must be greater than zero.'),
       assert(strokeWidth > 0, 'strokeWidth must be greater than zero.');

  @override
  State<GRippleSpinner> createState() => _GRippleSpinnerState();
}

class _GRippleSpinnerState extends State<GRippleSpinner>
    with SingleTickerProviderStateMixin, SpinnerControllerMixin {
  @override
  AnimationController? controllerOf(GRippleSpinner widget) => widget.controller;

  @override
  Duration durationOf(GRippleSpinner widget) => widget.duration;

  @override
  Widget build(BuildContext context) => wrapSpinnerSemantics(
    context: context,
    semanticsLabel: widget.semanticsLabel,
    child: _buildSpinner(context),
  );

  Widget _buildSpinner(BuildContext context) {
    final rippleColor = GSpinnerTheme.resolveColor(context, widget.color);

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Stack(
              children: List.generate(widget.rippleCount, (index) {
                final delay = index / widget.rippleCount;
                final progress = (controller.value + delay) % 1.0;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final currentSize = widget.size * progress;

                return Center(
                  child: Container(
                    width: currentSize,
                    height: currentSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rippleColor.withValues(alpha: opacity),
                        width: widget.strokeWidth,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
