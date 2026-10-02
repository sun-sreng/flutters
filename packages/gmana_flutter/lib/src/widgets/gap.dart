import 'package:flutter/widgets.dart';

/// Spacing gap widget that provides fixed width and height dimensions in layout containers.
class GGap extends StatelessWidget {
  /// Dimension along the primary configured axis.
  final double size;

  /// Explicit horizontal width dimension.
  final double? width;

  /// Explicit vertical height dimension.
  final double? height;

  /// Creates a uniform square gap with [size].
  const GGap(this.size, {super.key}) : width = size, height = size;

  /// Creates a horizontal gap with [width].
  const GGap.horizontal(double width, {super.key})
    : size = width,
      width = width,
      height = null;

  /// Creates a vertical gap with [height].
  const GGap.vertical(double height, {super.key})
    : size = height,
      width = null,
      height = height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}
