import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('NumFormatX.toCompact', () {
    test('leaves small magnitudes alone', () {
      expect(0.toCompact(), '0');
      expect(999.toCompact(), '999');
      expect(0.5.toCompact(), '0.5');
    });

    test('abbreviates thousands through trillions', () {
      expect(1000.toCompact(), '1K');
      expect(1234.toCompact(), '1.2K');
      expect(2500000.toCompact(), '2.5M');
      expect(1500000000.toCompact(), '1.5B');
      expect(2500000000000.toCompact(), '2.5T');
    });

    test('keeps the sign', () {
      expect((-4500000).toCompact(), '-4.5M');
    });

    test('honours the decimals argument', () {
      expect(1234.toCompact(decimals: 2), '1.23K');
      expect(1234.toCompact(decimals: 0), '1K');
    });

    test('rejects negative decimals', () {
      expect(() => 1.toCompact(decimals: -1), throwsArgumentError);
    });
  });

  group('NumFormatX.toBytes', () {
    test('uses IEC units by default', () {
      expect(0.toBytes(), '0 B');
      expect(512.toBytes(), '512 B');
      expect(1024.toBytes(), '1 KiB');
      expect(1572864.toBytes(), '1.5 MiB');
    });

    test('uses SI units when binary is false', () {
      expect(1500.toBytes(binary: false), '1.5 kB');
      expect(1000000.toBytes(binary: false), '1 MB');
    });

    test('keeps the sign', () {
      expect((-2048).toBytes(), '-2 KiB');
    });
  });

  group('NumFormatX.toThousands', () {
    test('groups the integer part', () {
      expect(999.toThousands(), '999');
      expect(1234567.toThousands(), '1,234,567');
      expect((-1234567).toThousands(), '-1,234,567');
    });

    test('respects a custom separator', () {
      expect(1234567.toThousands(separator: ' '), '1 234 567');
    });

    test('keeps the fractional part intact', () {
      expect(1234.5.toThousands(), '1,234.5');
      expect(1234.5.toThousands(decimals: 2), '1,234.50');
    });
  });

  group('NumFormatX.toCurrency', () {
    test('prefixes the symbol by default', () {
      expect(1234.5.toCurrency(), r'$1,234.50');
    });

    test('moves the sign outside the symbol', () {
      expect((-9.5).toCurrency(), r'-$9.50');
    });

    test('can place the symbol as a suffix', () {
      expect(1234.5.toCurrency(symbol: '€', suffix: true), '1,234.50€');
    });
  });

  group('NumFormatX numeric strings', () {
    test('toPercentString scales by 100', () {
      expect(0.256.toPercentString(), '26%');
      expect(0.256.toPercentString(decimals: 1), '25.6%');
      expect(1.toPercentString(), '100%');
    });

    test('toFixed and toTrimmed', () {
      expect(3.14159.toFixed(2), '3.14');
      expect(3.10.toTrimmed(2), '3.1');
      expect(3.0.toTrimmed(2), '3');
    });
  });

  group('IntFormatX.toOrdinal', () {
    test('handles the regular suffixes', () {
      expect(1.toOrdinal, '1st');
      expect(2.toOrdinal, '2nd');
      expect(3.toOrdinal, '3rd');
      expect(4.toOrdinal, '4th');
      expect(21.toOrdinal, '21st');
      expect(101.toOrdinal, '101st');
    });

    test('handles the teens exception', () {
      expect(11.toOrdinal, '11th');
      expect(12.toOrdinal, '12th');
      expect(13.toOrdinal, '13th');
      expect(111.toOrdinal, '111th');
    });
  });

  group('IntFormatX.toRoman', () {
    test('converts common values', () {
      expect(1.toRoman, 'I');
      expect(4.toRoman, 'IV');
      expect(1994.toRoman, 'MCMXCIV');
      expect(2024.toRoman, 'MMXXIV');
      expect(3999.toRoman, 'MMMCMXCIX');
    });

    test('rejects out-of-range values', () {
      expect(() => 0.toRoman, throwsArgumentError);
      expect(() => 4000.toRoman, throwsArgumentError);
    });
  });

  group('IntFormatX radix and padding', () {
    test('toPadded pads and keeps the sign outside', () {
      expect(7.toPadded(3), '007');
      expect(7.toPadded(3, padChar: ' '), '  7');
      expect((-7).toPadded(3), '-07');
      expect(1234.toPadded(2), '1234');
    });

    test('toPadded validates its arguments', () {
      expect(() => 7.toPadded(-1), throwsArgumentError);
      expect(() => 7.toPadded(3, padChar: '00'), throwsArgumentError);
    });

    test('radix helpers', () {
      expect(255.toHexString(), 'ff');
      expect(255.toHexString(upperCase: true), 'FF');
      expect(255.toHexString(prefix: true, padTo: 4), '0x00ff');
      expect(5.toBinaryString(), '101');
      expect(5.toBinaryString(prefix: true, padTo: 4), '0b0101');
      expect(8.toOctalString(prefix: true), '0o10');
    });
  });
}
