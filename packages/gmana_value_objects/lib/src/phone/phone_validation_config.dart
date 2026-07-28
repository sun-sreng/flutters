import 'package:meta/meta.dart';

/// Configuration rules for phone number validation.
@immutable
final class PhoneValidationConfig {
  /// Whether to enforce E.164 leading `+` prefix.
  final bool requirePlusPrefix;

  /// Minimum digit count (defaults to 7).
  final int minDigits;

  /// Maximum digit count (defaults to 15).
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneValidationConfig &&
          runtimeType == other.runtimeType &&
          requirePlusPrefix == other.requirePlusPrefix &&
          minDigits == other.minDigits &&
          maxDigits == other.maxDigits;

  @override
  int get hashCode => Object.hash(requirePlusPrefix, minDigits, maxDigits);
}
