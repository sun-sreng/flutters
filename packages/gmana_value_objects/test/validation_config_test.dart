import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('config equality', () {
    test('value-equal configs are equal and share a hash code', () {
      expect(
        const EmailValidationConfig(maxLength: 100, blockedDomains: {'a.com'}),
        const EmailValidationConfig(maxLength: 100, blockedDomains: {'a.com'}),
      );
      expect(
        const EmailValidationConfig(maxLength: 100).hashCode,
        const EmailValidationConfig(maxLength: 100).hashCode,
      );
      expect(
        const NumberValidationConfig(min: 0, max: 10),
        const NumberValidationConfig(min: 0, max: 10),
      );
      expect(
        const TextValidationConfig(blacklistedWords: {'a', 'b'}),
        const TextValidationConfig(blacklistedWords: {'b', 'a'}),
      );
      expect(
        const MoneyValidationConfig(allowedCurrencies: {'USD'}),
        const MoneyValidationConfig(allowedCurrencies: {'USD'}),
      );
    });

    test('different configs are not equal', () {
      expect(
        const NumberValidationConfig(min: 0),
        isNot(const NumberValidationConfig(min: 1)),
      );
      expect(
        const PasswordValidationConfig(minLength: 8),
        isNot(const PasswordValidationConfig(minLength: 12)),
      );
    });
  });

  group('config copyWith', () {
    test('replaces only the provided fields (non-nullable)', () {
      const base = EmailValidationConfig();
      final updated = base.copyWith(maxLength: 100, allowDisposable: false);

      expect(updated.maxLength, 100);
      expect(updated.allowDisposable, false);
      expect(updated.maxLocalPartLength, base.maxLocalPartLength);
      expect(updated.disposableDomains, base.disposableDomains);
    });

    test('omitting a nullable field keeps the current value', () {
      const base = NumberValidationConfig(min: 0, max: 100, maxDecimalPlaces: 2);
      final updated = base.copyWith(max: 50);

      expect(updated.min, 0);
      expect(updated.max, 50);
      expect(updated.maxDecimalPlaces, 2);
    });

    test('passing null to a nullable field clears it', () {
      const base = NumberValidationConfig(min: 0, max: 100);
      final updated = base.copyWith(max: null);

      expect(updated.min, 0);
      expect(updated.max, isNull);
    });

    test('clears nullable text and money fields explicitly', () {
      const text = TextValidationConfig(minLength: 3, pattern: r'^\d+$');
      expect(text.copyWith(pattern: null).pattern, isNull);
      expect(text.copyWith(pattern: null).minLength, 3);

      const money = MoneyValidationConfig(allowedCurrencies: {'USD'}, minMinorUnits: 100);
      expect(money.copyWith(allowedCurrencies: null).allowedCurrencies, isNull);
      expect(money.copyWith(allowedCurrencies: null).minMinorUnits, 100);
    });

    test('copyWith with no changes equals the original', () {
      const base = PasswordValidationConfig(minLength: 10);
      expect(base.copyWith(), base);
    });
  });

  group('Currency', () {
    test('subunitFactor matches decimal places', () {
      expect(Currency.usd.subunitFactor, 100); // 2 dp
      expect(Currency.jpy.subunitFactor, 1); // 0 dp
      expect(Currency.kwd.subunitFactor, 1000); // 3 dp
    });

    test('every currency factor equals 10^decimalPlaces', () {
      for (final currency in Currency.values) {
        var expected = 1;
        for (var i = 0; i < currency.decimalPlaces; i++) {
          expected *= 10;
        }
        expect(currency.subunitFactor, expected, reason: currency.code);
      }
    });
  });
}
