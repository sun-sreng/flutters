import 'package:flutter/material.dart';

import '../design_system/radius.dart';
import '../design_system/spacing.dart';
import '../design_system/tone.dart';

/// An inline status message.
///
/// `MaterialBanner` is scaffold-owned and full-bleed; this is the lighter
/// inline alert you drop directly into a form or a page section.
///
/// ```dart
/// const GBanner(
///   tone: GTone.warning,
///   title: 'Payment overdue',
///   message: 'Update your card to keep the subscription active.',
/// );
/// ```
class GBanner extends StatelessWidget {
  /// The main body text.
  final String message;

  /// Optional bold headline above [message].
  final String? title;

  /// Semantic intent driving the colors (defaults to [GTone.info]).
  final GTone tone;

  /// Leading icon. Defaults to the tone's own icon; pass `null` via
  /// [showIcon] to hide it entirely.
  final IconData? icon;

  /// Whether to show the leading icon.
  final bool showIcon;

  /// Whether to use the solid accent color instead of the tinted container.
  final bool filled;

  /// Optional dismiss callback. When non-null a close button is shown.
  final VoidCallback? onDismiss;

  /// Optional trailing actions rendered below the text.
  final List<Widget>? actions;

  /// Corner radius (defaults to [GRadius.sm]).
  final double borderRadius;

  /// Inner padding (defaults to `GSpacing.md`).
  final EdgeInsetsGeometry? padding;

  /// Creates an inline banner.
  const GBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = GTone.info,
    this.icon,
    this.showIcon = true,
    this.filled = false,
    this.onDismiss,
    this.actions,
    this.borderRadius = GRadius.sm,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tone.resolve(context);
    final background = filled ? colors.accent : colors.container;
    final foreground = filled ? colors.onAccent : colors.onContainer;

    return Semantics(
      container: true,
      liveRegion: true,
      label: title == null ? message : '$title. $message',
      child: Container(
        width: double.infinity,
        padding: padding ?? GSpacing.paddingAll(GSpacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: GRadius.all(borderRadius),
          border:
              filled
                  ? null
                  : Border.all(color: colors.accent.withValues(alpha: 0.35)),
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showIcon) ...[
                    Icon(icon ?? tone.icon, size: 20, color: foreground),
                    const SizedBox(width: GSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null) ...[
                          Text(
                            title!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: GSpacing.xxs),
                        ],
                        Text(
                          message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDismiss != null) ...[
                    const SizedBox(width: GSpacing.xs),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: foreground,
                      onPressed: onDismiss,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                    ),
                  ],
                ],
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: GSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: GSpacing.sm),
                      actions![i],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
