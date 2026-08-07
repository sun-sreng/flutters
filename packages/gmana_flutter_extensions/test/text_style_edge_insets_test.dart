import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

/// Keeps the static type nullable so the nullable extension is exercised.
TextStyle? maybeStyle(TextStyle? style) => style;

void main() {
  group('TextStyleX weights', () {
    test('named weights', () {
      expect(const TextStyle().bold.fontWeight, FontWeight.bold);
      expect(const TextStyle().light.fontWeight, FontWeight.w300);
      expect(const TextStyle().regular.fontWeight, FontWeight.w400);
      expect(const TextStyle().medium.fontWeight, FontWeight.w500);
      expect(const TextStyle().semiBold.fontWeight, FontWeight.w600);
      expect(const TextStyle().black.fontWeight, FontWeight.w900);
      expect(
        const TextStyle().withWeight(FontWeight.w200).fontWeight,
        FontWeight.w200,
      );
    });

    test('weights compose with other modifiers', () {
      final style = const TextStyle().semiBold.italic.withFontSize(14);

      expect(style.fontWeight, FontWeight.w600);
      expect(style.fontStyle, FontStyle.italic);
      expect(style.fontSize, 14);
    });
  });

  group('TextStyleX decoration', () {
    test('underline and lineThrough', () {
      expect(const TextStyle().underline.decoration, TextDecoration.underline);
      expect(
        const TextStyle().lineThrough.decoration,
        TextDecoration.lineThrough,
      );
    });

    test('noDecoration clears it', () {
      expect(
        const TextStyle().underline.noDecoration.decoration,
        TextDecoration.none,
      );
    });

    test('withDecoration carries styling', () {
      final style = const TextStyle().withDecoration(
        TextDecoration.underline,
        color: const Color(0xFFFF0000),
        style: TextDecorationStyle.dashed,
        thickness: 2,
      );

      expect(style.decoration, TextDecoration.underline);
      expect(style.decorationColor, const Color(0xFFFF0000));
      expect(style.decorationStyle, TextDecorationStyle.dashed);
      expect(style.decorationThickness, 2);
    });
  });

  group('TextStyleX metrics', () {
    test('height, spacing, and family', () {
      expect(const TextStyle().withHeight(1.5).height, 1.5);
      expect(const TextStyle().withLetterSpacing(2).letterSpacing, 2);
      expect(const TextStyle().withWordSpacing(3).wordSpacing, 3);
      expect(const TextStyle().withFamily('Roboto').fontFamily, 'Roboto');
    });

    test('scaled multiplies an explicit size', () {
      expect(const TextStyle(fontSize: 10).scaled(2).fontSize, 20);
      expect(const TextStyle(fontSize: 10).scaled(0.5).fontSize, 5);
    });

    test('scaled leaves an inherited size alone', () {
      const style = TextStyle(fontWeight: FontWeight.bold);

      expect(style.scaled(2).fontSize, isNull);
      expect(style.scaled(2), same(style));
    });

    test('scaled rejects a negative factor', () {
      expect(
        () => const TextStyle(fontSize: 10).scaled(-1),
        throwsArgumentError,
      );
    });
  });

  group('TextStyleX color', () {
    test('withColor replaces the color', () {
      expect(
        const TextStyle().withColor(const Color(0xFF00FF00)).color,
        const Color(0xFF00FF00),
      );
    });

    test('withAlphaOpacity applies to the existing color', () {
      final style = const TextStyle(
        color: Color(0xFFFF0000),
      ).withAlphaOpacity(0.5);

      expect(style.color!.a, closeTo(0.5, 0.01));
      expect(style.color!.r, closeTo(1, 0.01));
    });

    test('withAlphaOpacity falls back to black when there is no color', () {
      final style = const TextStyle().withAlphaOpacity(0.5);

      expect(style.color, isNotNull);
      expect(style.color!.a, closeTo(0.5, 0.01));
      expect(style.color!.r, 0);
    });

    test('withAlphaOpacity validates its range', () {
      expect(
        () => const TextStyle().withAlphaOpacity(-0.1),
        throwsArgumentError,
      );
      expect(
        () => const TextStyle().withAlphaOpacity(1.1),
        throwsArgumentError,
      );
    });

    test('withShadow attaches a single shadow', () {
      final style = const TextStyle().withShadow(blurRadius: 4);

      expect(style.shadows, hasLength(1));
      expect(style.shadows!.single.blurRadius, 4);
    });
  });

  group('TextStyleNullableX', () {
    test('orDefault substitutes an empty style', () {
      const TextStyle? missing = null;

      expect(missing.orDefault, const TextStyle());
      expect(missing.orDefault.semiBold.fontWeight, FontWeight.w600);
    });

    test('orDefault passes a real style through', () {
      const style = TextStyle(fontSize: 12);
      expect(style.orDefault, style);
    });

    test('map only runs for a non-null style', () {
      const TextStyle? missing = null;
      final present = maybeStyle(const TextStyle(fontSize: 10));

      expect(missing.map((s) => s.bold), isNull);
      expect(present.map((s) => s.bold)?.fontWeight, FontWeight.bold);
    });
  });

  group('EdgeInsetsX existing helpers', () {
    test('single-side replacement', () {
      const base = EdgeInsets.all(10);

      expect(base.withTop(1).top, 1);
      expect(base.withBottom(2).bottom, 2);
      expect(base.withLeft(3).left, 3);
      expect(base.withRight(4).right, 4);
      expect(base.withTop(1).left, 10);
    });

    test('axis totals', () {
      const insets = EdgeInsets.fromLTRB(1, 2, 3, 4);

      expect(insets.horizontalInsets, 4);
      expect(insets.verticalInsets, 6);
    });
  });

  group('EdgeInsetsX additions', () {
    test('isZero', () {
      expect(EdgeInsets.zero.isZero, isTrue);
      expect(const EdgeInsets.only(top: 0.1).isZero, isFalse);
    });

    test('largestSide', () {
      expect(const EdgeInsets.fromLTRB(1, 9, 3, 4).largestSide, 9);
      expect(EdgeInsets.zero.largestSide, 0);
    });

    test('horizontalOnly and verticalOnly zero the other axis', () {
      const insets = EdgeInsets.fromLTRB(1, 2, 3, 4);

      expect(insets.horizontalOnly, const EdgeInsets.only(left: 1, right: 3));
      expect(insets.verticalOnly, const EdgeInsets.only(top: 2, bottom: 4));
    });

    test('scaled multiplies every side', () {
      expect(const EdgeInsets.all(8).scaled(1.5), const EdgeInsets.all(12));
      expect(const EdgeInsets.all(8).scaled(0), EdgeInsets.zero);
      expect(() => const EdgeInsets.all(8).scaled(-1), throwsArgumentError);
    });

    test('grown and shrunk clamp at zero', () {
      expect(const EdgeInsets.all(4).grown(4), const EdgeInsets.all(8));
      expect(const EdgeInsets.all(4).shrunk(2), const EdgeInsets.all(2));
      expect(const EdgeInsets.all(4).shrunk(10), EdgeInsets.zero);
    });

    test('mergeMax takes the larger of each side', () {
      const design = EdgeInsets.all(16);
      const safeArea = EdgeInsets.only(top: 44, bottom: 8);

      expect(
        design.mergeMax(safeArea),
        const EdgeInsets.fromLTRB(16, 44, 16, 16),
      );
    });
  });
}
