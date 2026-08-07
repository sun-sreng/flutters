import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

/// Resolves [tone] inside a real theme so `Theme.of` works.
Future<GToneScheme> resolveTone(
  WidgetTester tester,
  GTone tone, {
  required Brightness brightness,
}) async {
  late GToneScheme resolved;

  await tester.pumpWidget(
    MaterialApp(
      theme:
          brightness == Brightness.dark
              ? GColors.darkTheme
              : GColors.lightTheme,
      home: Builder(
        builder: (context) {
          resolved = tone.resolve(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );

  return resolved;
}

void main() {
  group('GToneX.icon', () {
    test('every tone has a distinct enough default icon', () {
      expect(GTone.success.icon, Icons.check_circle_outline);
      expect(GTone.warning.icon, Icons.warning_amber_outlined);
      expect(GTone.error.icon, Icons.error_outline);
      expect(GTone.info.icon, Icons.info_outline);
    });
  });

  group('GToneX.resolve in light mode', () {
    testWidgets('semantic tones use the hand-tuned GColors tokens', (
      tester,
    ) async {
      final error = await resolveTone(
        tester,
        GTone.error,
        brightness: Brightness.light,
      );
      expect(error.accent, GColors.error);
      expect(error.container, GColors.errorContainer);
      expect(error.onContainer, GColors.onErrorContainer);

      final success = await resolveTone(
        tester,
        GTone.success,
        brightness: Brightness.light,
      );
      expect(success.accent, GColors.success);
      expect(success.container, GColors.successContainer);
    });

    testWidgets('neutral falls back to surface colors', (tester) async {
      final neutral = await resolveTone(
        tester,
        GTone.neutral,
        brightness: Brightness.light,
      );
      final scheme = GColors.lightTheme.colorScheme;

      expect(neutral.accent, scheme.onSurfaceVariant);
      expect(neutral.container, scheme.surfaceContainerHighest);
      expect(neutral.onContainer, scheme.onSurface);
    });

    testWidgets('primary follows the theme, not a hard-coded brand color', (
      tester,
    ) async {
      final primary = await resolveTone(
        tester,
        GTone.primary,
        brightness: Brightness.light,
      );

      expect(primary.accent, GColors.lightTheme.colorScheme.primary);
    });
  });

  group('GToneX.resolve in dark mode', () {
    testWidgets('containers are derived, not the bright light tokens', (
      tester,
    ) async {
      final error = await resolveTone(
        tester,
        GTone.error,
        brightness: Brightness.dark,
      );

      expect(error.accent, GColors.error);
      expect(error.container, isNot(GColors.errorContainer));
    });

    testWidgets('the derived container stays dark', (tester) async {
      for (final tone in [GTone.info, GTone.success, GTone.warning]) {
        final resolved = await resolveTone(
          tester,
          tone,
          brightness: Brightness.dark,
        );

        expect(
          ThemeData.estimateBrightnessForColor(resolved.container),
          Brightness.dark,
          reason: '$tone container should stay dark in dark mode',
        );
      }
    });

    testWidgets('onContainer contrasts with the container', (tester) async {
      for (final tone in GTone.values) {
        final resolved = await resolveTone(
          tester,
          tone,
          brightness: Brightness.dark,
        );

        expect(
          ThemeData.estimateBrightnessForColor(resolved.onContainer),
          isNot(ThemeData.estimateBrightnessForColor(resolved.container)),
          reason: '$tone text should contrast with its container',
        );
      }
    });
  });
}
