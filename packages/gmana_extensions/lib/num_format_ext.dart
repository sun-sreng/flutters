/// Human-readable string formatting for [num] values.
///
/// These are dependency-free approximations of what `intl` does with full
/// locale support — use them for compact labels, debug output, and places
/// where pulling in a locale database is overkill.
extension NumFormatX on num {
  /// Abbreviates large magnitudes: `1234` -> `'1.2K'`, `2500000` -> `'2.5M'`.
  ///
  /// Trailing zeros are trimmed, so `1000.toCompact()` is `'1K'`.
  ///
  /// ```dart
  /// 999.toCompact();       // '999'
  /// 1234.toCompact();      // '1.2K'
  /// (-4_500_000).toCompact(); // '-4.5M'
  /// ```
  String toCompact({int decimals = 1}) {
    _checkNonNegativeDecimals(decimals);

    final value = toDouble();
    if (!value.isFinite) return toString();

    final magnitude = value.abs();
    for (final (threshold, suffix) in const [
      (1e12, 'T'),
      (1e9, 'B'),
      (1e6, 'M'),
      (1e3, 'K'),
    ]) {
      if (magnitude >= threshold) {
        final scaled = (value / threshold).toStringAsFixed(decimals);
        return '${_trimTrailingZeros(scaled)}$suffix';
      }
    }
    return _trimTrailingZeros(value.toStringAsFixed(decimals));
  }

  /// Formats a byte count with the largest fitting unit.
  ///
  /// With [binary] (the default) the base is 1024 and IEC units are used
  /// (`KiB`, `MiB`, ...). Pass `binary: false` for 1000-based SI units
  /// (`kB`, `MB`, ...).
  ///
  /// ```dart
  /// 1024.toBytes();                // '1 KiB'
  /// 1500.toBytes(binary: false);   // '1.5 kB'
  /// ```
  String toBytes({int decimals = 1, bool binary = true}) {
    _checkNonNegativeDecimals(decimals);

    final units =
        binary
            ? const ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB']
            : const ['B', 'kB', 'MB', 'GB', 'TB', 'PB'];
    final base = binary ? 1024 : 1000;

    var value = toDouble();
    final negative = value < 0;
    value = value.abs();

    var unitIndex = 0;
    while (value >= base && unitIndex < units.length - 1) {
      value /= base;
      unitIndex++;
    }

    final formatted =
        unitIndex == 0
            ? _trimTrailingZeros(value.toStringAsFixed(0))
            : _trimTrailingZeros(value.toStringAsFixed(decimals));
    return '${negative ? '-' : ''}$formatted ${units[unitIndex]}';
  }

  /// Groups the integer part into thousands.
  ///
  /// ```dart
  /// 1234567.toThousands();              // '1,234,567'
  /// 1234.5.toThousands(decimals: 2);    // '1,234.50'
  /// 1234567.toThousands(separator: ' '); // '1 234 567'
  /// ```
  String toThousands({String separator = ',', int? decimals}) {
    if (decimals != null) _checkNonNegativeDecimals(decimals);

    final text = decimals == null ? toString() : toStringAsFixed(decimals);
    final negative = text.startsWith('-');
    final unsigned = negative ? text.substring(1) : text;

    final dotIndex = unsigned.indexOf('.');
    final integerPart =
        dotIndex == -1 ? unsigned : unsigned.substring(0, dotIndex);
    final fractionPart = dotIndex == -1 ? '' : unsigned.substring(dotIndex);

    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) buffer.write(separator);
      buffer.write(integerPart[i]);
    }

    return '${negative ? '-' : ''}$buffer$fractionPart';
  }

  /// Formats this value as currency.
  ///
  /// ```dart
  /// 1234.5.toCurrency();                     // '$1,234.50'
  /// 1234.5.toCurrency(symbol: '€', suffix: true); // '1,234.50€'
  /// ```
  String toCurrency({
    String symbol = r'$',
    int decimals = 2,
    String separator = ',',
    bool suffix = false,
  }) {
    _checkNonNegativeDecimals(decimals);

    final formatted = toThousands(separator: separator, decimals: decimals);
    if (suffix) return '$formatted$symbol';
    return formatted.startsWith('-')
        ? '-$symbol${formatted.substring(1)}'
        : '$symbol$formatted';
  }

  /// Formats this fraction as a percentage, scaling by 100.
  ///
  /// ```dart
  /// 0.256.toPercentString();             // '26%'
  /// 0.256.toPercentString(decimals: 1);  // '25.6%'
  /// ```
  String toPercentString({int decimals = 0}) {
    _checkNonNegativeDecimals(decimals);
    return '${(toDouble() * 100).toStringAsFixed(decimals)}%';
  }

  /// Formats with exactly [decimals] decimal places.
  ///
  /// A guarded alias for [num.toStringAsFixed].
  String toFixed(int decimals) {
    _checkNonNegativeDecimals(decimals);
    return toStringAsFixed(decimals);
  }

  /// Formats with up to [decimals] decimal places, trimming trailing zeros.
  ///
  /// ```dart
  /// 3.10.toTrimmed(2); // '3.1'
  /// 3.00.toTrimmed(2); // '3'
  /// ```
  String toTrimmed(int decimals) {
    _checkNonNegativeDecimals(decimals);
    return _trimTrailingZeros(toStringAsFixed(decimals));
  }
}

