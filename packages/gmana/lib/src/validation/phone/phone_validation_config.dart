import 'package:meta/meta.dart';

/// Configuration rules for phone number validation.
@immutable
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

  /// Returns a copy with the supplied fields replaced.
  ///
  /// Omitted fields retain their current values.
  PhoneValidationConfig copyWith({
    bool? requirePlusPrefix,
    int? minDigits,
    int? maxDigits,
  }) {
    return PhoneValidationConfig(
      requirePlusPrefix: requirePlusPrefix ?? this.requirePlusPrefix,
      minDigits: minDigits ?? this.minDigits,
      maxDigits: maxDigits ?? this.maxDigits,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneValidationConfig &&
          other.requirePlusPrefix == requirePlusPrefix &&
          other.minDigits == minDigits &&
          other.maxDigits == maxDigits;

  @override
  int get hashCode => Object.hash(requirePlusPrefix, minDigits, maxDigits);
}
