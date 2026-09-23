import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart' as v;

import '../email/email.dart';
import '../email/email_errors.dart';
import '../number/number_errors.dart';
import '../number/number_value.dart';
import '../password/password.dart';
import '../password/password_errors.dart';
import '../phone/phone.dart';
import '../phone/phone_errors.dart';
import '../text/text_errors.dart';
import '../text/text_value.dart';
import '../url/url.dart';
import '../url/url_errors.dart';

/// Adapts an [v.EmailValidationIssue] to an [EmailError].
extension EmailValidationIssueToDomainErrorX on v.EmailValidationIssue {
  /// Maps a validation issue to its domain [EmailError] equivalent.
  EmailError toEmailError() => switch (this) {
    v.EmailEmptyIssue() => const EmailEmpty(),
    v.EmailInvalidFormatIssue() => const EmailInvalidFormat(),
    v.EmailTooLongIssue(:final currentLength, :final maxLength) => EmailTooLong(
      currentLength: currentLength,
      maxLength: maxLength,
    ),
    v.EmailLocalPartTooLongIssue(:final currentLength, :final maxLength) =>
      EmailLocalPartTooLong(currentLength: currentLength, maxLength: maxLength),
    v.EmailDomainTooLongIssue(:final currentLength, :final maxLength) =>
      EmailDomainTooLong(currentLength: currentLength, maxLength: maxLength),
    v.EmailBlockedDomainIssue(:final domain) => EmailBlockedDomain(domain),
    v.EmailDisposableDomainIssue(:final domain) => EmailDisposableDomain(
      domain,
    ),
  };
}

/// Extensions adapting `gmana_validation` email results into `gmana_value_objects` types.
extension EmailValidationAdapterX on Either<v.EmailValidationIssue, String> {
  /// Converts a successful validation into an [Email] value object.
  Either<v.EmailValidationIssue, Email> toEmailValueObject() {
    return map(Email.new);
  }

  /// Converts this validation result to a domain [Email] result with [EmailError].
  Either<EmailError, Email> toEmailDomainResult() {
    return fold((issue) => Left(issue.toEmailError()), Email.tryParse);
  }
}

/// Adapts a [v.PasswordValidationIssue] to a [PasswordError].
extension PasswordValidationIssueToDomainErrorX on v.PasswordValidationIssue {
  /// Maps a validation issue to its domain [PasswordError] equivalent.
  PasswordError toPasswordError() => switch (this) {
    v.PasswordEmptyIssue() => const PasswordEmpty(),
    v.PasswordTooShortIssue(:final currentLength, :final minLength) =>
      PasswordTooShort(currentLength: currentLength, minLength: minLength),
    v.PasswordTooLongIssue(:final currentLength, :final maxLength) =>
      PasswordTooLong(currentLength: currentLength, maxLength: maxLength),
    v.PasswordMissingUppercaseIssue() => const PasswordTooWeak(),
    v.PasswordMissingLowercaseIssue() => const PasswordTooWeak(),
    v.PasswordMissingDigitIssue() => const PasswordTooWeak(),
    v.PasswordMissingSpecialCharacterIssue() => const PasswordTooWeak(),
    v.PasswordTooCommonIssue() => const PasswordTooCommon(),
    v.PasswordRepeatedCharacterIssue() => const PasswordTooPredictable(),
    v.PasswordSequentialPatternIssue() => const PasswordTooPredictable(),
  };
}

/// Extensions adapting `gmana_validation` password results into `gmana_value_objects` types.
extension PasswordValidationAdapterX
    on Either<v.PasswordValidationIssue, String> {
  /// Converts a successful validation into a [Password] value object.
  Either<v.PasswordValidationIssue, Password> toPasswordValueObject() {
    return map(Password.new);
  }

  /// Converts this validation result to a domain [Password] result with [PasswordError].
  Either<PasswordError, Password> toPasswordDomainResult() {
    return fold((issue) => Left(issue.toPasswordError()), Password.tryParse);
  }
}

/// Adapts a [v.PhoneValidationIssue] to a [PhoneError].
extension PhoneValidationIssueToDomainErrorX on v.PhoneValidationIssue {
  /// Maps a validation issue to its domain [PhoneError] equivalent.
  PhoneError toPhoneError() => switch (this) {
    v.PhoneEmptyIssue() => const PhoneEmpty(),
    v.PhoneInvalidFormatIssue() => const PhoneInvalidFormat(),
    v.PhoneMissingPlusIssue() => const PhoneMissingPlus(),
    v.PhoneTooShortIssue(:final currentDigits, :final minDigits) =>
      PhoneTooShort(currentDigits: currentDigits, minDigits: minDigits),
    v.PhoneTooLongIssue(:final currentDigits, :final maxDigits) => PhoneTooLong(
      currentDigits: currentDigits,
      maxDigits: maxDigits,
    ),
  };
}

/// Extensions adapting `gmana_validation` phone results into `gmana_value_objects` types.
extension PhoneValidationAdapterX on Either<v.PhoneValidationIssue, String> {
  /// Converts a successful validation into a [PhoneValue] value object.
  Either<v.PhoneValidationIssue, PhoneValue> toPhoneValueObject() {
    return map(PhoneValue.new);
  }

