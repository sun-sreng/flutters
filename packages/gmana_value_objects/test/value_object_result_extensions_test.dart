import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('GmanaValueObjectResultX', () {
    test('exposes a valid value without resolving an error message', () {
      final result = Email.tryParse(' User@Example.COM ');
      final messages = _TrackingMessages();

      expect(result.isValid, isTrue);
      expect(result.isInvalid, isFalse);
      expect(result.errorOrNull, isNull);
      expect(result.valueOrNull?.value, 'user@example.com');
      expect(result.messageOrNull(messages), isNull);
      expect(messages.calls, 0);
    });

    test('exposes an invalid result and its default message', () {
      final result = Email.tryParse('');
      final error = result.leftOrNull();

      expect(result.isValid, isFalse);
      expect(result.isInvalid, isTrue);
      expect(result.errorOrNull, same(error));
      expect(result.errorOrNull, isA<EmailEmpty>());
      expect(result.valueOrNull, isNull);
      expect(result.messageOrNull(), 'Email cannot be empty');
    });

    test('uses the provided message implementation only for a Left', () {
      final result = Email.tryParse('not-an-email');
      final messages = _TrackingMessages();

      expect(result.messageOrNull(messages), 'custom: email_invalid_format');
      expect(messages.calls, 1);
      expect(messages.lastError, same(result.errorOrNull));
    });

    test('propagates errors from a custom message implementation', () {
      final result = Email.tryParse('');

      expect(
        () => result.messageOrNull(const _ThrowingMessages()),
        throwsStateError,
      );
    });

    test('distinguishes a nullable successful value from a failure', () {
      const Either<ValidationError, String?> result =
          Right<ValidationError, String?>(null);

      expect(result.isValid, isTrue);
      expect(result.isInvalid, isFalse);
      expect(result.errorOrNull, isNull);
      expect(result.valueOrNull, isNull);
      expect(result.messageOrNull(), isNull);
    });

    test('is exported as a named extension', () {
      final result = Email.tryParse('user@example.com');

      expect(GmanaValueObjectResultX(result).isValid, isTrue);
      expect(
        GmanaValueObjectResultX(result).valueOrNull,
        Email('user@example.com'),
      );
    });
  });
}

final class _TrackingMessages implements ValidationErrorMessages {
  int calls = 0;
  ValidationError? lastError;

  @override
  String getMessage(ValidationError error) {
    calls++;
    lastError = error;
    return 'custom: ${error.code}';
  }
}

final class _ThrowingMessages implements ValidationErrorMessages {
  const _ThrowingMessages();

  @override
  String getMessage(ValidationError error) {
    throw StateError('message lookup failed for ${error.code}');
  }
}
