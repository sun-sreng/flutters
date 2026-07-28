import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('Color Utilities', () {
    test('darken produces a darker color', () {
      const color = Colors.blue;
      final darker = darken(color, 0.2);

      final originalHsl = HSLColor.fromColor(color);
      final darkerHsl = HSLColor.fromColor(darker);

      expect(darkerHsl.lightness, lessThan(originalHsl.lightness));
    });

    test('lighten produces a lighter color', () {
      const color = Colors.blue;
      final lighter = lighten(color, 0.2);

      final originalHsl = HSLColor.fromColor(color);
      final lighterHsl = HSLColor.fromColor(lighter);

      expect(lighterHsl.lightness, greaterThan(originalHsl.lightness));
    });
  });
}
