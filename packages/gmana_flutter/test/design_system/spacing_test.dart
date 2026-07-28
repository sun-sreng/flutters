import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('GSpacing Design Tokens & Helpers', () {
    test('constants have correct numerical proportions', () {
      expect(GSpacing.spaceUnit, equals(16.0));
      expect(GSpacing.sm, equals(8.0));
      expect(GSpacing.md, equals(12.0));
      expect(GSpacing.lg, equals(16.0));
      expect(GSpacing.xlg, equals(24.0));
    });

    test('paddingAll produces uniform EdgeInsets', () {
      expect(GSpacing.paddingAll(GSpacing.lg), equals(const EdgeInsets.all(16.0)));
    });

    test('paddingSymmetric produces symmetric EdgeInsets', () {
      expect(
        GSpacing.paddingSymmetric(horizontal: 10, vertical: 20),
        equals(const EdgeInsets.symmetric(horizontal: 10, vertical: 20)),
      );
    });

    test('vSpace and hSpace return correct SizedBox dimensions', () {
      final v = GSpacing.vSpace(GSpacing.lg);
      final h = GSpacing.hSpace(GSpacing.sm);

      expect(v.height, equals(16.0));
      expect(h.width, equals(8.0));
    });
  });
}
