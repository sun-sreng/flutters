import 'package:meta/meta.dart';

import 'currency.dart';

/// A value object representing a non-negative monetary amount.
///
/// [Money] is always valid: it stores an exact, non-negative integer count of
/// minor units (for example cents) paired with [Currency] metadata, so
/// arithmetic never depends on floating-point decimal storage. For USD, a
/// [minorUnits] of `1234` represents `$12.34`; for JPY, `1234` represents
/// `¥1234`.
///
/// Construct trusted amounts with the [Money] constructors. To validate
/// untrusted text or numeric input, use `MoneyValidator`, which returns an
/// `Either<MoneyError, Money>`.
@immutable
final class Money implements Comparable<Money> {
  /// The exact, non-negative minor-unit amount.
  final int minorUnits;

  /// The ISO currency metadata.
  final Currency currency;

  /// Creates a [Money] from exact minor units.
  ///
  /// Throws a [RangeError] when [minorUnits] is negative.
  factory Money({required int minorUnits, required Currency currency}) {
    if (minorUnits < 0) {
      throw RangeError.range(minorUnits, 0, null, 'minorUnits');
    }

    return Money._(minorUnits: minorUnits, currency: currency);
  }

  /// Parses a decimal string into [Money].
  ///
  /// Pads minor digits to match [currency]'s decimal places and rejects input
  /// with too many fractional digits, a negative sign, or non-numeric content.
  factory Money.fromDecimalString(String value, Currency currency) {
    final trimmed = value.trim().replaceAll(',', '');
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(trimmed)) {
      throw FormatException('Invalid money amount', value);
    }

    final parts = trimmed.split('.');
    final major = int.parse(parts.first);
    final rawMinor = parts.length == 1 ? '' : parts.last;
    if (rawMinor.length > currency.decimalPlaces) {
      throw FormatException(
        'Too many decimal places for ${currency.code}',
        value,
      );
    }

    final paddedMinor = rawMinor.padRight(currency.decimalPlaces, '0');
    final normalizedMinor =
        currency.decimalPlaces == 0
            ? ''
            : paddedMinor.substring(0, currency.decimalPlaces);
    final minor = normalizedMinor.isEmpty ? 0 : int.parse(normalizedMinor);

