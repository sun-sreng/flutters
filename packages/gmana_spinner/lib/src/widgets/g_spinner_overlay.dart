import 'package:flutter/material.dart';

import '../theme/g_spinner_theme.dart';
import 'g_circular_spinner.dart';

/// Covers [child] with a scrim and a centered spinner while [isLoading].
///
/// The usual reason to reach for a spinner is to block a screen during a save
/// or a fetch, which needs three things that are easy to get wrong
/// individually: the content must stay laid out (so nothing jumps when the
/// spinner clears), input must actually be blocked, and assistive technology
/// must be told the screen is busy.
///
/// ```dart
/// GSpinnerOverlay(
///   isLoading: _saving,
///   semanticsLabel: 'Saving',
///   child: MyForm(),
/// )
/// ```
class GSpinnerOverlay extends StatelessWidget {
  /// Whether the overlay is shown.
  final bool isLoading;

  /// The content underneath.
  final Widget child;

  /// The indicator to center. Defaults to a [GCircularSpinner].
  final Widget? spinner;

  /// Scrim color drawn over [child].
  ///
  /// Defaults to the theme's scrim at 46% opacity.
  final Color? barrierColor;

  /// Whether the scrim swallows pointer events.
  ///
  /// Leave this `true` unless the content behind must stay interactive — a
  /// visible-but-clickable overlay invites double submissions.
  final bool blockInteraction;

  /// Optional message shown under the spinner.
  final Widget? message;

  /// Screen-reader label announced while the overlay is up.
  ///
  /// Falls back to [GSpinnerTheme.semanticsLabel]. When neither is set the
  /// overlay still blocks input, but goes unannounced.
  final String? semanticsLabel;

  /// How long the overlay takes to fade in and out.
  final Duration fadeDuration;

  /// Creates a loading overlay around [child].
  const GSpinnerOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.spinner,
    this.barrierColor,
    this.blockInteraction = true,
    this.message,
    this.semanticsLabel,
    this.fadeDuration = const Duration(milliseconds: 150),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // `ExcludeSemantics` rather than swapping the child out: the content
        // stays laid out so nothing reflows when loading ends, while a screen
        // reader stops wandering into controls the scrim has disabled.
        ExcludeSemantics(excluding: isLoading, child: child),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: fadeDuration,
            // An empty SizedBox has no child to hit-test and does not
            // hit-test itself, so the idle overlay layer is transparent to
            // pointers even though Positioned.fill stretches it.
            child: isLoading ? _buildBarrier(context) : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildBarrier(BuildContext context) {
    final scrim =
        barrierColor ??
        Theme.of(context).colorScheme.scrim.withValues(alpha: 0.46);
    final label = GSpinnerTheme.resolveSemanticsLabel(context, semanticsLabel);

    Widget barrier = ColoredBox(
      color: scrim,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The overlay already carries the label. Without this the inner
            // spinner picks up the same `GSpinnerTheme.semanticsLabel` and a
            // screen reader announces it twice.
            ExcludeSemantics(child: spinner ?? const GCircularSpinner()),
            if (message != null) ...[const SizedBox(height: 16), message!],
          ],
        ),
      ),
    );

    // AbsorbPointer stops the hit test at the scrim; IgnorePointer lets it
    // continue past to the content. `ColoredBox` alone does neither
    // dependably, so the intent is stated explicitly in both directions.
    barrier =
        blockInteraction
            ? AbsorbPointer(child: barrier)
            : IgnorePointer(child: barrier);

    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: barrier,
    );
  }
}
