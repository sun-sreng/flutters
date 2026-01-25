import 'package:flutter/material.dart';

import 'models/dot_animation_config.dart';

/// A single animated dot for the SpinnerWaveDot widget.
class DotContainer extends StatelessWidget {
  final DotAnimationConfig config;
  final double size;
  final Color color;
  final AnimationController controller;

  const DotContainer({
    super.key,
    required this.config,
    required this.size,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final dotSize = size * 0.13;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final isForward = controller.value <= config.offsetInterval.end;
        final offsetTween = Tween<Offset>(
          begin: isForward ? Offset.zero : Offset(0, config.maxOffset),
          end: isForward ? Offset(0, config.maxOffset) : Offset.zero,
        );
        final heightTween = Tween<double>(
          begin: isForward ? dotSize : config.maxHeight,
          end: isForward ? config.maxHeight : dotSize,
        );

        return Transform.translate(
          offset:
              offsetTween
                  .animate(
                    CurvedAnimation(
                      parent: controller,
                      curve:
                          isForward
                              ? config.offsetInterval
                              : config.reverseOffsetInterval,
                    ),
                  )
                  .value,
          child: Container(
            width: dotSize,
            height:
                heightTween
                    .animate(
                      CurvedAnimation(
                        parent: controller,
                        curve:
                            isForward
                                ? config.heightInterval
                                : config.reverseHeightInterval,
                      ),
                    )
                    .value,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(dotSize / 2),
            ),
          ),
        );
      },
    );
  }
}
