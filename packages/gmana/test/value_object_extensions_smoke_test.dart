import 'package:gmana/gmana.dart';
import 'package:test/test.dart';

void main() {
  test('validation and value-object result vocabularies coexist', () {
    final validationResult = ' User@Example.COM '.validateEmail();
    final valueObjectResult = Email.tryParse(' User@Example.COM ');

    expect(validationResult.isValid, isTrue);
    expect(validationResult.valueOrNull, 'user@example.com');
    expect(validationResult.messageOrNull(resolveEmailValidationIssue), null);
    expect(valueObjectResult.isValid, isTrue);
    expect(valueObjectResult.valueOrNull, Email('user@example.com'));
    expect(valueObjectResult.messageOrNull(), null);
  });

  test('date-range and money extensions are available from the facade', () {
    final first = DateRange(
      start: DateTime.utc(2026, 1, 1),
      end: DateTime.utc(2026, 1, 10),
    );
    final second = DateRange(
      start: DateTime.utc(2026, 1, 10),
      end: DateTime.utc(2026, 1, 20),
    );
    final totals =
        [
          Money(minorUnits: 100, currency: Currency.usd),
          Money(minorUnits: 250, currency: Currency.usd),
          Money(minorUnits: 500, currency: Currency.eur),
        ].sumByCurrency();

    expect(first.overlaps(second), isTrue);
    expect(totals[Currency.usd]?.minorUnits, 350);
    expect(totals[Currency.eur]?.minorUnits, 500);
  });
}
