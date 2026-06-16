import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('Currency', () {
    test('looks up supported currency codes', () {
      expect(Currency.fromCode('USD'), Currency.usd);
      expect(Currency.fromCode('usd'), Currency.usd);
      expect(Currency.fromCode('krw'), Currency.krw);
      expect(Currency.fromCode('XXX'), null);
    });
  });

  group('Money', () {
    test('constructs from exact minor units', () {
      final price = Money(minorUnits: 1999, currency: Currency.usd);
      final yen = Money(minorUnits: 500, currency: Currency.jpy);
      final kwd = Money(minorUnits: 3500, currency: Currency.kwd);

      expect(price.decimalString, '19.99');
      expect(yen.decimalString, '500');
      expect(kwd.decimalString, '3.500');
      expect(price.minorUnits, 1999);
      expect(price.currency, Currency.usd);
      expect(() => Money(minorUnits: -1, currency: Currency.usd), throwsRangeError);
    });

    test('constructs zero money', () {
      const subtotal = Money.zero(Currency.usd);

      expect(subtotal.minorUnits, 0);
      expect(subtotal.formatted, r'$0.00');
      expect(subtotal.isZero, true);
      expect(subtotal.isPositive, false);
    });

    test('constructs from major and minor parts', () {
      final price = Money.ofMajor(19, 99, Currency.usd);
      final rent = Money.ofMajor(1200, 0, Currency.gbp);
      final kwd = Money.ofMajor(3, 500, Currency.kwd);

      expect(price.minorUnits, 1999);
      expect(rent.minorUnits, 120000);
      expect(kwd.minorUnits, 3500);
      expect(() => Money.ofMajor(-1, 0, Currency.usd), throwsArgumentError);
      expect(() => Money.ofMajor(1, -1, Currency.usd), throwsRangeError);
      expect(() => Money.ofMajor(1, 100, Currency.usd), throwsRangeError);
    });

    test('parses decimal strings with currency precision', () {
      expect(Money.fromDecimalString('19.99', Currency.usd).minorUnits, 1999);
      expect(Money.fromDecimalString('19.9', Currency.usd).minorUnits, 1990);
      expect(Money.fromDecimalString('19', Currency.usd).minorUnits, 1900);
      expect(Money.fromDecimalString('1,234.56', Currency.usd).minorUnits, 123456);
      expect(Money.fromDecimalString('500', Currency.jpy).minorUnits, 500);
      expect(Money.fromDecimalString('3.500', Currency.kwd).minorUnits, 3500);
      expect(() => Money.fromDecimalString('19.999', Currency.usd), throwsFormatException);
      expect(() => Money.fromDecimalString('not-money', Currency.usd), throwsFormatException);
      expect(() => Money.fromDecimalString('-1.00', Currency.usd), throwsFormatException);
    });

    test('constructs from numeric decimal values', () {
      final price = Money.fromNum(19.99, Currency.usd);
      final rounded = Money.fromNum(10.005, Currency.usd);
      final yen = Money.fromNum(500, Currency.jpy);

      expect(price.minorUnits, 1999);
      expect(rounded.minorUnits, 1001);
      expect(yen.minorUnits, 500);
      expect(() => Money.fromNum(-1, Currency.usd), throwsArgumentError);
    });

    test('has value equality across currency and minor units', () {
      final a = Money(minorUnits: 1234, currency: Currency.usd);
      final b = Money(minorUnits: 1234, currency: Currency.usd);
      final differentAmount = Money(minorUnits: 1235, currency: Currency.usd);
      final differentCurrency = Money(minorUnits: 1234, currency: Currency.eur);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect({a, b}, hasLength(1));
      expect(a, isNot(differentAmount));
      expect(a, isNot(differentCurrency));
    });

    test('adds and subtracts same-currency amounts', () {
      final price = Money(minorUnits: 1999, currency: Currency.usd);
      final tax = Money(minorUnits: 160, currency: Currency.usd);

      expect((price + tax).minorUnits, 2159);
      expect((price - tax).minorUnits, 1839);
      expect(price.canSubtract(tax), true);
      expect(tax.canSubtract(price), false);
      expect(() => tax - price, throwsArgumentError);
    });

    test('rejects arithmetic across currencies', () {
      final usd = Money(minorUnits: 1000, currency: Currency.usd);
      final eur = Money(minorUnits: 1000, currency: Currency.eur);

      expect(() => usd + eur, throwsArgumentError);
      expect(() => usd.compareTo(eur), throwsArgumentError);
    });

    test('multiplies with half-up rounding', () {
      final unitPrice = Money(minorUnits: 999, currency: Currency.usd);

      expect((unitPrice * 3).minorUnits, 2997);
      expect((unitPrice * 1.08).minorUnits, 1079);
      expect(() => unitPrice * -1, throwsArgumentError);
    });

    test('applies percentage amounts and discounts', () {
      final price = Money(minorUnits: 10000, currency: Currency.usd);
      final tax = price.applyPercent(7);
      final discount = price.applyPercent(10);
      final total = price + tax - discount;

      expect(tax.minorUnits, 700);
      expect(discount.minorUnits, 1000);
      expect(total.minorUnits, 9700);
      expect(price.applyDiscountPercent(15).minorUnits, 8500);
      expect(() => price.applyPercent(-1), throwsRangeError);
      expect(() => price.applyPercent(101), throwsRangeError);
    });

    test('allocates by ratios without losing minor units', () {
      final amount = Money(minorUnits: 1000, currency: Currency.usd);

      final parts = amount.allocate([1, 1, 1]);
      final taxAndNet = amount.allocate([15, 85]);

      expect(parts.map((part) => part.minorUnits), [334, 333, 333]);
      expect(taxAndNet.map((part) => part.minorUnits), [150, 850]);
      expect(parts.sum(emptyCurrency: Currency.usd), amount);
      expect(() => amount.allocate([]), throwsArgumentError);
      expect(() => amount.allocate([1, -1]), throwsArgumentError);
      expect(() => amount.allocate([0, 0]), throwsArgumentError);
    });

    test('compares, min, max, and sorts same-currency amounts', () {
      final threshold = Money(minorUnits: 5000, currency: Currency.usd);
      final subtotal = Money(minorUnits: 7500, currency: Currency.usd);
      final discount = Money(minorUnits: 1000, currency: Currency.usd);

      expect(subtotal >= threshold, true);
      expect(discount < threshold, true);
      expect(discount.min(subtotal), discount);
      expect(discount.max(subtotal), subtotal);

      final prices = [subtotal, discount, threshold]..sort();
      expect(prices, [discount, threshold, subtotal]);
    });

    test('formats for UI, admin, API, and debugging', () {
      final price = Money(minorUnits: 1999, currency: Currency.usd);
      final yen = Money(minorUnits: 500, currency: Currency.jpy);
      final kwd = Money(minorUnits: 3500, currency: Currency.kwd);

      expect(price.formatted, r'$19.99');
      expect(price.formattedWithCode, 'USD 19.99');
      expect(price.decimalString, '19.99');
      expect(price.toString(), 'USD 19.99');
      expect(yen.formatted, '¥500');
      expect(yen.decimalString, '500');
      expect(kwd.formatted, 'KD 3.500');
      expect(kwd.format(), 'KD 3.500');
      expect(kwd.format(withCode: true), 'KWD 3.500');
    });

    test('sums iterable money values', () {
      final subtotal = [
        Money(minorUnits: 999, currency: Currency.usd) * 2,
        Money(minorUnits: 500, currency: Currency.usd),
      ].sum(emptyCurrency: Currency.usd);

      expect(subtotal.minorUnits, 2498);
      expect(<Money>[].sum(emptyCurrency: Currency.usd), const Money.zero(Currency.usd));
      expect(
        () => [
          Money(minorUnits: 100, currency: Currency.usd),
          Money(minorUnits: 100, currency: Currency.eur),
        ].sum(emptyCurrency: Currency.usd),
        throwsArgumentError,
      );
    });
  });
}
