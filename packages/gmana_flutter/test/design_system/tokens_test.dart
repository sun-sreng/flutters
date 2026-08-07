import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('GRadius', () {
    test('scale is ordered and starts at zero', () {
      expect(GRadius.none, 0);
      expect(GRadius.xs, lessThan(GRadius.sm));
      expect(GRadius.sm, lessThan(GRadius.md));
      expect(GRadius.md, lessThan(GRadius.lg));
      expect(GRadius.lg, lessThan(GRadius.xl));
      expect(GRadius.xl, lessThan(GRadius.pill));
    });

    test('all builds a uniform BorderRadius', () {
      expect(GRadius.all(), BorderRadius.circular(GRadius.md));
      expect(GRadius.all(GRadius.xs), BorderRadius.circular(4));
    });

    test('top and bottom only round one edge', () {
      final top = GRadius.top(8);
      expect(top.topLeft, const Radius.circular(8));
      expect(top.bottomLeft, Radius.zero);

      final bottom = GRadius.bottom(8);
      expect(bottom.bottomRight, const Radius.circular(8));
      expect(bottom.topRight, Radius.zero);
    });

    test('start and end are direction-aware', () {
      final start = GRadius.start(8);
      expect(
        start.resolve(TextDirection.ltr).topLeft,
        const Radius.circular(8),
      );
      expect(
        start.resolve(TextDirection.rtl).topRight,
        const Radius.circular(8),
      );
    });

    test('shape helpers produce rounded rectangles', () {
      expect(GRadius.shape(8).borderRadius, BorderRadius.circular(8));
      expect(GRadius.shape(8).side, BorderSide.none);

      const side = BorderSide(color: Color(0xFF000000));
      expect(GRadius.outlinedShape(side, 8).side, side);
    });
  });

  group('GMotion', () {
    test('durations are ordered', () {
      expect(GMotion.instant, Duration.zero);
      expect(GMotion.xfast, lessThan(GMotion.fast));
      expect(GMotion.fast, lessThan(GMotion.normal));
      expect(GMotion.normal, lessThan(GMotion.slow));
      expect(GMotion.slow, lessThan(GMotion.xslow));
    });

    test('curves are defined', () {
      expect(GMotion.standard, isA<Curve>());
      expect(GMotion.enter, isA<Curve>());
      expect(GMotion.exit, isA<Curve>());
      expect(GMotion.emphasized, isA<Curve>());
    });
  });

  group('GSpacing additions', () {
    test('paddingOnly sets individual sides', () {
      expect(
        GSpacing.paddingOnly(left: 4, bottom: 8),
        const EdgeInsets.only(left: 4, bottom: 8),
      );
      expect(GSpacing.paddingOnly(), EdgeInsets.zero);
    });

    test('paddingDirectional mirrors under RTL', () {
      final padding = GSpacing.paddingDirectional(start: 12, end: 4);

      expect(
        padding.resolve(TextDirection.ltr),
        const EdgeInsets.only(left: 12, right: 4),
      );
      expect(
        padding.resolve(TextDirection.rtl),
        const EdgeInsets.only(left: 4, right: 12),
      );
    });
  });
}
