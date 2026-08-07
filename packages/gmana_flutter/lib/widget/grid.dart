import 'package:flutter/material.dart';

import '../design_system/spacing.dart';

/// Responsive grid container widget that auto-calculates columns or accepts a fixed column count.
class GGrid extends StatelessWidget {
  /// Grid child widgets.
  final List<Widget> children;

  /// Target maximum width per grid item (used when [crossAxisCount] is null).
  final double? maxItemWidth;

  /// Fixed column count.
  final int? crossAxisCount;

  /// Horizontal spacing between items.
  final double spacing;

  /// Vertical spacing between items.
  final double runSpacing;

  /// Aspect ratio of grid items.
  final double childAspectRatio;

  /// Grid padding.
  final EdgeInsetsGeometry? padding;

  /// Creates a [GGrid].
  const GGrid({
    super.key,
    required this.children,
    this.maxItemWidth,
    this.crossAxisCount,
    this.spacing = GSpacing.md,
    this.runSpacing = GSpacing.md,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = crossAxisCount ??
            ((maxItemWidth != null && maxItemWidth! > 0)
                ? (constraints.maxWidth / maxItemWidth!).floor().clamp(1, 12)
                : 2);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          mainAxisSpacing: runSpacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          padding: padding,
          children: children,
        );
      },
    );
  }
}
