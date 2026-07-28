import 'package:flutter/material.dart';
import '../design_system/spacing.dart';

/// A surface card container widget with customizable background, border, elevation, and optional ink response.
class GCard extends StatelessWidget {
  /// The content child widget inside the card.
  final Widget child;

  /// Optional tap callback. If provided, renders an InkWell gesture response.
  final VoidCallback? onTap;

  /// Internal padding around [child].
  final EdgeInsetsGeometry? padding;

  /// Outer margin surrounding the card.
  final EdgeInsetsGeometry? margin;

  /// Background color (defaults to theme surface container / surface).
  final Color? backgroundColor;

  /// Border color (defaults to theme outline color if specified).
  final Color? borderColor;

  /// Corner radius (defaults to 12.0).
  final double borderRadius;

  /// Shadow elevation (defaults to 0.0).
  final double elevation;

  /// Creates a styled [GCard].
  const GCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12.0,
    this.elevation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? GSpacing.paddingAll(GSpacing.lg);
    final effectiveBg = backgroundColor ?? theme.colorScheme.surface;
    final effectiveBorderColor = borderColor ?? theme.colorScheme.outlineVariant;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: borderColor != null
          ? BorderSide(color: effectiveBorderColor)
          : BorderSide.none,
    );

    final Widget cardBody = Material(
      color: effectiveBg,
      elevation: elevation,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Padding(padding: effectivePadding, child: child),
            )
          : Padding(padding: effectivePadding, child: child),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: cardBody);
    }

    return cardBody;
  }
}
