import 'package:gmana/gmana.dart' show Either, Right;
import '../core/value_object.dart';
import 'currency.dart';
import 'money_amount.dart';
import 'money_errors.dart';

/// A value object representing a non-negative monetary amount.
///
/// Money is stored as exact integer minor units paired with [Currency] metadata.
final class Money extends ValueObject<MoneyAmount>
    implements Comparable<Money> {
  /// The underlying validated [MoneyAmount].
  @override
  Either<MoneyError, MoneyAmount> get value => Right(amountValue);

  /// The exact minor-unit amount.
  final int minorUnits;

  /// The ISO currency metadata.
  final Currency currency;

  /// Creates a [Money] from exact minor units.
  const Money({required this.minorUnits, required this.currency})
    : assert(minorUnits >= 0, 'minorUnits must be zero or greater');

  /// Creates a zero amount for [currency].
  const Money.zero(this.currency) : minorUnits = 0;

  /// Creates a [Money] from separate major and minor parts.
  factory Money.ofMajor(int major, int minor, Currency currency) {
    if (major < 0) {
      throw ArgumentError.value(major, 'major', 'Major cannot be negative');
    }
    if (minor < 0 || minor >= currency.subunitFactor) {
      throw RangeError.range(minor, 0, currency.subunitFactor - 1, 'minor');
    }

    return Money(
      minorUnits: major * currency.subunitFactor + minor,
      currency: currency,
    );
  }

  /// Parses a decimal string into [Money].
  ///
  /// Pads minor digits to match [currency]'s decimal places and rejects input
  /// that has too many fractional digits.
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

  /// Creates a [Money] from a numeric decimal value.
  factory Money.fromNum(num value, Currency currency) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'Value cannot be negative');
    }

    final minorUnits =
        MoneyAmount(
          minorUnits: 1,
          currency: currency,
        ).multiply(value * currency.subunitFactor).minorUnits;

    return Money(minorUnits: minorUnits, currency: currency);
  }

  /// Creates a [Money] from a [MoneyAmount].
  factory Money.fromAmount(MoneyAmount amount) {
    return Money(minorUnits: amount.minorUnits, currency: amount.currency);
  }

  /// The internal exact amount.
  MoneyAmount get amountValue {
    return MoneyAmount(minorUnits: minorUnits, currency: currency);
  }

  /// The decimal amount for display and simple non-authoritative reads.
  num get amount => amountValue.amount;

  /// The number of fractional digits used by [minorUnits].
  int get decimalDigits => currency.decimalPlaces;

  /// Whole major units, truncated toward zero.
  int get major => amountValue.major;

  /// Minor-unit remainder after stripping [major].
  int get minor => amountValue.minor;

  /// Currency-aware formatted value for UI display.
  String get formatted => amountValue.formatted;

  /// Currency-code formatted value for admin, receipts, logs, and debugging.
  String get formattedWithCode => amountValue.formattedWithCode;

  /// Decimal string suitable for API payloads and form prefill.
  String get decimalString => amountValue.decimalString;

  /// Returns `true` when this amount is zero.
  bool get isZero => minorUnits == 0;

  /// Returns `true` when this amount is greater than zero.
  bool get isPositive => minorUnits > 0;

  /// Adds another same-currency [Money].
  Money add(Money other) => Money.fromAmount(amountValue + other.amountValue);

  /// Subtracts another same-currency [Money].
  Money subtract(Money other) {
    return Money.fromAmount(amountValue - other.amountValue);
  }

  /// Returns whether this amount can subtract [other] without going negative.
  bool canSubtract(Money other) => amountValue.canSubtract(other.amountValue);

  /// Multiplies this amount by [factor] using half-up rounding.
  Money multiply(num factor) => Money.fromAmount(amountValue * factor);

  /// Returns [percent] percent of this amount using half-up rounding.
  Money applyPercent(num percent) {
    return Money.fromAmount(amountValue.applyPercent(percent));
  }

  /// Applies a percentage discount.
  Money applyDiscountPercent(num percent) {
    return Money.fromAmount(amountValue.applyDiscountPercent(percent));
  }

  /// Splits this amount across [ratios] without losing any remainder.
  List<Money> allocate(List<int> ratios) {
    return amountValue.allocate(ratios).map(Money.fromAmount).toList();
  }

  /// Returns the smaller same-currency amount.
  Money min(Money other) => compareTo(other) <= 0 ? this : other;

  /// Returns the larger same-currency amount.
  Money max(Money other) => compareTo(other) >= 0 ? this : other;

  /// Adds another [Money].
  Money operator +(Money other) => add(other);

  /// Subtracts another [Money].
  Money operator -(Money other) => subtract(other);

  /// Multiplies this amount by a numeric factor.
  Money operator *(num factor) => multiply(factor);

  /// Returns whether this amount is less than [other].
  bool operator <(Money other) => compareTo(other) < 0;

  /// Returns whether this amount is less than or equal to [other].
  bool operator <=(Money other) => compareTo(other) <= 0;

  /// Returns whether this amount is greater than [other].
  bool operator >(Money other) => compareTo(other) > 0;

  /// Returns whether this amount is greater than or equal to [other].
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  int compareTo(Money other) => amountValue.compareTo(other.amountValue);

  @override
  MoneyAmount? get valueOrNull => amountValue;

  @override
  String toString() => formattedWithCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Money &&
            other.currency == currency &&
            other.minorUnits == minorUnits;
  }

  @override
  int get hashCode => Object.hash(currency, minorUnits);
}

/// Helpers for summing ecommerce money collections.
extension MoneyIterableExtension on Iterable<Money> {
  /// Sums the collection, returning zero in [emptyCurrency] for empty lists.
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
