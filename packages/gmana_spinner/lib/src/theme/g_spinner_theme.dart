import 'package:flutter/material.dart';

/// Application-wide defaults for every spinner in this package.
///
/// Install it on your [ThemeData] and stop repeating `color:` at each call
/// site:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: const [
///       GSpinnerTheme(color: Colors.teal, semanticsLabel: 'Loading'),
///     ],
///   ),
/// )
/// ```
///
/// Every spinner resolves each value in the same order: the argument passed to
/// the widget, then this extension, then the widget's own default. Adding the
/// extension therefore never changes a call site that was already explicit.
@immutable
class GSpinnerTheme extends ThemeExtension<GSpinnerTheme> {
  /// Default primary color for spinners.
  ///
  /// Falls back to `ColorScheme.primary` for the animated spinners, and to the
  /// legacy purple for `GCircularSpinner` and `GLinearSpinner`.
  final Color? color;

  /// Default secondary color, used by the spinners that draw two elements.
  final Color? secondaryColor;

  /// Default screen-reader label announced for a running spinner.
  ///
  /// There is deliberately no built-in default: the text is user-facing, and a
  /// package cannot know the app's language. Set it once here — from your
  /// localizations — and every spinner becomes announceable at once.
  final String? semanticsLabel;

  /// Creates spinner defaults. Every field is optional; a `null` field defers
  /// to the widget's own default.
  const GSpinnerTheme({this.color, this.secondaryColor, this.semanticsLabel});

  /// The nearest [GSpinnerTheme], or `null` when none is installed.
  static GSpinnerTheme? maybeOf(BuildContext context) =>
      Theme.of(context).extension<GSpinnerTheme>();

  /// The nearest [GSpinnerTheme], or an empty one when none is installed.
  ///
  /// Always safe to call — an empty theme resolves every field to `null`, so
  /// each widget falls through to its own default.
  static GSpinnerTheme of(BuildContext context) =>
      maybeOf(context) ?? const GSpinnerTheme();

  /// Resolves a spinner color: [explicit], then this theme, then
  /// `ColorScheme.primary`.
  static Color resolveColor(BuildContext context, Color? explicit) =>
      explicit ??
      maybeOf(context)?.color ??
      Theme.of(context).colorScheme.primary;

  /// Resolves a secondary color: [explicit], then this theme, then [fallback].
  static Color resolveSecondaryColor(
    BuildContext context,
    Color? explicit,
    Color fallback,
  ) => explicit ?? maybeOf(context)?.secondaryColor ?? fallback;

  /// Resolves a screen-reader label: [explicit], then this theme.
  ///
  /// `null` means the spinner contributes no semantics node, which is the
  /// behaviour of a bare `CircularProgressIndicator`.
  static String? resolveSemanticsLabel(
    BuildContext context,
    String? explicit,
  ) => explicit ?? maybeOf(context)?.semanticsLabel;

  @override
  GSpinnerTheme copyWith({
    Color? color,
    Color? secondaryColor,
    String? semanticsLabel,
  }) => GSpinnerTheme(
    color: color ?? this.color,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    semanticsLabel: semanticsLabel ?? this.semanticsLabel,
  );

  @override
  GSpinnerTheme lerp(covariant GSpinnerTheme? other, double t) {
    if (other == null) return this;
    return GSpinnerTheme(
      color: Color.lerp(color, other.color, t),
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t),
      // A label is not a continuous quantity, so it switches at the
      // midpoint rather than interpolating.
      semanticsLabel: t < 0.5 ? semanticsLabel : other.semanticsLabel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GSpinnerTheme &&
          other.color == color &&
          other.secondaryColor == secondaryColor &&
          other.semanticsLabel == semanticsLabel;

  @override
  int get hashCode => Object.hash(color, secondaryColor, semanticsLabel);

  @override
  String toString() =>
      'GSpinnerTheme(color: $color, secondaryColor: $secondaryColor, '
      'semanticsLabel: $semanticsLabel)';
}

/// Wraps [child] so assistive technology announces the spinner.
///
/// Returns [child] untouched when no label resolves, so a spinner without a
/// label stays exactly as it was.
Widget wrapSpinnerSemantics({
  required BuildContext context,
  required String? semanticsLabel,
  required Widget child,
}) {
  final label = GSpinnerTheme.resolveSemanticsLabel(context, semanticsLabel);
  if (label == null) return child;
  return Semantics(
    container: true,
    liveRegion: true,
    label: label,
    child: ExcludeSemantics(child: child),
  );
}
