import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

const _pureRed = Color(0xFFFF0000);
const _brand = Color(0xFFF57224);

void main() {
  group('ColorService.tryParseHex', () {
    test('accepts the three supported lengths', () {
      expect(ColorService.tryParseHex('#F50')?.toARGB32(), 0xFFFF5500);
      expect(ColorService.tryParseHex('#FF5500')?.toARGB32(), 0xFFFF5500);
      expect(ColorService.tryParseHex('#80FF5500')?.toARGB32(), 0x80FF5500);
    });

    test('the hash prefix is optional', () {
      expect(ColorService.tryParseHex('FF5500')?.toARGB32(), 0xFFFF5500);
    });

    test('returns null for anything else', () {
      expect(ColorService.tryParseHex(''), isNull);
      expect(ColorService.tryParseHex('#FF55'), isNull);
      expect(ColorService.tryParseHex('#GGGGGG'), isNull);
      expect(ColorService.tryParseHex('not-a-color'), isNull);
    });

    test('String.toColor throws where tryParseHex returns null', () {
      expect(() => 'not-a-color'.toColor(), throwsFormatException);
      expect('#F50'.toColor().toARGB32(), 0xFFFF5500);
    });

    test('toColorWithOpacity validates its range', () {
      expect('#FF5500'.toColorWithOpacity(0.5).a, closeTo(0.5, 0.01));
      expect(() => '#FF5500'.toColorWithOpacity(2), throwsArgumentError);
      expect(() => '#FF5500'.toColorWithOpacity(-1), throwsArgumentError);
    });
  });

  group('ColorExt hex output', () {
    test('toHexRGB drops alpha, toHexARGB keeps it', () {
      expect(const Color(0x80FF5500).toHexRGB(), '#FF5500');
      expect(const Color(0x80FF5500).toHexARGB(), '#80FF5500');
    });

    test('the hash sign is optional', () {
      expect(_brand.toHexRGB(withHashSign: false), 'F57224');
      expect(_brand.toHexARGB(withHashSign: false), 'FFF57224');
    });

    test('toCssRgba renders channels and alpha', () {
      expect(const Color(0xFFFF5500).toCssRgba(), 'rgba(255, 85, 0, 1.00)');
      expect(const Color(0x80FF5500).toCssRgba(), 'rgba(255, 85, 0, 0.50)');
      expect(
        const Color(0xFFFF5500).toCssRgba(alphaPrecision: 0),
        'rgba(255, 85, 0, 1)',
      );
    });

    test('toCssRgba rejects a negative precision', () {
      expect(() => _brand.toCssRgba(alphaPrecision: -1), throwsArgumentError);
    });
  });

  group('ColorExt HSL accessors', () {
    test('reads hue, saturation, and lightness', () {
      expect(_pureRed.hue, closeTo(0, 0.001));
      expect(_pureRed.saturation, closeTo(1, 0.001));
      expect(_pureRed.lightness, closeTo(0.5, 0.001));
    });

    test('withHue rotates around the wheel', () {
      expect(_pureRed.withHue(120).toARGB32(), 0xFF00FF00);
      expect(_pureRed.withHue(240).toARGB32(), 0xFF0000FF);
    });

    test('withHue wraps values beyond 360', () {
      expect(
        _pureRed.withHue(480).toARGB32(),
        _pureRed.withHue(120).toARGB32(),
      );
    });

    test('withSaturation and withLightness clamp their input', () {
      expect(_pureRed.withSaturation(0).saturation, closeTo(0, 0.001));
      expect(_pureRed.withSaturation(5).saturation, closeTo(1, 0.001));
      expect(_pureRed.withLightness(0).toARGB32(), 0xFF000000);
      expect(_pureRed.withLightness(1).toARGB32(), 0xFFFFFFFF);
      expect(_pureRed.withLightness(-2).toARGB32(), 0xFF000000);
    });
  });

  group('ColorExt alpha', () {
    test('isTransparent and isOpaque', () {
      expect(const Color(0x00FF5500).isTransparent, isTrue);
      expect(_brand.isTransparent, isFalse);
      expect(_brand.isOpaque, isTrue);
      expect(const Color(0x80FF5500).isOpaque, isFalse);
    });

    test('opaque restores full alpha', () {
      expect(const Color(0x00FF5500).opaque.a, 1);
      expect(const Color(0x00FF5500).opaque.toHexRGB(), '#FF5500');
    });

    test('withAlphaOpacity validates its range', () {
      expect(_brand.withAlphaOpacity(0.5).a, closeTo(0.5, 0.01));
      expect(() => _brand.withAlphaOpacity(1.5), throwsArgumentError);
      expect(() => _brand.withAlphaOpacity(double.nan), throwsArgumentError);
    });
  });

  group('ColorExt harmonies', () {
    test('complementary is the opposite hue', () {
      expect(_pureRed.complementary.toARGB32(), 0xFF00FFFF);
    });

    test('triadic returns two colors 120 degrees apart', () {
      final (a, b) = _pureRed.triadic;
      expect(a.hue, closeTo(120, 0.5));
      expect(b.hue, closeTo(240, 0.5));
    });

    test('tetradic returns three colors 90 degrees apart', () {
      final (a, b, c) = _pureRed.tetradic;
      expect(a.hue, closeTo(90, 0.5));
      expect(b.hue, closeTo(180, 0.5));
      expect(c.hue, closeTo(270, 0.5));
    });

    test('splitComplementary straddles the complement', () {
      final (a, b) = _pureRed.splitComplementary;
      expect(a.hue, closeTo(150, 0.5));
      expect(b.hue, closeTo(210, 0.5));
    });

    test('analogous returns 2 * count colors', () {
      expect(_brand.analogous(), hasLength(4));
      expect(_brand.analogous(count: 3), hasLength(6));
      expect(() => _brand.analogous(count: 0), throwsArgumentError);
    });

    test('monochromatic is a same-hue ramp of ascending lightness', () {
      final ramp = _brand.monochromatic();

      expect(ramp, hasLength(5));
      for (var i = 1; i < ramp.length; i++) {
        expect(ramp[i].lightness, greaterThan(ramp[i - 1].lightness));
        expect(ramp[i].hue, closeTo(ramp[0].hue, 0.5));
      }
    });

    test('monochromatic honours count and rejects fewer than two', () {
      expect(_brand.monochromatic(count: 9), hasLength(9));
      expect(() => _brand.monochromatic(count: 1), throwsArgumentError);
    });
  });

  group('ColorExt adjustments', () {
    test('lighten and darken move lightness', () {
      expect(_brand.lighten(0.2).lightness, greaterThan(_brand.lightness));
      expect(_brand.darken(0.2).lightness, lessThan(_brand.lightness));
    });

    test('saturate and desaturate move saturation', () {
      expect(_brand.desaturate(0.3).saturation, lessThan(_brand.saturation));
      expect(
        _brand.desaturate(0.3).saturate(0.3).saturation,
        closeTo(_brand.saturation, 0.01),
      );
    });

    test('greyscale removes all saturation', () {
      expect(_brand.greyscale.saturation, closeTo(0, 0.001));
    });

    test('adjustments reject out-of-range amounts', () {
      expect(() => _brand.lighten(-0.1), throwsArgumentError);
      expect(() => _brand.darken(1.5), throwsArgumentError);
      expect(() => _brand.saturate(double.nan), throwsArgumentError);
    });

    test('mix, tint, and shade interpolate', () {
      expect(
        ColorService.mix(_pureRed, const Color(0xFF0000FF)).toARGB32(),
        Color.lerp(_pureRed, const Color(0xFF0000FF), 0.5)!.toARGB32(),
      );
      expect(_pureRed.tint(1).toARGB32(), 0xFFFFFFFF);
      expect(_pureRed.shade(1).toARGB32(), 0xFF000000);
      expect(() => _pureRed.mix(Colors.blue, 2), throwsArgumentError);
    });
  });

  group('ColorExt contrast', () {
    test('contrastRatio peaks at 21 for black on white', () {
      expect(
        const Color(0xFFFFFFFF).contrastRatio(const Color(0xFF000000)),
        closeTo(21, 0.01),
      );
      expect(_brand.contrastRatio(_brand), closeTo(1, 0.001));
    });

    test('WCAG thresholds', () {
      const white = Color(0xFFFFFFFF);
      const black = Color(0xFF000000);

      expect(white.meetsWcagAA(black), isTrue);
      expect(white.meetsWcagAAA(black), isTrue);
      expect(white.meetsWcagAA(const Color(0xFFEEEEEE)), isFalse);
    });

    test('isDark and isLight are complementary', () {
      expect(const Color(0xFF000000).isDark, isTrue);
      expect(const Color(0xFF000000).isLight, isFalse);
      expect(const Color(0xFFFFFFFF).isLight, isTrue);
    });

    test('bestContrast picks the readable candidate', () {
      expect(const Color(0xFFFFFFFF).contrastText.toARGB32(), 0xFF000000);
      expect(const Color(0xFF000000).contrastText.toARGB32(), 0xFFFFFFFF);
    });

    test('bestContrast honours a custom candidate list', () {
      const candidates = [Color(0xFF888888), Color(0xFF000000)];
      expect(
        const Color(0xFFFFFFFF).bestContrast(candidates).toARGB32(),
        0xFF000000,
      );
    });

    test('bestContrast rejects an empty candidate list', () {
      expect(() => _brand.bestContrast(const []), throwsArgumentError);
    });
  });

  group('ColorService.createMaterialColor', () {
    test('shade 500 is the input color', () {
      final swatch = _brand.toMaterialColor();
      expect(swatch[500]!.toARGB32(), _brand.toARGB32());
    });

    test('shades run light to dark', () {
      final swatch = _brand.toMaterialColor();
      expect(swatch[50]!.lightness, greaterThan(swatch[500]!.lightness));
      expect(swatch[900]!.lightness, lessThan(swatch[500]!.lightness));
    });
  });
}
