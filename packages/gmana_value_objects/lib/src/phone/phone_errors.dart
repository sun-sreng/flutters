import '../core/validation_error.dart';

/// Sealed hierarchy of phone validation errors.
sealed class PhoneError extends ValidationError {
  /// Creates a phone validation error.
  const PhoneError();
}

/// Phone input is empty.
final class PhoneEmpty extends PhoneError {
  /// Creates a phone-empty error.
  const PhoneEmpty();

  @override
  String get code => 'phone.empty';
}

/// Phone format is invalid or contains no digits.
final class PhoneInvalidFormat extends PhoneError {
  /// Creates a phone-invalid-format error.
  const PhoneInvalidFormat();

  @override
  String get code => 'phone.invalidFormat';
}

/// Phone input is missing required `+` prefix.
final class PhoneMissingPlus extends PhoneError {
  /// Creates a phone-missing-plus error.
  const PhoneMissingPlus();

  @override
  String get code => 'phone.missingPlus';
}

/// Phone number contains fewer than required minimum digits.
final class PhoneTooShort extends PhoneError {
  /// Provided digit count.
  final int currentDigits;

  /// Required minimum digits.
  final int minDigits;

  /// Creates a phone-too-short error.
  const PhoneTooShort({
    required this.currentDigits,
    required this.minDigits,
  });

  @override
  String get code => 'phone.tooShort';
}

/// Phone number contains more than allowed maximum digits.
final class PhoneTooLong extends PhoneError {
  /// Provided digit count.
  final int currentDigits;

  /// Allowed maximum digits.
  final int maxDigits;

  /// Creates a phone-too-long error.
  const PhoneTooLong({
    required this.currentDigits,
    required this.maxDigits,
  });

  @override
  String get code => 'phone.tooLong';
}
