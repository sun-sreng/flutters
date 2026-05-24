import 'package:flutter/material.dart';

/// A Material linear progress indicator with package defaults.
class GLinearSpinner extends StatelessWidget {
  /// Spinner color.
  ///
  /// Defaults to the package's legacy purple.
  final Color color;

  /// Padding around the indicator.
  final EdgeInsetsGeometry padding;

  /// Minimum indicator height.
  final double minHeight;

  /// Creates a linear spinner with package defaults.
  const GLinearSpinner({
    super.key,
    this.color = Colors.purple,
    this.padding = const EdgeInsets.only(bottom: 10.0),
    this.minHeight = 4.0,
  }) : assert(minHeight > 0, 'minHeight must be greater than zero.');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: LinearProgressIndicator(
        minHeight: minHeight,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
