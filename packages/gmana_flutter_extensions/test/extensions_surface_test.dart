import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

void main() {
  group('color extensions', () {
    test('parse and serialize hex colors', () {
      final color = '#F50'.toColor();

      expect(color.toARGB32(), const Color(0xFFFF5500).toARGB32());
      expect(color.toHexRGB(), '#FF5500');
      expect(color.toHexARGB(), '#FFFF5500');
      expect(ColorService.tryParseHex('#80FF5500')?.toARGB32(), 0x80FF5500);
    });

    test('validate color amounts', () {
      expect(() => Colors.orange.lighten(-0.1), throwsArgumentError);
      expect(() => '#FF5500'.toColorWithOpacity(2), throwsArgumentError);
      expect(() => 'not-a-color'.toColor(), throwsFormatException);
    });
  });

  group('responsive extensions', () {
    test('resolve breakpoints from constraints', () {
      const mobile = BoxConstraints(maxWidth: 600);
      const tablet = BoxConstraints(maxWidth: 900);
      const desktop = BoxConstraints(maxWidth: 1300);
      const widescreen = BoxConstraints(maxWidth: 1700);

      expect(mobile.breakpoint, Breakpoint.mobile);
      expect(tablet.breakpoint, Breakpoint.tablet);
      expect(desktop.breakpoint, Breakpoint.desktop);
      expect(widescreen.breakpoint, Breakpoint.widescreen);
      expect(desktop.resolve(mobile: 1, tablet: 2, desktop: 3), 3);
    });

    testWidgets('resolve breakpoints from context', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedContext.breakpoint, Breakpoint.tablet);
      expect(capturedContext.responsive(mobile: 'm', tablet: 't', desktop: 'd'), 't');
    });
  });

  group('theme mode extensions', () {
    test('convert between storage keys and theme modes', () {
      expect(ThemeModeService.fromKey('dark'), ThemeMode.dark);
      expect(ThemeModeService.getKey(ThemeMode.light), 'light');
      expect('system'.toThemeMode(), ThemeMode.system);
      expect(ThemeMode.dark.toLabel(), 'Dark Mode');
    });
  });

  group('icon serialization', () {
    test('round trips icon data', () {
      const source = Icons.home;
      final restored = IconDataExt.parse(source.toJsonString());

      expect(restored.codePoint, source.codePoint);
      expect(restored.fontFamily, source.fontFamily);
    });
  });

  group('time extensions', () {
    test('format time of day', () {
      expect(const TimeOfDay(hour: 13, minute: 5).toCustomString(), '01:05 PM');
    });
  });
}
