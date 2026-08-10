import 'package:flutter/material.dart';

import '../theme/g_spinner_theme.dart';

/// A Material linear progress indicator with package defaults.
class GLinearSpinner extends StatelessWidget {
  /// Spinner color.
  ///
  /// When `null`, falls back to [GSpinnerTheme.color] and then to the
  /// package's legacy purple, so an existing call site keeps its appearance
  /// until a [GSpinnerTheme] is installed.
  final Color? color;

  /// Padding around the indicator.
  final EdgeInsetsGeometry padding;

  /// Minimum indicator height.
  final double minHeight;

  /// Screen-reader label announced while the spinner runs.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// spinner contributes no semantics node.
  final String? semanticsLabel;

  /// Creates a linear spinner with package defaults.
  const GLinearSpinner({
    super.key,
    this.color,
    this.padding = const EdgeInsets.only(bottom: 10.0),
    this.minHeight = 4.0,
    this.semanticsLabel,
  }) : assert(minHeight > 0, 'minHeight must be greater than zero.');

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ?? GSpinnerTheme.maybeOf(context)?.color ?? Colors.purple;

    return wrapSpinnerSemantics(
      context: context,
      semanticsLabel: semanticsLabel,
      child: Container(
        padding: padding,
        child: LinearProgressIndicator(
          minHeight: minHeight,
          valueColor: AlwaysStoppedAnimation(resolved),
        ),
      ),
    );
  }
}
