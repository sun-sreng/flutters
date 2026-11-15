import '../core/validation_issue.dart';

/// Default English messages for phone validation issues.
String resolvePhoneValidationIssue(PhoneValidationIssue issue) {
  return switch (issue) {
    PhoneEmptyIssue() => 'Please enter a phone number',
    PhoneInvalidFormatIssue() => 'Please enter a valid phone number',
    PhoneMissingPlusIssue() => 'Phone number must start with +',
    PhoneTooShortIssue(:final minDigits) =>
      'Phone number must contain at least $minDigits digits',
    PhoneTooLongIssue(:final maxDigits) =>
      'Phone number must contain at most $maxDigits digits',
  };
}

/// Base type for phone validation failures.
sealed class PhoneValidationIssue extends ValidationIssue {
  /// Creates a phone validation issue.
  const PhoneValidationIssue();
}

/// Phone input is empty.
final class PhoneEmptyIssue extends PhoneValidationIssue {
  /// Creates a phone-empty issue.
  const PhoneEmptyIssue();

  @override
  String get code => 'phone.empty';
}

/// Phone input has invalid formatting or non-digit characters.
final class PhoneInvalidFormatIssue extends PhoneValidationIssue {
  /// Creates a phone-invalid-format issue.
  const PhoneInvalidFormatIssue();

  @override
  String get code => 'phone.invalidFormat';
}

/// Phone input is missing required `+` prefix.
final class PhoneMissingPlusIssue extends PhoneValidationIssue {
  /// Creates a phone-missing-plus issue.
  const PhoneMissingPlusIssue();

  @override
  String get code => 'phone.missingPlus';
}

/// Phone number contains fewer than required minimum digits.
final class PhoneTooShortIssue extends PhoneValidationIssue {
  /// Provided digit count.
  final int currentDigits;

  /// Required minimum digits.
  final int minDigits;

  /// Creates a phone-too-short issue.
  const PhoneTooShortIssue({
    required this.currentDigits,
    required this.minDigits,
  });

  @override
  String get code => 'phone.tooShort';
}

/// Phone number contains more than allowed maximum digits.
final class PhoneTooLongIssue extends PhoneValidationIssue {
  /// Provided digit count.
  final int currentDigits;

  /// Allowed maximum digits.
  final int maxDigits;

  /// Creates a phone-too-long issue.
  const PhoneTooLongIssue({
    required this.currentDigits,
    required this.maxDigits,
  });

  @override
  String get code => 'phone.tooLong';
}
