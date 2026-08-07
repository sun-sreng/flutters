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

  /// Forces the outline on even when [borderColor] is not supplied.
  ///
  /// Without this, a card only draws a border when you name the color — which
  /// makes "outlined card in the theme's own color" awkward to express.
  final bool showBorder;

  /// Long-press callback, mirroring [onTap].
  final VoidCallback? onLongPress;

  /// Semantics label describing the card as a whole.
  final String? semanticsLabel;

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
    this.showBorder = false,
    this.onLongPress,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? GSpacing.paddingAll(GSpacing.lg);
    final effectiveBg = backgroundColor ?? theme.colorScheme.surface;
    final effectiveBorderColor =
        borderColor ?? theme.colorScheme.outlineVariant;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side:
          (borderColor != null || showBorder)
              ? BorderSide(color: effectiveBorderColor)
              : BorderSide.none,
    );

    final isInteractive = onTap != null || onLongPress != null;

    Widget cardBody = Material(
      color: effectiveBg,
      elevation: elevation,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child:
          isInteractive
              ? InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(padding: effectivePadding, child: child),
              )
              : Padding(padding: effectivePadding, child: child),
    );

    if (semanticsLabel != null) {
      // `explicitChildNodes` keeps the card's own label separate from its
      // content. Without it the child text is merged in and the label reads
      // as a prefix rather than a description of the container.
      cardBody = Semantics(
        container: true,
        explicitChildNodes: true,
        label: semanticsLabel,
        button: isInteractive,
        child: cardBody,
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: cardBody);
    }

    return cardBody;
  }
}
