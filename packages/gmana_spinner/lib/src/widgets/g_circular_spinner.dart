import 'package:flutter/material.dart';

/// A centered Material circular progress indicator.
class GCircularSpinner extends StatelessWidget {
  /// Spinner color.
  ///
  /// Defaults to the package's legacy purple.
  final Color color;

  /// Padding around the indicator.
  final EdgeInsetsGeometry padding;

  /// Indicator stroke width.
  final double strokeWidth;

  /// Creates a centered circular spinner.
  const GCircularSpinner({
    super.key,
    this.color = Colors.purple,
    this.padding = const EdgeInsets.only(top: 10.0),
    this.strokeWidth = 4.0,
  }) : assert(strokeWidth > 0, 'strokeWidth must be greater than zero.');

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: padding,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
