import 'package:meta/meta.dart';

import 'currency.dart';
import 'money_validation_config.dart';
import 'money_validation_issue.dart';
import 'money_validator.dart';

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
/// `Either<MoneyValidationIssue, Money>`.
@immutable
final class Money implements Comparable<Money> {
  /// The largest amount, in minor units, that [Money] holds.
  ///
  /// This is 2^53 − 1, the largest integer that is exact on every Dart
  /// platform, including the web. Constructors and arithmetic that would
  /// exceed it throw a [RangeError] instead of overflowing or losing
  /// precision; `MoneyValidator` reports it as `MoneyOutOfRangeIssue`.
  static const int maxMinorUnits = 9007199254740991;

  /// The exact, non-negative minor-unit amount.
  final int minorUnits;

  /// The ISO currency metadata.
  final Currency currency;

  /// Creates a [Money] from exact minor units.
  ///
  /// Throws a [RangeError] when [minorUnits] is negative or above
  /// [maxMinorUnits].
  factory Money({required int minorUnits, required Currency currency}) {
    if (minorUnits < 0 || minorUnits > maxMinorUnits) {
      throw RangeError.range(minorUnits, 0, maxMinorUnits, 'minorUnits');
    }

    return Money._(minorUnits: minorUnits, currency: currency);
  }

  /// Parses decimal text into [Money] with the rules `MoneyValidator` uses.
  ///
  /// Accepts digits with an optional `+` sign and `.` fraction, and comma
  /// thousands separators in groups of three (`1,234.56`). The fraction may
  /// have up to [currency]'s decimal places and is padded when shorter.
  /// Surrounding whitespace is ignored.
  ///
  /// Throws a [FormatException] for empty, malformed or negative input, or too
  /// many decimal places, and a [RangeError] when the amount is above
  /// [maxMinorUnits]. Use `MoneyValidator` to get these as issues instead.
  factory Money.fromDecimalString(String value, Currency currency) {
    return MoneyValidator(MoneyValidationConfig(defaultCurrency: currency.code))
        .validate(value)
        .fold(
          (issue) =>
              issue is MoneyOutOfRangeIssue
                  ? throw RangeError(resolveMoneyValidationIssue(issue))
                  : throw FormatException(
                    resolveMoneyValidationIssue(issue),
                    value,
                  ),
          (money) => money,
        );
  }

  /// Creates a [Money] from a numeric decimal value using half-up rounding.
  ///
  /// Throws an [ArgumentError] when [value] is negative or not finite, and a
  /// [RangeError] when the rounded amount is above [maxMinorUnits].
  factory Money.fromNum(num value, Currency currency) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'Value must be finite');
    }
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'Value cannot be negative');
    }

    return Money._(
      minorUnits: _roundHalfUp(value * currency.subunitFactor, 'value'),
      currency: currency,
    );
  }

  /// Creates a [Money] from separate major and minor parts.
  ///
  /// Throws a [RangeError] when the combined amount is above [maxMinorUnits].
  factory Money.ofMajor(int major, int minor, Currency currency) {
    if (major < 0) {
      throw ArgumentError.value(major, 'major', 'Major cannot be negative');
    }
    if (minor < 0 || minor >= currency.subunitFactor) {
      throw RangeError.range(minor, 0, currency.subunitFactor - 1, 'minor');
    }
    final maxMajor = (maxMinorUnits - minor) ~/ currency.subunitFactor;
    if (major > maxMajor) {
      throw RangeError.range(major, 0, maxMajor, 'major');
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
  ///
  /// Throws a [RangeError] when the sum is above [maxMinorUnits].
  Money add(Money other) {
    _assertSameCurrency(other);
    if (other.minorUnits > maxMinorUnits - minorUnits) {
      throw RangeError('Money addition exceeds maxMinorUnits ($maxMinorUnits)');
    }
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
  ///
  /// Throws an [ArgumentError] when [factor] is negative or not finite, and a
  /// [RangeError] when the result is above [maxMinorUnits].
  Money multiply(num factor) {
    if (!factor.isFinite) {
      throw ArgumentError.value(factor, 'factor', 'Factor must be finite');
    }
    if (factor < 0) {
      throw ArgumentError.value(factor, 'factor', 'Factor cannot be negative');
    }

    return Money._(
      minorUnits: _roundHalfUp(minorUnits * factor, 'factor'),
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
  /// Each part first gets its exact share rounded down. The minor units left
  /// over then go one at a time to the parts with the largest fractional
  /// remainder, earlier parts first on a tie, so the parts always sum back to
  /// this amount and a zero ratio always receives zero.
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

    // BigInt keeps `amount * ratio` exact for any int inputs, on every
    // platform.
    final total = ratios.fold<BigInt>(
      BigInt.zero,
      (sum, ratio) => sum + BigInt.from(ratio),
    );
    if (total == BigInt.zero) {
      throw ArgumentError.value(
        ratios,
        'ratios',
        'At least one ratio must be greater than zero',
      );
    }

    final amount = BigInt.from(minorUnits);
    final shares = List<int>.filled(ratios.length, 0);
    final remainders = List<BigInt>.filled(ratios.length, BigInt.zero);
    var leftover = minorUnits;

    for (var i = 0; i < ratios.length; i++) {
      final exact = amount * BigInt.from(ratios[i]);
      shares[i] = (exact ~/ total).toInt();
      remainders[i] = exact.remainder(total);
      leftover -= shares[i];
    }

    // The leftover is the sum of the fractional parts, so it is smaller than
    // the number of parts with a non-zero remainder, and every unit lands on
    // a part whose ratio is positive.
    final byRemainder = [
      for (var i = 0; i < ratios.length; i++)
        if (remainders[i] > BigInt.zero) i,
    ]..sort((a, b) {
      final order = remainders[b].compareTo(remainders[a]);
      return order != 0 ? order : a.compareTo(b);
    });
    for (var k = 0; k < leftover; k++) {
      shares[byRemainder[k]]++;
    }

    return [
      for (final share in shares)
        Money._(minorUnits: share, currency: currency),
    ];
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
  // `(value + 0.5).floor()` form is correct here. The range check runs on the
  // double first, because flooring a value beyond the int range is not exact.
  static int _roundHalfUp(num value, String name) {
    final shifted = value + 0.5;
    if (shifted >= maxMinorUnits + 1) {
      throw RangeError(
        'Money amount from $name exceeds maxMinorUnits ($maxMinorUnits)',
      );
    }
    return shifted.floor();
  }
}

/// Helpers for summing collections of [Money].
extension MoneyIterableX on Iterable<Money> {
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

  /// Sums the collection, or returns `null` when it is empty.
  ///
  /// Unlike [sum], this does not require a currency solely for the empty case.
  /// Throws an [ArgumentError] when the collection mixes currencies.
  Money? sumOrNull() {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }

    var total = iterator.current;
    while (iterator.moveNext()) {
      total += iterator.current;
    }
    return total;
  }

  /// Sums amounts independently by currency.
  ///
  /// Returns a fresh, insertion-ordered map whose keys follow the order in
  /// which currencies first appear. An empty collection returns an empty map.
  Map<Currency, Money> sumByCurrency() {
    final totals = <Currency, Money>{};
    for (final money in this) {
      totals.update(
        money.currency,
        (total) => total + money,
        ifAbsent: () => money,
      );
    }
    return totals;
  }
}
