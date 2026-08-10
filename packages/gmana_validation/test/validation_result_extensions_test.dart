import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('GmanaValidationResultX', () {
    test('exposes the valid branch without resolving a message', () {
      final result = const EmailValidator().validate(' User@Example.COM ');
      var resolverCalls = 0;

      final message = result.messageOrNull((issue) {
        resolverCalls++;
        return resolveEmailValidationIssue(issue);
      });

      expect(result.isValid, isTrue);
      expect(result.isInvalid, isFalse);
      expect(result.issueOrNull, isNull);
      expect(result.valueOrNull, 'user@example.com');
      expect(message, isNull);
      expect(resolverCalls, 0);
    });

    test('exposes the invalid branch and resolves its message once', () {
      final result = const EmailValidator().validate('');
      var resolverCalls = 0;
      EmailValidationIssue? resolvedIssue;

      final message = result.messageOrNull((issue) {
        resolverCalls++;
        resolvedIssue = issue;
        return resolveEmailValidationIssue(issue);
      });

      expect(result.isValid, isFalse);
      expect(result.isInvalid, isTrue);
      expect(result.issueOrNull, isA<EmailEmptyIssue>());
      expect(result.valueOrNull, isNull);
      expect(message, 'Please enter an email address');
      expect(resolverCalls, 1);
      expect(resolvedIssue, same(result.issueOrNull));
    });

    test('treats a nullable Right value as valid', () {
      final ValidationResult<DateValidationIssue, DateTime?> result =
          const DateValidator(
            DateValidationConfig(allowEmpty: true),
          ).validate('');
      var resolverCalls = 0;

      final message = result.messageOrNull((issue) {
        resolverCalls++;
        return resolveDateValidationIssue(issue);
      });

      expect(result.isValid, isTrue);
      expect(result.isInvalid, isFalse);
      expect(result.issueOrNull, isNull);
      expect(result.valueOrNull, isNull);
      expect(message, isNull);
      expect(resolverCalls, 0);
    });

    test('propagates resolver errors for an invalid result', () {
      final result = const EmailValidator().validate('');

      expect(
        () => result.messageOrNull(
          (_) => throw StateError('message lookup failed'),
        ),
        throwsStateError,
      );
    });

    test('is exported as a named extension', () {
      final result = const EmailValidator().validate('user@example.com');

      expect(GmanaValidationResultX(result).isValid, isTrue);
      expect(GmanaValidationResultX(result).valueOrNull, 'user@example.com');
    });
  });
}
