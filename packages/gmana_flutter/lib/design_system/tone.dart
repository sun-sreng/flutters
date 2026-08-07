import 'package:flutter/material.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart'
    show ColorExt;

import 'colors.dart';

/// Semantic intent shared by the status-carrying widgets.
///
/// This is what finally puts the `GColors` semantic tokens (`success`,
/// `warning`, `info`, `error` and their containers) to work behind a single
/// vocabulary, so a badge, a banner, and a chip all agree on what "warning"
/// looks like.
enum GTone {
  /// No particular status — falls back to surface colors.
  neutral,

  /// Brand emphasis.
  primary,

  /// Informational, non-blocking.
  info,

  /// Positive outcome.
  success,

  /// Needs attention but is not a failure.
  warning,

  /// Failure or destructive outcome.
  error,
}

/// The four colors a [GTone] resolves to for the current theme.
@immutable
class GToneScheme {
  /// Solid, high-emphasis color — filled backgrounds and icons.
  final Color accent;

  /// Readable color on top of [accent].
  final Color onAccent;

  /// Low-emphasis tinted background.
  final Color container;

  /// Readable color on top of [container].
  final Color onContainer;

  /// Creates a resolved tone scheme.
  const GToneScheme({
    required this.accent,
    required this.onAccent,
    required this.container,
    required this.onContainer,
  });
}

/// Resolves a [GTone] against the ambient theme.
extension GToneX on GTone {
  /// The default icon associated with this tone.
  IconData get icon => switch (this) {
    GTone.neutral => Icons.info_outline,
    GTone.primary => Icons.star_outline,
    GTone.info => Icons.info_outline,
    GTone.success => Icons.check_circle_outline,
    GTone.warning => Icons.warning_amber_outlined,
    GTone.error => Icons.error_outline,
  };

  /// Resolves this tone's colors for the theme in [context].
  ///
  /// Light mode uses the hand-tuned container tokens from [GColors]. Dark
  /// mode derives a tint from [GToneScheme.accent] instead, because the light
  /// containers are far too bright on a dark surface.
  GToneScheme resolve(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (this == GTone.neutral) {
      return GToneScheme(
        accent: scheme.onSurfaceVariant,
        onAccent: scheme.surface,
        container: scheme.surfaceContainerHighest,
        onContainer: scheme.onSurface,
      );
    }

    final accent = switch (this) {
      GTone.primary => scheme.primary,
      GTone.info => GColors.info,
      GTone.success => GColors.success,
      GTone.warning => GColors.warning,
      GTone.error => GColors.error,
      GTone.neutral => scheme.onSurfaceVariant,
    };

    if (isDark) {
      return GToneScheme(
        accent: accent,
        onAccent: accent.contrastText,
        container: Color.alphaBlend(
          accent.withValues(alpha: 0.22),
          scheme.surface,
        ),
        onContainer: Color.lerp(accent, Colors.white, 0.62)!,
      );
    }

    final container = switch (this) {
      GTone.primary => scheme.primaryContainer,
      GTone.info => GColors.infoContainer,
      GTone.success => GColors.successContainer,
      GTone.warning => GColors.warningContainer,
      GTone.error => GColors.errorContainer,
      GTone.neutral => scheme.surfaceContainerHighest,
    };

    final onContainer = switch (this) {
      GTone.primary => scheme.onPrimaryContainer,
      GTone.info => GColors.onInfoContainer,
      GTone.success => GColors.onSuccessContainer,
      GTone.warning => GColors.onWarningContainer,
      GTone.error => GColors.onErrorContainer,
      GTone.neutral => scheme.onSurface,
    };

    return GToneScheme(
      accent: accent,
      onAccent: accent.contrastText,
      container: container,
      onContainer: onContainer,
    );
  }
}