    return Money.ofMajor(major, minor, currency);
  }

  /// Creates a [Money] from a numeric decimal value using half-up rounding.
  ///
  /// Throws an [ArgumentError] when [value] is negative.
  factory Money.fromNum(num value, Currency currency) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'Value cannot be negative');
    }

    return Money._(
      minorUnits: _roundHalfUp(value * currency.subunitFactor),
      currency: currency,
    );
  }

  /// Creates a [Money] from separate major and minor parts.
  factory Money.ofMajor(int major, int minor, Currency currency) {
    if (major < 0) {
      throw ArgumentError.value(major, 'major', 'Major cannot be negative');
    }
    if (minor < 0 || minor >= currency.subunitFactor) {
      throw RangeError.range(minor, 0, currency.subunitFactor - 1, 'minor');
    }

    return Money._(
      minorUnits: major * currency.subunitFactor + minor,
      currency: currency,
    );
  }

  /// Creates a zero amount for [currency].
  const Money.zero(this.currency) : minorUnits = 0;

  const Money._({required this.minorUnits, required this.currency});

  /// The decimal amount for display and simple non-authoritative reads.
  ///
  /// Prefer [decimalString] or [minorUnits] for exact, authoritative values.
  num get amount => minorUnits / currency.subunitFactor;

  /// The number of fractional digits used by [minorUnits].
  int get decimalDigits => currency.decimalPlaces;

  /// Whole major units, truncated toward zero.
  int get major => minorUnits ~/ currency.subunitFactor;

  /// Minor-unit remainder after stripping [major].
  int get minor => minorUnits.remainder(currency.subunitFactor);

  /// Returns `true` when this amount is zero.
  bool get isZero => minorUnits == 0;

  /// Returns `true` when this amount is greater than zero.
  bool get isPositive => minorUnits > 0;

  /// Decimal string suitable for API payloads and form prefill.
  String get decimalString {
    if (currency.decimalPlaces == 0) {
      return minorUnits.toString();
    }

    final whole = major.toString();
    final fractional = minor.toString().padLeft(currency.decimalPlaces, '0');
    return '$whole.$fractional';
  }

  /// Currency-aware formatted value for UI display.
  String get formatted {
    final separator = _symbolNeedsSeparator(currency.symbol) ? ' ' : '';
    return '${currency.symbol}$separator$decimalString';
  }

  /// Currency-code formatted value for admin, receipts, logs, and debugging.
  String get formattedWithCode => '${currency.code} $decimalString';

  /// Formats the amount, optionally with the currency code instead of symbol.
  String format({bool withCode = false}) {
    return withCode ? formattedWithCode : formatted;
  }

  /// Adds another same-currency [Money].
  Money add(Money other) {
    _assertSameCurrency(other);
    return Money._(
      minorUnits: minorUnits + other.minorUnits,
      currency: currency,
    );
  }

  /// Subtracts another same-currency [Money].
  ///
  /// Throws an [ArgumentError] when the result would be negative.
  Money subtract(Money other) {
    _assertSameCurrency(other);
    if (other.minorUnits > minorUnits) {
      throw ArgumentError.value(
        other,
        'other',
        'Subtraction would produce a negative money amount',
      );
    }

    return Money._(
      minorUnits: minorUnits - other.minorUnits,
      currency: currency,
    );
  }

  /// Returns whether this amount can subtract [other] without going negative.
  bool canSubtract(Money other) {
    _assertSameCurrency(other);
    return minorUnits >= other.minorUnits;
  }

  /// Multiplies this amount by [factor] using half-up rounding.
  Money multiply(num factor) {
    if (factor < 0) {
      throw ArgumentError.value(factor, 'factor', 'Factor cannot be negative');
    }

    return Money._(
      minorUnits: _roundHalfUp(minorUnits * factor),
      currency: currency,
    );
  }

  /// Returns [percent] percent of this amount using half-up rounding.
  Money applyPercent(num percent) {
    if (percent < 0 || percent > 100) {
      throw RangeError.range(percent, 0, 100, 'percent');
    }

    return multiply(percent / 100);
  }

  /// Applies a percentage discount and rounds to the nearest minor unit.
  Money applyDiscountPercent(num percent) {
    return subtract(applyPercent(percent));
  }

  /// Splits this amount across [ratios] without losing any minor units.
  ///
  /// Any rounding remainder is distributed one minor unit at a time across the
  /// leading allocations, so the parts always sum back to this amount.
  List<Money> allocate(List<int> ratios) {
    if (ratios.isEmpty) {
      throw ArgumentError.value(ratios, 'ratios', 'Ratios cannot be empty');
    }
    if (ratios.any((ratio) => ratio < 0)) {
      throw ArgumentError.value(
        ratios,
        'ratios',
        'Ratios cannot contain negative values',
      );
    }

    final total = ratios.fold<int>(0, (sum, ratio) => sum + ratio);
    if (total <= 0) {
      throw ArgumentError.value(
        ratios,
        'ratios',
        'At least one ratio must be greater than zero',
      );
    }

    var remainder = minorUnits;
    final allocations = <Money>[];

    for (final ratio in ratios) {
      final share = minorUnits * ratio ~/ total;
      allocations.add(Money._(minorUnits: share, currency: currency));
      remainder -= share;
    }

    for (var i = 0; remainder > 0; i++, remainder--) {
      allocations[i] = Money._(
        minorUnits: allocations[i].minorUnits + 1,
        currency: currency,
      );
    }

    return allocations;
  }

  /// Returns the smaller same-currency amount.
  Money min(Money other) => compareTo(other) <= 0 ? this : other;

  /// Returns the larger same-currency amount.
  Money max(Money other) => compareTo(other) >= 0 ? this : other;

  /// Multiplies this amount by a numeric factor.
  Money operator *(num factor) => multiply(factor);

  /// Adds another [Money].
  Money operator +(Money other) => add(other);

  /// Subtracts another [Money].
  Money operator -(Money other) => subtract(other);

  /// Returns whether this amount is less than [other].
  bool operator <(Money other) => compareTo(other) < 0;

  /// Returns whether this amount is less than or equal to [other].
  bool operator <=(Money other) => compareTo(other) <= 0;

  /// Returns whether this amount is greater than [other].
  bool operator >(Money other) => compareTo(other) > 0;

  /// Returns whether this amount is greater than or equal to [other].
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          other.currency == currency &&
          other.minorUnits == minorUnits;

  @override
  int get hashCode => Object.hash(currency, minorUnits);

  @override
  String toString() => formattedWithCode;

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError.value(
        other,
        'other',
        'Money amounts must use the same currency',
      );
    }
  }

  static bool _symbolNeedsSeparator(String symbol) {
    return symbol.length > 1 && RegExp(r'^[A-Z]').hasMatch(symbol);
  }

  // Half-up rounding. Money is always non-negative, so the simple
  // `(value + 0.5).floor()` form is correct here.
  static int _roundHalfUp(num value) {
    return (value + 0.5).floor();
  }
}

/// Helpers for summing collections of [Money].
extension MoneyIterableExtension on Iterable<Money> {
  /// Sums the collection, returning zero in [emptyCurrency] for empty lists.
  ///
  /// Throws an [ArgumentError] when the collection mixes currencies.
  Money sum({required Currency emptyCurrency}) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return Money.zero(emptyCurrency);
    }

    var total = iterator.current;
    while (iterator.moveNext()) {
      total += iterator.current;
    }

    return total;
  }
}