  /// Converts this validation result to a domain [PhoneValue] result with [PhoneError].
  Either<PhoneError, PhoneValue> toPhoneDomainResult() {
    return fold((issue) => Left(issue.toPhoneError()), PhoneValue.tryParse);
  }
}

/// Adapts a [v.UrlValidationIssue] to a [UrlError].
extension UrlValidationIssueToDomainErrorX on v.UrlValidationIssue {
  /// Maps a validation issue to its domain [UrlError] equivalent.
  UrlError toUrlError() => switch (this) {
    v.UrlEmptyIssue() => const UrlEmpty(),
    v.UrlInvalidFormatIssue() => const UrlInvalidFormat(),
    v.UrlDisallowedSchemeIssue(:final scheme) => UrlDisallowedScheme(scheme),
    v.UrlMissingHostIssue() => const UrlMissingHost(),
  };
}

/// Extensions adapting `gmana_validation` URL results into `gmana_value_objects` types.
extension UrlValidationAdapterX on Either<v.UrlValidationIssue, Uri> {
  /// Converts a successful validation into an [UrlValue] value object.
  Either<v.UrlValidationIssue, UrlValue> toUrlValueObject() {
    return map((uri) => UrlValue(uri.toString()));
  }

  /// Converts this validation result to a domain [UrlValue] result with [UrlError].
  Either<UrlError, UrlValue> toUrlDomainResult() {
    return fold(
      (issue) => Left(issue.toUrlError()),
      (uri) => UrlValue.tryParse(uri.toString()),
    );
  }
}

/// Adapts a [v.TextValidationIssue] to a [TextError].
extension TextValidationIssueToDomainErrorX on v.TextValidationIssue {
  /// Maps a validation issue to its domain [TextError] equivalent.
  TextError toTextError() => switch (this) {
    v.TextEmptyIssue() => const TextEmpty(),
    v.TextOnlyWhitespaceIssue() => const TextOnlyWhitespace(),
    v.TextTooShortIssue(:final currentLength, :final minLength) => TextTooShort(
      currentLength: currentLength,
      minLength: minLength,
    ),
    v.TextTooLongIssue(:final currentLength, :final maxLength) => TextTooLong(
      currentLength: currentLength,
      maxLength: maxLength,
    ),
    v.TextInvalidPatternIssue() => const TextInvalidPattern(''),
    v.TextInvalidCharactersIssue(:final invalidCharacters) =>
      TextInvalidCharacters(invalidCharacters),
    v.TextContainsBlacklistedIssue(:final foundWords) =>
      TextContainsBlacklisted(foundWords),
  };
}

/// Extensions adapting `gmana_validation` text results into `gmana_value_objects` types.
extension TextValidationAdapterX on Either<v.TextValidationIssue, String> {
  /// Converts a successful validation into a [TextValue] value object.
  Either<v.TextValidationIssue, TextValue> toTextValueObject() {
    return map(TextValue.new);
  }

  /// Converts this validation result to a domain [TextValue] result with [TextError].
  Either<TextError, TextValue> toTextDomainResult() {
    return fold((issue) => Left(issue.toTextError()), TextValue.tryParse);
  }
}

/// Adapts a [v.NumberValidationIssue] to a [NumberError].
extension NumberValidationIssueToDomainErrorX on v.NumberValidationIssue {
  /// Maps a validation issue to its domain [NumberError] equivalent.
  NumberError toNumberError() => switch (this) {
    v.NumberEmptyIssue() => const NumberEmpty(),
    v.NumberInvalidFormatIssue() => const NumberInvalidFormat(),
    v.NumberNegativeNotAllowedIssue(:final currentValue) =>
      NumberNegativeNotAllowed(currentValue),
    v.NumberNotIntegerIssue(:final currentValue) => NumberNotInteger(
      currentValue,
    ),
    v.NumberTooSmallIssue(:final minValue, :final currentValue) =>
      NumberTooSmall(currentValue: currentValue, minValue: minValue),
    v.NumberTooLargeIssue(:final maxValue, :final currentValue) =>
      NumberTooLarge(currentValue: currentValue, maxValue: maxValue),
    v.NumberDecimalPlacesExceededIssue(
      :final maxPlaces,
      :final currentPlaces,
    ) =>
      NumberDecimalPlacesExceeded(
        currentPlaces: currentPlaces,
        maxPlaces: maxPlaces,
      ),
  };
}

/// Extensions adapting `gmana_validation` number results into `gmana_value_objects` types.
extension NumberValidationAdapterX on Either<v.NumberValidationIssue, num> {
  /// Converts a successful validation into a [NumberValue] value object.
  Either<v.NumberValidationIssue, NumberValue> toNumberValueObject() {
    return map(NumberValue.fromNum);
  }

  /// Converts this validation result to a domain [NumberValue] result with [NumberError].
  Either<NumberError, NumberValue> toNumberDomainResult() {
    return fold(
      (issue) => Left(issue.toNumberError()),
      (n) => NumberValue.tryParse(n.toString()),
    );
  }
}
