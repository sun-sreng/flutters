import '../core/validation_error.dart';
import '../email/email_errors.dart';
import '../password/password_errors.dart';
import '../text/text_errors.dart';
import '../number/number_errors.dart';
import '../money/money_errors.dart';

/// Default English messages for all validation errors.
/// Consumers can create their own implementations for i18n.
abstract interface class ValidationErrorMessages {
  /// Converts a [ValidationError] into a human-readable string message.
  ///
  /// The [error] parameter is the validation error that needs to be displayed.
  String getMessage(ValidationError error);
}

/// The default implementation of [ValidationErrorMessages].
///
/// This class provides default English error messages for all built-in
/// validation errors in the package.
final class DefaultValidationErrorMessages implements ValidationErrorMessages {
  /// Creates a new instance of [DefaultValidationErrorMessages].
  const DefaultValidationErrorMessages();

  /// Gets the localized or default string message for a given [ValidationError].
  ///
  /// The [error] parameter represents the validation error to be translated.
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
      EmailDisposableDomain(:final domain) =>
        'Disposable email addresses are not allowed ($domain)',
      EmailBlockedDomain(:final domain) =>
        'Email domain is not allowed ($domain)',

      // Password errors
      PasswordEmpty() => 'Password cannot be empty',
      PasswordTooShort(:final currentLength, :final minLength) =>
        'Password must be at least $minLength characters (current: $currentLength)',
      PasswordTooLong(:final currentLength, :final maxLength) =>
        'Password must be at most $maxLength characters (current: $currentLength)',
      PasswordNonAscii() => 'Password must contain only standard characters',
      PasswordTooCommon() =>
        'This password is too common. Please choose a different one',
      PasswordTooWeak() =>
        'Password is too weak. Try mixing different characters',
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
      TextInvalidPattern(:final pattern) =>
        'Invalid format (pattern: $pattern)',
      TextContainsBlacklisted(:final foundWords) =>
        'Contains prohibited words: ${foundWords.join(', ')}',
      TextOnlyWhitespace() => 'Cannot contain only whitespace',
      TextInvalidCharacters(:final invalidChars) =>
        'Contains invalid characters: $invalidChars',

      // Number errors
      NumberEmpty() => 'Number cannot be empty',
      NumberInvalidFormat() => 'Invalid number format',
      NumberTooSmall(:final currentValue, :final minValue) =>
        'Number must be at least $minValue (current: $currentValue)',
      NumberTooLarge(:final currentValue, :final maxValue) =>
        'Number must be at most $maxValue (current: $currentValue)',
      NumberNotInteger(:final currentValue) =>
        'Must be a whole number (current: $currentValue)',
      NumberNegativeNotAllowed(:final currentValue) =>
        'Negative numbers are not allowed (current: $currentValue)',
      NumberNotInRange(:final currentValue, :final minValue, :final maxValue) =>
        'Number must be between $minValue and $maxValue (current: $currentValue)',
      NumberDecimalPlacesExceeded(:final currentPlaces, :final maxPlaces) =>
        'Too many decimal places (max: $maxPlaces, current: $currentPlaces)',

      // Money errors
      MoneyEmpty() => 'Money amount cannot be empty',
      MoneyInvalidFormat() => 'Invalid money amount format',
      MoneyNegativeNotAllowed(:final minorUnits) =>
        'Negative money amounts are not allowed (minor units: $minorUnits)',
      MoneyDecimalPlacesExceeded(:final currentPlaces, :final maxPlaces) =>
        'Too many money decimal places (max: $maxPlaces, current: $currentPlaces)',
      MoneyInvalidCurrency(:final currency) =>
        'Invalid currency code ($currency)',
      MoneyUnsupportedCurrency(:final currency, :final allowedCurrencies) =>
        'Unsupported currency $currency (allowed: ${allowedCurrencies.join(', ')})',
      MoneyTooSmall(:final currentMinorUnits, :final minMinorUnits) =>
        'Money amount is too small (min minor units: $minMinorUnits, current: $currentMinorUnits)',
      MoneyTooLarge(:final currentMinorUnits, :final maxMinorUnits) =>
        'Money amount is too large (max minor units: $maxMinorUnits, current: $currentMinorUnits)',

      _ => 'Validation error',
    };
  }
}
