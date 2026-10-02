import 'package:flutter/material.dart';

import '../animation/delayed_animation_tween.dart';
import '../animation/spinner_controller_mixin.dart';
import '../theme/g_spinner_theme.dart';

/// A loading spinner widget with expanding and fading pulse rings.
class GPulseSpinner extends StatefulWidget {
  /// Pulse ring color. Defaults to active theme primary color.
  final Color? color;

  /// Diameter of the spinner surface.
  final double size;

  /// Number of pulse rings (defaults to 3).
  final int pulseCount;

  /// Duration for one full pulse cycle.
  final Duration duration;

  /// Optional builder for custom ring elements.
  final IndexedWidgetBuilder? itemBuilder;

  /// Optional external animation controller.
  final AnimationController? controller;

  /// Screen-reader label announced while the spinner runs.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// spinner contributes no semantics node.
  final String? semanticsLabel;

  /// Creates a pulse ring spinner.
  const GPulseSpinner({
    super.key,
    this.color,
    this.size = 50.0,
    this.pulseCount = 3,
    this.duration = const Duration(milliseconds: 1500),
    this.itemBuilder,
    this.controller,
    this.semanticsLabel,
  }) : assert(size > 0, 'size must be greater than zero.'),
       assert(pulseCount > 0, 'pulseCount must be greater than zero.');

  @override
  State<GPulseSpinner> createState() => _GPulseSpinnerState();
}

class _GPulseSpinnerState extends State<GPulseSpinner>
    with SingleTickerProviderStateMixin, SpinnerControllerMixin {
  @override
  AnimationController? controllerOf(GPulseSpinner widget) => widget.controller;

  @override
  Duration durationOf(GPulseSpinner widget) => widget.duration;

  @override
  Widget build(BuildContext context) => wrapSpinnerSemantics(
    context: context,
    semanticsLabel: widget.semanticsLabel,
    child: _buildSpinner(context),
  );

  Widget _buildSpinner(BuildContext context) {
    final effectiveColor = GSpinnerTheme.resolveColor(context, widget.color);

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(widget.pulseCount, (index) {
            final animation = DelayedAnimationTween(
              delay: index / widget.pulseCount,
            ).animate(controller);

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final progress = animation.value;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final scale = progress;

                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child:
                          widget.itemBuilder != null
                              ? widget.itemBuilder!(context, index)
                              : DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: effectiveColor.withValues(
                                    alpha: 0.6 * opacity,
                                  ),
                                  border: Border.all(
                                    color: effectiveColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
