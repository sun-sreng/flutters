import 'package:flutter/material.dart';

import '../design_system/spacing.dart';

/// A centered placeholder for "nothing here yet" and "nothing matched"
/// screens.
///
/// Flutter has no primitive for this, so every app reinvents the same
/// icon + title + message + action column. This is that column, with
/// consistent spacing and accessible semantics.
///
/// ```dart
/// GEmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No messages',
///   message: 'When someone writes to you it will show up here.',
///   action: GButton(label: 'Refresh', onPressed: reload),
/// );
/// ```
class GEmptyState extends StatelessWidget {
  /// Icon shown above the title. Ignored when [illustration] is supplied.
  final IconData icon;

  /// Optional custom artwork replacing the default [icon].
  final Widget? illustration;

  /// Short headline describing the empty condition.
  final String title;

  /// Optional supporting sentence.
  final String? message;

  /// Optional call to action, typically a button.
  final Widget? action;

  /// Outer padding (defaults to `GSpacing.xlg` on all sides).
  final EdgeInsetsGeometry? padding;

  /// Whether to use tighter spacing and a smaller icon.
  final bool compact;

  /// Icon color (defaults to the theme's `onSurfaceVariant`).
  final Color? iconColor;

  /// Creates an empty-state placeholder.
  const GEmptyState({
    super.key,
    required this.title,
    this.icon = Icons.inbox_outlined,
    this.illustration,
    this.message,
    this.action,
    this.padding,
    this.compact = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.onSurfaceVariant;
    final gap = compact ? GSpacing.sm : GSpacing.md;

    return Semantics(
      container: true,
      label: message == null ? title : '$title. $message',
      child: Padding(
        padding: padding ?? GSpacing.paddingAll(GSpacing.xlg),
        child: Center(
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                illustration ??
                    Icon(
                      icon,
                      size: compact ? 40 : 64,
                      color: effectiveIconColor,
                    ),
                SizedBox(height: gap),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: (compact
                          ? theme.textTheme.titleSmall
                          : theme.textTheme.titleMedium)
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (message != null) ...[
                  const SizedBox(height: GSpacing.xs),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (action != null) ...[
                  SizedBox(height: compact ? GSpacing.md : GSpacing.lg),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
