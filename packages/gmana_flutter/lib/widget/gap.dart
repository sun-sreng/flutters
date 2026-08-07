import 'package:flutter/widgets.dart';

/// Spacing gap widget that provides fixed width and height dimensions in layout containers.
class GGap extends StatelessWidget {
  /// Dimension along the main axis.
  final double size;

  /// Creates a uniform square gap with [size].
  const GGap(this.size, {super.key});

  /// Creates a horizontal gap with [width].
  const GGap.horizontal(double width, {super.key}) : size = width;

  /// Creates a vertical gap with [height].
  const GGap.vertical(double height, {super.key}) : size = height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
    );
  }
}
