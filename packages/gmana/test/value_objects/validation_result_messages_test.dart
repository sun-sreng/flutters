import 'package:gmana/gmana.dart';
import 'package:test/test.dart';

void main() {
  group('GmanaValidationResultX on value-object results', () {
    test('a valid result has a value and no message', () {
      final result = Email.tryParse('user@example.com');

      expect(result.isValid, isTrue);
      expect(result.issueOrNull, isNull);
      expect(result.valueOrNull?.value, 'user@example.com');
      expect(result.messageOrNull(), isNull);
    });

    test('an invalid result resolves the default message', () {
      final result = Email.tryParse('');

      expect(result.isInvalid, isTrue);
      expect(result.issueOrNull, isA<EmailEmptyIssue>());
      expect(
        result.messageOrNull(),
        resolveEmailValidationIssue(const EmailEmptyIssue()),
      );
    });

    test('a custom resolver is used only for a Left', () {
      var calls = 0;
      String resolve(EmailValidationIssue issue) {
        calls++;
        return 'custom ${issue.code}';
      }

      expect(Email.tryParse('user@example.com').messageOrNull(resolve), isNull);
      expect(calls, 0);
      expect(Email.tryParse('').messageOrNull(resolve), 'custom email.empty');
      expect(calls, 1);
    });
  });

  group('resolveValidationIssue', () {
    test('dispatches to the issue family resolver', () {
      const password = PasswordTooShortIssue(currentLength: 3, minLength: 8);
      const money = MoneyInvalidCurrencyIssue('ZZZ');

      expect(
        resolveValidationIssue(password),
        resolvePasswordValidationIssue(password),
      );
      expect(resolveValidationIssue(money), resolveMoneyValidationIssue(money));
    });

    test('falls back to the code for issues from other sources', () {
      expect(resolveValidationIssue(const _CustomIssue()), 'custom.issue');
    });
  });
}

final class _CustomIssue extends ValidationIssue {
  const _CustomIssue();

  @override
  String get code => 'custom.issue';
}
