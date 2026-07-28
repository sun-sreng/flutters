/// Configuration rules for phone number validation.
final class PhoneValidationConfig {
  /// Whether to enforce E.164 leading `+` prefix format.
  final bool requirePlusPrefix;

  /// Minimum number of digits (defaults to 7).
  final int minDigits;

  /// Maximum number of digits (defaults to 15).
  final int maxDigits;

  /// Creates a phone validation config.
  const PhoneValidationConfig({
    this.requirePlusPrefix = false,
    this.minDigits = 7,
    this.maxDigits = 15,
  });

  /// Preset for strict E.164 phone numbers (e.g. `+14155552671`).
  factory PhoneValidationConfig.e164() => const PhoneValidationConfig(
        requirePlusPrefix: true,
        minDigits: 7,
        maxDigits: 15,
      );
}
