import 'package:flutter/material.dart';

import '../theme/g_spinner_theme.dart';

/// A centered Material circular progress indicator.
class GCircularSpinner extends StatelessWidget {
  /// Spinner color.
  ///
  /// When `null`, falls back to [GSpinnerTheme.color] and then to the
  /// package's legacy purple, so an existing call site keeps its appearance
  /// until a [GSpinnerTheme] is installed.
  final Color? color;

  /// Padding around the indicator.
  final EdgeInsetsGeometry padding;

  /// Indicator stroke width.
  final double strokeWidth;

  /// Screen-reader label announced while the spinner runs.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// spinner contributes no semantics node.
  final String? semanticsLabel;

  /// Creates a centered circular spinner.
  const GCircularSpinner({
    super.key,
    this.color,
    this.padding = const EdgeInsets.only(top: 10.0),
    this.strokeWidth = 4.0,
    this.semanticsLabel,
  }) : assert(strokeWidth > 0, 'strokeWidth must be greater than zero.');

  @override
  Widget build(BuildContext context) {
    final resolved =
        color ?? GSpinnerTheme.maybeOf(context)?.color ?? Colors.purple;

    return wrapSpinnerSemantics(
      context: context,
      semanticsLabel: semanticsLabel,
      child: Container(
        alignment: Alignment.center,
        padding: padding,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation(resolved),
        ),
      ),
    );
  }
}
