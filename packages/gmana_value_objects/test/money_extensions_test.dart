import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('MoneyIterableExtension', () {
    test('sumOrNull sums one currency and returns null when empty', () {
      final amounts = [
        Money(minorUnits: 125, currency: Currency.usd),
        Money(minorUnits: 375, currency: Currency.usd),
      ];

      expect(
        amounts.sumOrNull(),
        Money(minorUnits: 500, currency: Currency.usd),
      );
      expect(<Money>[].sumOrNull(), isNull);
    });

    test('sumOrNull rejects mixed currencies', () {
      final amounts = [
        Money(minorUnits: 100, currency: Currency.usd),
        Money(minorUnits: 100, currency: Currency.eur),
      ];

      expect(amounts.sumOrNull, throwsArgumentError);
    });

    test('sumByCurrency independently totals every encountered currency', () {
      final amounts = [
        Money(minorUnits: 125, currency: Currency.usd),
        Money(minorUnits: 200, currency: Currency.eur),
        Money(minorUnits: 375, currency: Currency.usd),
        Money(minorUnits: 50, currency: Currency.eur),
        Money(minorUnits: 800, currency: Currency.jpy),
      ];

      expect(amounts.sumByCurrency(), {
        Currency.usd: Money(minorUnits: 500, currency: Currency.usd),
        Currency.eur: Money(minorUnits: 250, currency: Currency.eur),
        Currency.jpy: Money(minorUnits: 800, currency: Currency.jpy),
      });
    });

    test('sumByCurrency returns an empty map for an empty iterable', () {
      expect(<Money>[].sumByCurrency(), isEmpty);
    });

    test('new members are available through the named extension', () {
      final amounts = [
        Money(minorUnits: 100, currency: Currency.usd),
        Money(minorUnits: 250, currency: Currency.usd),
      ];

      expect(
        MoneyIterableExtension(amounts).sumOrNull(),
        Money(minorUnits: 350, currency: Currency.usd),
      );
      expect(MoneyIterableExtension(amounts).sumByCurrency(), {
        Currency.usd: Money(minorUnits: 350, currency: Currency.usd),
      });
    });
  });
}
