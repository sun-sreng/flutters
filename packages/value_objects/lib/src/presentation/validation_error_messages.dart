import '../core/validation_error.dart';
import '../email/email_errors.dart';
import '../password/password_errors.dart';
import '../text/text_errors.dart';
import '../number/number_errors.dart';

/// Default English messages for all validation errors.
/// Consumers can create their own implementations for i18n.
abstract interface class ValidationErrorMessages {
  String getMessage(ValidationError error);
}

final class DefaultValidationErrorMessages implements ValidationErrorMessages {
  const DefaultValidationErrorMessages();

  @override
  String getMessage(ValidationError error) {
    return switch (error) {
      // Email errors
      EmailEmpty() => 'Email cannot be empty',
      EmailInvalidFormat() => 'Invalid email format',
      EmailTooLong(:final currentLength, :final maxLength) =>
        'Email must be at most $maxLength characters (current: $currentLength)',
      EmailLocalPartTooLong(:final currentLength, :final maxLength) =>
        'Email username must be at most $maxLength characters (current: $currentLength)',
      EmailDomainTooLong(:final currentLength, :final maxLength) =>
        'Email domain must be at most $maxLength characters (current: $currentLength)',
      EmailDisposableDomain(:final domain) => 'Disposable email addresses are not allowed ($domain)',
      EmailBlockedDomain(:final domain) => 'Email domain is not allowed ($domain)',

      // Password errors
      PasswordEmpty() => 'Password cannot be empty',
      PasswordTooShort(:final currentLength, :final minLength) =>
        'Password must be at least $minLength characters (current: $currentLength)',
      PasswordTooLong(:final currentLength, :final maxLength) =>
        'Password must be at most $maxLength characters (current: $currentLength)',
      PasswordNonAscii() => 'Password must contain only standard characters',
      PasswordTooCommon() => 'This password is too common. Please choose a different one',
      PasswordTooWeak() => 'Password is too weak. Try mixing different characters',
      PasswordTooPredictable() => 'Password contains predictable patterns',
      PasswordComplexityRequired(:final currentScore, :final requiredScore) =>
        'Password must include $requiredScore types of characters: '
            'uppercase, lowercase, numbers, symbols (current: $currentScore)',

      // Text errors
      TextEmpty() => 'This field cannot be empty',
      TextTooShort(:final currentLength, :final minLength) =>
        'Must be at least $minLength characters (current: $currentLength)',
      TextTooLong(:final currentLength, :final maxLength) =>
        'Must be at most $maxLength characters (current: $currentLength)',
      TextInvalidPattern(:final pattern) => 'Invalid format (pattern: $pattern)',
      TextContainsBlacklisted(:final foundWords) => 'Contains prohibited words: ${foundWords.join(', ')}',
      TextOnlyWhitespace() => 'Cannot contain only whitespace',
      TextInvalidCharacters(:final invalidChars) => 'Contains invalid characters: $invalidChars',

      // Number errors
      NumberEmpty() => 'Number cannot be empty',
      NumberInvalidFormat() => 'Invalid number format',
      NumberTooSmall(:final currentValue, :final minValue) =>
        'Number must be at least $minValue (current: $currentValue)',
      NumberTooLarge(:final currentValue, :final maxValue) =>
        'Number must be at most $maxValue (current: $currentValue)',
      NumberNotInteger(:final currentValue) => 'Must be a whole number (current: $currentValue)',
      NumberNegativeNotAllowed(:final currentValue) => 'Negative numbers are not allowed (current: $currentValue)',
      NumberNotInRange(:final currentValue, :final minValue, :final maxValue) =>
        'Number must be between $minValue and $maxValue (current: $currentValue)',
      NumberDecimalPlacesExceeded(:final currentPlaces, :final maxPlaces) =>
        'Too many decimal places (max: $maxPlaces, current: $currentPlaces)',

      _ => 'Validation error',
    };
  }
}
