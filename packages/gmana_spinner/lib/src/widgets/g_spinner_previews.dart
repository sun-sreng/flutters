import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../animation/dot_animation_config.dart';
import 'g_bar_wave_spinner.dart';
import 'g_circular_spinner.dart';
import 'g_dot_spinner.dart';
import 'g_linear_spinner.dart';
import 'g_scale_y.dart';
import 'g_wave_dot_spinner.dart';
import 'g_wave_dot_spinner_dot.dart';
import 'g_wave_spinner.dart';

/// Builds the shared theme used by the spinner widget previews.
PreviewThemeData buildGSpinnerPreviewTheme() {
  return PreviewThemeData(
    materialLight: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      useMaterial3: true,
    ),
    materialDark: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF60A5FA),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
  );
}

/// Applies consistent spacing and centering around spinner previews.
Widget wrapGSpinnerPreview(Widget child) {
  return Material(
    type: MaterialType.transparency,
    child: Center(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

/// Previews the default circular spinner.
@Preview(
  name: 'Circular',
  group: 'gmana_spinner/widgets',
  size: Size(160, 120),
  theme: buildGSpinnerPreviewTheme,
  wrapper: wrapGSpinnerPreview,
)
Widget gCircularSpinnerPreview() {
  return const GCircularSpinner(
    color: Color(0xFF2563EB),
    strokeWidth: 3,
    padding: EdgeInsets.zero,
  );
}

/// Previews the default linear spinner.
@Preview(
  name: 'Linear',
  group: 'gmana_spinner/widgets',
  size: Size(240, 96),
  theme: buildGSpinnerPreviewTheme,
  wrapper: wrapGSpinnerPreview,
)
Widget gLinearSpinnerPreview() {
  return const SizedBox(
    width: 180,
    child: GLinearSpinner(
      color: Color(0xFF2563EB),
      minHeight: 6,
      padding: EdgeInsets.zero,
    ),
  );
}

/// Previews the pulsing dot spinner.
@Preview(
  name: 'Dots',
  group: 'gmana_spinner/widgets',
  size: Size(180, 120),
  theme: buildGSpinnerPreviewTheme,
  wrapper: wrapGSpinnerPreview,
)
Widget gDotSpinnerPreview() {
  return const GDotSpinner(color: Color(0xFF0F766E), size: 42, dotCount: 4);
}

/// Previews the wave dot spinner.
@Preview(
  name: 'Wave Dots',
  group: 'gmana_spinner/widgets',
  size: Size(180, 120),
  theme: buildGSpinnerPreviewTheme,
  wrapper: wrapGSpinnerPreview,
)
Widget gWaveDotSpinnerPreview() {
  return const GWaveDotSpinner(color: Color(0xFF7C3AED), size: 64, dotCount: 5);
}

/// Previews the bar wave spinner.
@Preview(
  name: 'Bar Wave',
  group: 'gmana_spinner/widgets',
  size: Size(180, 120),
  theme: buildGSpinnerPreviewTheme,
  wrapper: wrapGSpinnerPreview,
)
Widget gBarWaveSpinnerPreview() {
  return const GBarWaveSpinner(
    color: Color(0xFFEA580C),
    type: GBarWaveSpinnerType.center,
    size: 54,
    itemCount: 5,
  );
}

/// Previews the circular wave spinner.
@Preview(
  name: 'Wave',
  group: 'gmana_spinner/widgets',
  size: Size(180, 140),
  theme: buildGSpinnerPreviewTheme,
  wrapper: wrapGSpinnerPreview,
)
Widget gWaveSpinnerPreview() {
  return const GWaveSpinner(
    color: Color(0xFF2563EB),
    trackColor: Color(0xFFD6E4FF),
    waveColor: Color(0xFFBFDBFE),
    size: 72,
    child: Icon(Icons.hourglass_bottom, color: Color(0xFF2563EB)),
  );
}

/// Previews the vertical scaling helper widget.
@Preview(
  name: 'Scale Y',
  group: 'gmana_spinner/internals',
  size: Size(120, 120),
  theme: buildGSpinnerPreviewTheme,
  wrapper: wrapGSpinnerPreview,
)
Widget gScaleYPreview() {
  return const GScaleY(
    scaleY: AlwaysStoppedAnimation<double>(0.65),
    child: SizedBox(
      width: 24,
      height: 72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF2563EB),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    ),
  );
}

/// Previews one animated wave-dot segment.
@Preview(
  name: 'Wave Dot Segment',
  group: 'gmana_spinner/internals',
  size: Size(120, 120),
  theme: buildGSpinnerPreviewTheme,
  wrapper: wrapGSpinnerPreview,
)
Widget gWaveDotSpinnerDotPreview() {
  return _LoopingAnimationPreview(
    builder: (BuildContext context, AnimationController controller) {
      return SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: GWaveDotSpinnerDot(
            config: DotAnimationConfig.forIndex(
              index: 1,
              dotCount: 5,
              baseSize: 64,
              isEven: true,
            ),
            size: 64,
            color: const Color(0xFF7C3AED),
            controller: controller,
          ),
        ),
      );
    },
  );
}

typedef _AnimatedSpinnerBuilder =
    Widget Function(BuildContext context, AnimationController controller);

class _LoopingAnimationPreview extends StatefulWidget {
  const _LoopingAnimationPreview({required this.builder});

  final _AnimatedSpinnerBuilder builder;

  @override
  State<_LoopingAnimationPreview> createState() =>
      _LoopingAnimationPreviewState();
}

class _LoopingAnimationPreviewState extends State<_LoopingAnimationPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    unawaited(_controller.repeat());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }
}