/// Integer-only formatting: ordinals, Roman numerals, and radix output.
extension IntFormatX on int {
  /// English ordinal form: `1` -> `'1st'`, `12` -> `'12th'`, `23` -> `'23rd'`.
  String get toOrdinal {
    final magnitude = abs();
    final lastTwo = magnitude % 100;
    final suffix =
        (lastTwo >= 11 && lastTwo <= 13)
            ? 'th'
            : switch (magnitude % 10) {
              1 => 'st',
              2 => 'nd',
              3 => 'rd',
              _ => 'th',
            };
    return '$this$suffix';
  }

  /// Roman numeral representation. Valid for 1 through 3999.
  ///
  /// ```dart
  /// 2024.toRoman; // 'MMXXIV'
  /// ```
  String get toRoman {
    if (this < 1 || this > 3999) {
      throw ArgumentError.value(this, 'this', 'must be between 1 and 3999');
    }

    const numerals = [
      (1000, 'M'),
      (900, 'CM'),
      (500, 'D'),
      (400, 'CD'),
      (100, 'C'),
      (90, 'XC'),
      (50, 'L'),
      (40, 'XL'),
      (10, 'X'),
      (9, 'IX'),
      (5, 'V'),
      (4, 'IV'),
      (1, 'I'),
    ];

    final buffer = StringBuffer();
    var remaining = this;
    for (final (value, symbol) in numerals) {
      while (remaining >= value) {
        buffer.write(symbol);
        remaining -= value;
      }
    }
    return buffer.toString();
  }

  /// Zero-padded decimal string.
  ///
  /// ```dart
  /// 7.toPadded(3);              // '007'
  /// 7.toPadded(3, padChar: ' '); // '  7'
  /// ```
  String toPadded(int width, {String padChar = '0'}) {
    if (width < 0) {
      throw ArgumentError.value(width, 'width', 'must not be negative');
    }
    if (padChar.length != 1) {
      throw ArgumentError.value(
        padChar,
        'padChar',
        'must be exactly one character',
      );
    }

    final negative = this < 0;
    final digits = abs().toString().padLeft(
      negative ? width - 1 : width,
      padChar,
    );
    return negative ? '-$digits' : digits;
  }

  /// Binary representation, optionally prefixed with `0b`.
  String toBinaryString({bool prefix = false, int padTo = 0}) =>
      '${prefix ? '0b' : ''}${toRadixString(2).padLeft(padTo, '0')}';

  /// Hexadecimal representation, optionally prefixed with `0x`.
  String toHexString({
    bool prefix = false,
    bool upperCase = false,
    int padTo = 0,
  }) {
    final digits = toRadixString(16).padLeft(padTo, '0');
    return '${prefix ? '0x' : ''}${upperCase ? digits.toUpperCase() : digits}';
  }

  /// Octal representation, optionally prefixed with `0o`.
  String toOctalString({bool prefix = false, int padTo = 0}) =>
      '${prefix ? '0o' : ''}${toRadixString(8).padLeft(padTo, '0')}';
}

String _trimTrailingZeros(String value) {
  if (!value.contains('.')) return value;
  var end = value.length;
  while (end > 0 && value[end - 1] == '0') {
    end--;
  }
  if (end > 0 && value[end - 1] == '.') end--;
  return value.substring(0, end);
}

void _checkNonNegativeDecimals(int decimals) {
  if (decimals < 0) {
    throw ArgumentError.value(decimals, 'decimals', 'must not be negative');
  }
}
