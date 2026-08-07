import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

/// Pumps a probe widget and hands back the BuildContext it was built with.
Future<BuildContext> captureContext(
  WidgetTester tester, {
  ThemeData? theme,
  MediaQueryData? mediaQuery,
}) async {
  late BuildContext captured;

  Widget body = Builder(
    builder: (context) {
      captured = context;
      return const SizedBox.shrink();
    },
  );

  if (mediaQuery != null) {
    body = MediaQuery(data: mediaQuery, child: body);
  }

  await tester.pumpWidget(MaterialApp(theme: theme, home: body));
  // MaterialApp lerps between themes over kThemeAnimationDuration, so a
  // single frame still reports the previous theme when one test pumps twice.
  await tester.pumpAndSettle();
  return captured;
}

void main() {
  group('BrightnessX', () {
    test('isDark and isLight', () {
      expect(Brightness.dark.isDark, isTrue);
      expect(Brightness.dark.isLight, isFalse);
      expect(Brightness.light.isLight, isTrue);
    });

    test('opposite flips', () {
      expect(Brightness.dark.opposite, Brightness.light);
      expect(Brightness.light.opposite, Brightness.dark);
      expect(Brightness.light.opposite.opposite, Brightness.light);
    });

    test('select picks by brightness', () {
      expect(Brightness.dark.select(light: 'L', dark: 'D'), 'D');
      expect(Brightness.light.select(light: 'L', dark: 'D'), 'L');
    });
  });

  group('ThemeDataX', () {
    test('isDark and isLight follow the theme brightness', () {
      expect(ThemeData.dark().isDark, isTrue);
      expect(ThemeData.dark().isLight, isFalse);
      expect(ThemeData.light().isLight, isTrue);
    });

    test('select picks by theme brightness', () {
      expect(ThemeData.dark().select(light: 1, dark: 2), 2);
      expect(ThemeData.light().select(light: 1, dark: 2), 1);
    });
  });

  group('ThemeModeService', () {
    test('key round-trip', () {
      expect(ThemeModeService.fromKey('light'), ThemeMode.light);
      expect(ThemeModeService.getKey(ThemeMode.dark), 'dark');
      expect(ThemeModeService.fromKey('nonsense'), ThemeMode.system);
    });

    test('labels and icons', () {
      expect(ThemeModeService.getLabel(ThemeMode.dark), 'Dark Mode');
      expect(ThemeModeService.getLabelFromKey('light'), 'Light Mode');
      expect(ThemeModeService.getIcon(ThemeMode.dark), Icons.dark_mode);
      expect(ThemeModeService.getIconFromKey('light'), Icons.light_mode);
    });

    test('all and getThemeKeys agree on order', () {
      expect(ThemeModeService.all, [
        ThemeMode.system,
        ThemeMode.light,
        ThemeMode.dark,
      ]);
      expect(ThemeModeService.getThemeKeys(), ['system', 'light', 'dark']);
    });

    test('next cycles through every mode and wraps', () {
      expect(ThemeModeService.next(ThemeMode.system), ThemeMode.light);
      expect(ThemeModeService.next(ThemeMode.light), ThemeMode.dark);
      expect(ThemeModeService.next(ThemeMode.dark), ThemeMode.system);
    });

    test('nextKey mirrors next', () {
      expect(ThemeModeService.nextKey('system'), 'light');
      expect(ThemeModeService.nextKey('dark'), 'system');
    });

    test('isKnownKey separates real keys from fallbacks', () {
      expect(ThemeModeService.isKnownKey('dark'), isTrue);
      expect(ThemeModeService.isKnownKey('Dark'), isFalse);
      expect(ThemeModeService.isKnownKey('nonsense'), isFalse);
    });

    test('resolveBrightness only consults the platform for system', () {
      expect(
        ThemeModeService.resolveBrightness(
          ThemeMode.light,
          platformBrightness: Brightness.dark,
        ),
        Brightness.light,
      );
      expect(
        ThemeModeService.resolveBrightness(
          ThemeMode.system,
          platformBrightness: Brightness.dark,
        ),
        Brightness.dark,
      );
    });
  });

  group('ThemeModeExt', () {
    test('conversions', () {
      expect(ThemeMode.dark.toKey(), 'dark');
      expect(ThemeMode.dark.toLabel(), 'Dark Mode');
      expect(ThemeMode.dark.toIcon(), Icons.dark_mode);
    });

    test('predicates', () {
      expect(ThemeMode.system.isSystem, isTrue);
      expect(ThemeMode.light.isLight, isTrue);
      expect(ThemeMode.dark.isDark, isTrue);
      expect(ThemeMode.dark.isLight, isFalse);
    });

    test('next returns to the start after three steps', () {
      expect(ThemeMode.system.next().next().next(), ThemeMode.system);
    });

    test('resolveBrightness', () {
      expect(
        ThemeMode.system.resolveBrightness(Brightness.dark),
        Brightness.dark,
      );
      expect(
        ThemeMode.light.resolveBrightness(Brightness.dark),
        Brightness.light,
      );
    });
  });

  group('ThemeModeStringExt', () {
    test('conversions', () {
      expect('dark'.toThemeMode(), ThemeMode.dark);
      expect('light'.toThemeLabel(), 'Light Mode');
      expect('dark'.toThemeIcon(), Icons.dark_mode);
    });

    test('nextThemeKey and isThemeKey', () {
      expect('light'.nextThemeKey(), 'dark');
      expect('dark'.isThemeKey, isTrue);
      expect('nope'.isThemeKey, isFalse);
    });
  });

  group('ContextExt theme queries', () {
    testWidgets('isDarkMode follows the ambient theme', (tester) async {
      var context = await captureContext(tester, theme: ThemeData.dark());
      expect(context.isDarkMode, isTrue);
      expect(context.isLightMode, isFalse);
      expect(context.brightness, Brightness.dark);

      context = await captureContext(tester, theme: ThemeData.light());
      expect(context.isLightMode, isTrue);
      expect(context.brightness, Brightness.light);
    });

    testWidgets('byBrightness selects a value', (tester) async {
      var context = await captureContext(tester, theme: ThemeData.dark());
      expect(context.byBrightness(light: 'L', dark: 'D'), 'D');

      context = await captureContext(tester, theme: ThemeData.light());
      expect(context.byBrightness(light: 'L', dark: 'D'), 'L');
    });

    testWidgets('platform predicates read the theme platform', (tester) async {
      var context = await captureContext(
        tester,
        theme: ThemeData(platform: TargetPlatform.iOS),
      );
      expect(context.isIOS, isTrue);
      expect(context.isAndroid, isFalse);
      expect(context.isApplePlatform, isTrue);
      expect(context.isDesktopPlatform, isFalse);

      context = await captureContext(
        tester,
        theme: ThemeData(platform: TargetPlatform.windows),
      );
      expect(context.isDesktopPlatform, isTrue);
      expect(context.isApplePlatform, isFalse);
    });
  });

  group('ContextExt media queries', () {
    testWidgets('keyboardHeight reads the bottom view inset', (tester) async {
      var context = await captureContext(
        tester,
        mediaQuery: const MediaQueryData(size: Size(400, 800)),
      );
      expect(context.keyboardHeight, 0);
      expect(context.isKeyboardVisible, isFalse);

      context = await captureContext(
        tester,
        mediaQuery: const MediaQueryData(
          size: Size(400, 800),
          viewInsets: EdgeInsets.only(bottom: 280),
        ),
      );
      expect(context.keyboardHeight, 280);
      expect(context.isKeyboardVisible, isTrue);
    });

    testWidgets('screen dimensions', (tester) async {
      final context = await captureContext(
        tester,
        mediaQuery: const MediaQueryData(size: Size(400, 800)),
      );

      expect(context.screenWidth, 400);
      expect(context.screenHeight, 800);
      expect(context.shortestSide, 400);
      expect(context.longestSide, 800);
      expect(context.isPortrait, isTrue);
      expect(context.orientation, Orientation.portrait);
    });

    testWidgets('landscape flips the orientation flags', (tester) async {
      final context = await captureContext(
        tester,
        mediaQuery: const MediaQueryData(size: Size(900, 400)),
      );

      expect(context.isLandscape, isTrue);
      expect(context.isPortrait, isFalse);
      expect(context.orientation, Orientation.landscape);
    });

    testWidgets('safe area padding', (tester) async {
      final context = await captureContext(
        tester,
        mediaQuery: const MediaQueryData(
          size: Size(400, 800),
          padding: EdgeInsets.only(top: 44, bottom: 34),
        ),
      );

      expect(context.topSafeArea, 44);
      expect(context.bottomSafeArea, 34);
      expect(context.safeAreaPadding.top, 44);
    });
  });

  group('ContextExt snack bars', () {
    Future<void> pumpWithButton(
      WidgetTester tester,
      void Function(BuildContext context) onPressed,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () => onPressed(context),
                    child: const Text('go'),
                  ),
            ),
          ),
        ),
      );
    }

    testWidgets('showSnackBar renders the message', (tester) async {
      await pumpWithButton(
        tester,
        (context) => context.showSnackBar(message: 'plain'),
      );

      await tester.tap(find.text('go'));
      await tester.pump();

      expect(find.text('plain'), findsOneWidget);
    });

    testWidgets('the semantic variants each render', (tester) async {
      for (final entry
          in <String, void Function(BuildContext)>{
            'ok': (c) => c.showSuccessSnackBar(message: 'ok'),
            'bad': (c) => c.showErrorSnackBar(message: 'bad'),
            'careful': (c) => c.showWarningSnackBar(message: 'careful'),
            'fyi': (c) => c.showInfoSnackBar(message: 'fyi'),
          }.entries) {
        await pumpWithButton(tester, entry.value);
        await tester.tap(find.text('go'));
        await tester.pump();

        expect(find.text(entry.key), findsOneWidget);
      }
    });

    testWidgets('hideSnackBar dismisses the current one', (tester) async {
      late BuildContext captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      captured.showSnackBar(message: 'temporary');
      await tester.pump();
      expect(find.text('temporary'), findsOneWidget);

      captured.hideSnackBar();
      await tester.pumpAndSettle();
      expect(find.text('temporary'), findsNothing);
    });
  });
}
