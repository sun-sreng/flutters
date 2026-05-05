import 'package:meta/meta.dart';
import 'currency.dart';

/// A validated monetary amount represented in exact minor units.
@immutable
final class MoneyAmount implements Comparable<MoneyAmount> {
  /// The exact minor-unit amount.
  ///
  /// For USD, `1234` represents `$12.34`; for JPY, `1234` represents `¥1234`.
  final int minorUnits;

  /// The ISO currency metadata.
  final Currency currency;

  /// Creates a validated [MoneyAmount].
  const MoneyAmount({required this.minorUnits, required this.currency})
    : assert(minorUnits >= 0, 'minorUnits must be zero or greater');

  /// The decimal amount for display and simple non-authoritative reads.
  num get amount => minorUnits / currency.subunitFactor;

  /// The number of fractional digits used by [minorUnits].
  int get decimalDigits => currency.decimalPlaces;

  /// Returns the power-of-ten scale used by this amount.
  int get scale => currency.subunitFactor;

  /// Whole major units, truncated toward zero.
  int get major => minorUnits ~/ scale;

  /// Minor-unit remainder after stripping [major].
  int get minor => minorUnits.remainder(scale);

  /// Returns `true` when this amount is zero.
  bool get isZero => minorUnits == 0;

  /// Returns `true` when this amount is greater than zero.
  bool get isPositive => minorUnits > 0;

  /// Formatted for customer-facing UI.
  String get formatted {
    final amountText = decimalString;
    final separator = _symbolNeedsSeparator(currency.symbol) ? ' ' : '';
    return '${currency.symbol}$separator$amountText';
  }

  /// Formatted for admin, logs, and receipts.
  String get formattedWithCode => '${currency.code} $decimalString';

  /// Decimal string without currency metadata.
  String get decimalString {
    if (currency.decimalPlaces == 0) {
      return minorUnits.toString();
    }

    final whole = major.toString();
    final fractional = minor.toString().padLeft(currency.decimalPlaces, '0');
    return '$whole.$fractional';
  }

  /// Adds another amount with the same currency.
  MoneyAmount add(MoneyAmount other) {
    _assertSameCurrency(other);

    return MoneyAmount(
      minorUnits: minorUnits + other.minorUnits,
      currency: currency,
    );
  }

  /// Subtracts another amount with the same currency.
  ///
  /// Throws [ArgumentError] when the result would be negative.
  MoneyAmount subtract(MoneyAmount other) {
    _assertSameCurrency(other);
    if (other.minorUnits > minorUnits) {
      throw ArgumentError.value(
        other,
        'other',
        'Subtraction would produce a negative money amount',
      );
    }

    return MoneyAmount(
      minorUnits: minorUnits - other.minorUnits,
      currency: currency,
    );
  }

  /// Returns whether this amount can subtract [other] without going negative.
  bool canSubtract(MoneyAmount other) {
    _assertSameCurrency(other);
    return minorUnits >= other.minorUnits;
  }

  /// Multiplies this amount by [factor] using half-up rounding.
  MoneyAmount multiply(num factor) {
    if (factor < 0) {
      throw ArgumentError.value(factor, 'factor', 'Factor cannot be negative');
    }

    return MoneyAmount(
      minorUnits: _roundHalfUp(minorUnits * factor),
      currency: currency,
    );
  }

  /// Returns [percent] percent of this amount using half-up rounding.
  MoneyAmount applyPercent(num percent) {
    if (percent < 0 || percent > 100) {
      throw RangeError.range(percent, 0, 100, 'percent');
    }

    return multiply(percent / 100);
  }

  /// Applies a percentage discount and rounds to the nearest minor unit.
  MoneyAmount applyDiscountPercent(num percent) {
    return subtract(applyPercent(percent));
  }

  /// Splits this amount across [ratios] without losing any remainder.
  List<MoneyAmount> allocate(List<int> ratios) {
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
    final allocations = <MoneyAmount>[];

    for (final ratio in ratios) {
      final share = minorUnits * ratio ~/ total;
      allocations.add(MoneyAmount(minorUnits: share, currency: currency));
      remainder -= share;
    }

    for (var i = 0; remainder > 0; i++, remainder--) {
      allocations[i] = MoneyAmount(
        minorUnits: allocations[i].minorUnits + 1,
        currency: currency,
      );
    }

    return allocations;
  }

  /// Returns the smaller same-currency amount.
  MoneyAmount min(MoneyAmount other) => compareTo(other) <= 0 ? this : other;

  /// Returns the larger same-currency amount.
  MoneyAmount max(MoneyAmount other) => compareTo(other) >= 0 ? this : other;

  /// Formats the money amount for display.
  String format({bool withCode = false}) {
    return withCode ? formattedWithCode : formatted;
  }

  /// Adds another [MoneyAmount].
  MoneyAmount operator +(MoneyAmount other) => add(other);

  /// Subtracts another [MoneyAmount].
  MoneyAmount operator -(MoneyAmount other) => subtract(other);

  /// Multiplies this amount by a numeric factor.
  MoneyAmount operator *(num factor) => multiply(factor);

  /// Returns whether this amount is less than [other].
  bool operator <(MoneyAmount other) => compareTo(other) < 0;

  /// Returns whether this amount is less than or equal to [other].
  bool operator <=(MoneyAmount other) => compareTo(other) <= 0;

  /// Returns whether this amount is greater than [other].
  bool operator >(MoneyAmount other) => compareTo(other) > 0;

  /// Returns whether this amount is greater than or equal to [other].
  bool operator >=(MoneyAmount other) => compareTo(other) >= 0;

  @override
  int compareTo(MoneyAmount other) {
    _assertSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  @override
  String toString() => formattedWithCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MoneyAmount &&
            other.currency == currency &&
            other.minorUnits == minorUnits;
  }

  @override
  int get hashCode => Object.hash(currency, minorUnits);

  void _assertSameCurrency(MoneyAmount other) {
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

  static int _roundHalfUp(num value) {
    return (value + 0.5).floor();
  }
}
