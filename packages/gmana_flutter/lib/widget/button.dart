import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';

/// Variant style options for [GButton].
enum GButtonVariant {
  /// Filled background with primary brand color.
  primary,

  /// Secondary filled background.
  secondary,

  /// Outlined border without filled background.
  outline,

  /// Text-only button without background or border.
  text,
}

/// A flexible, theme-aware button widget supporting variants, icons, and loading states.
class GButton extends StatelessWidget {
  /// The text label displayed on the button.
  final String label;

  /// Callback executed when the button is pressed. If `null` or [isLoading] is true, disabled.
  final VoidCallback? onPressed;

  /// Visual variant style (defaults to [GButtonVariant.primary]).
  final GButtonVariant variant;

  /// Whether to display a loading spinner in place of/alongside content.
  final bool isLoading;

  /// Optional leading icon widget.
  final Widget? icon;

  /// Whether the button expands to fill available horizontal width.
  final bool fullWidth;

  /// Custom background color override.
  final Color? backgroundColor;

  /// Custom foreground/text color override.
  final Color? foregroundColor;

  /// Custom border radius (defaults to 8.0).
  final double borderRadius;

  /// Padding surrounding the button content.
  final EdgeInsetsGeometry? padding;

  /// Creates a [GButton] with [label] and optional callbacks & icons.
  const GButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = GButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 8.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    final Widget buttonContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(context, isEnabled),
              ),
            ),
          ),
          GSpacing.hSpace(GSpacing.sm),
        ] else if (icon != null) ...[
          icon!,
          GSpacing.hSpace(GSpacing.sm),
        ],
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );

    final effectivePadding =
        padding ??
        GSpacing.paddingSymmetric(
          horizontal: GSpacing.lg,
          vertical: GSpacing.md,
        );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    Widget result;
    switch (variant) {
      case GButtonVariant.primary:
        result = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? GColors.primary,
            foregroundColor: foregroundColor ?? Colors.white,
            padding: effectivePadding,
            shape: shape,
            elevation: 0,
          ),
          child: buttonContent,
        );

      case GButtonVariant.secondary:
        result = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
            foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
            padding: effectivePadding,
            shape: shape,
            elevation: 0,
          ),
          child: buttonContent,
        );

      case GButtonVariant.outline:
        result = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            padding: effectivePadding,
            shape: shape,
            side: BorderSide(
              color: foregroundColor ?? theme.colorScheme.primary,
            ),
          ),
          child: buttonContent,
        );

      case GButtonVariant.text:
        result = TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            padding: effectivePadding,
            shape: shape,
          ),
          child: buttonContent,
        );
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: result);
    }

    return result;
  }

  Color _getForegroundColor(BuildContext context, bool isEnabled) {
    if (foregroundColor != null) return foregroundColor!;
    final theme = Theme.of(context);
    switch (variant) {
      case GButtonVariant.primary:
        return Colors.white;
      case GButtonVariant.secondary:
        return theme.colorScheme.onSurface;
      case GButtonVariant.outline:
      case GButtonVariant.text:
        return theme.colorScheme.primary;
    }
  }
}
