import 'package:flutter/material.dart';

import '../design_system/radius.dart';
import '../design_system/spacing.dart';
import '../design_system/tone.dart';

/// A compact, tone-aware status label.
///
/// Unlike Flutter's `Chip` this carries no selection or delete affordance by
/// default, and unlike `Badge` it stands on its own rather than overlaying a
/// child — it is the small "Active" / "Overdue" / "Beta" pill that shows up
/// in tables, list rows, and headers.
///
/// ```dart
/// const GTag(label: 'Active', tone: GTone.success);
/// const GTag(label: 'Overdue', tone: GTone.error, filled: true);
/// ```
class GTag extends StatelessWidget {
  /// The text shown inside the tag.
  final String label;

  /// Semantic intent driving the colors (defaults to [GTone.neutral]).
  final GTone tone;

  /// Whether to use the solid accent color instead of the tinted container.
  final bool filled;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether to use the tighter padding and smaller text.
  final bool compact;

  /// Optional tap callback. When non-null the tag becomes interactive.
  final VoidCallback? onTap;

  /// Corner radius (defaults to [GRadius.pill]).
  final double borderRadius;

  /// Creates a status tag.
  const GTag({
    super.key,
    required this.label,
    this.tone = GTone.neutral,
    this.filled = false,
    this.icon,
    this.compact = false,
    this.onTap,
    this.borderRadius = GRadius.pill,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tone.resolve(context);
    final background = filled ? colors.accent : colors.container;
    final foreground = filled ? colors.onAccent : colors.onContainer;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: compact ? 12 : 14, color: foreground),
          SizedBox(width: compact ? GSpacing.xxs : GSpacing.xs),
        ],
        Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );

    final padding = GSpacing.paddingSymmetric(
      horizontal: compact ? GSpacing.xs : GSpacing.sm,
      vertical: compact ? GSpacing.xxs : GSpacing.xs,
    );

    return Semantics(
      label: label,
      button: onTap != null,
      container: true,
      child: Material(
        color: background,
        borderRadius: GRadius.all(borderRadius),
        clipBehavior: Clip.antiAlias,
        child:
            onTap == null
                ? Padding(
                  padding: padding,
                  child: ExcludeSemantics(child: content),
                )
                : InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: padding,
                    child: ExcludeSemantics(child: content),
                  ),
                ),
      ),
    );
  }
}
