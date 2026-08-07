import 'package:flutter/material.dart';

import '../design_system/spacing.dart';

/// Styled divider widget supporting optional text or custom widget label in the center.
class GDivider extends StatelessWidget {
  /// Optional label text in the middle of the divider.
  final String? label;

  /// Optional custom child widget in the middle of the divider.
  final Widget? child;

  /// Divider thickness.
  final double thickness;

  /// Indent at start.
  final double indent;

  /// Indent at end.
  final double endIndent;

  /// Color of the divider line.
  final Color? color;

  /// Text style for [label].
  final TextStyle? labelStyle;

  /// Creates a [GDivider].
  const GDivider({
    super.key,
    this.label,
    this.child,
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.color,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = color ?? theme.colorScheme.outlineVariant;
    final textWidget = child ??
        (label != null
            ? Text(
                label!,
                style: labelStyle ??
                    theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              )
            : null);

    if (textWidget == null) {
      return Divider(
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: lineColor,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: thickness,
            indent: indent,
            endIndent: GSpacing.sm,
            color: lineColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GSpacing.xs),
          child: textWidget,
        ),
        Expanded(
          child: Divider(
            thickness: thickness,
            indent: GSpacing.sm,
            endIndent: endIndent,
            color: lineColor,
          ),
        ),
      ],
    );
  }
}
