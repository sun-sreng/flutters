import 'package:meta/meta.dart';

import '../core/collection_equality.dart';

/// Configuration rules for valid passwords.
///
/// Contains constraints such as length limit, complexity requirements, etc.
@immutable
final class PasswordValidationConfig {
  /// The required minimum length of the password.
  final int minLength;

  /// The maximum allowed length of the password.
  final int maxLength;

  /// The required minimum complexity score.
  final int minComplexityScore;

  /// The minimum allowed ASCII character code.
  final int minAsciiCode;

  /// The maximum allowed ASCII character code.
  final int maxAsciiCode;

  /// Threshold for disallowing sequential runs of characters.
  final double sequentialRunFactor;

  /// Set of blacklisted common passwords.
  final Set<String> commonPasswords;

  /// List of blacklisted common prefixes.
  final List<String> commonPrefixes;

  /// Creates a [PasswordValidationConfig] with optional customized constraints.
  const PasswordValidationConfig({
    this.minLength = 8,
    this.maxLength = 128,
    this.minComplexityScore = 3,
    this.minAsciiCode = 32,
    this.maxAsciiCode = 126,
    this.sequentialRunFactor = 0.5,
    this.commonPasswords = _defaultCommonPasswords,
    this.commonPrefixes = _defaultCommonPrefixes,
  });

  /// Creates a more loosely configured [PasswordValidationConfig].
  factory PasswordValidationConfig.lenient() {
    return const PasswordValidationConfig(minLength: 4, minComplexityScore: 1);
  }

  /// Creates a highly constrained [PasswordValidationConfig].
  factory PasswordValidationConfig.strict() {
    return const PasswordValidationConfig(minLength: 12, minComplexityScore: 4);
  }

  /// Returns a copy of this config with the given fields replaced.
  PasswordValidationConfig copyWith({
    int? minLength,
    int? maxLength,
    int? minComplexityScore,
    int? minAsciiCode,
    int? maxAsciiCode,
    double? sequentialRunFactor,
    Set<String>? commonPasswords,
    List<String>? commonPrefixes,
  }) {
    return PasswordValidationConfig(
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      minComplexityScore: minComplexityScore ?? this.minComplexityScore,
      minAsciiCode: minAsciiCode ?? this.minAsciiCode,
      maxAsciiCode: maxAsciiCode ?? this.maxAsciiCode,
      sequentialRunFactor: sequentialRunFactor ?? this.sequentialRunFactor,
      commonPasswords: commonPasswords ?? this.commonPasswords,
      commonPrefixes: commonPrefixes ?? this.commonPrefixes,
    );
  }

  static const Set<String> _defaultCommonPasswords = {
    '12345678',
    '123456789',
    'password',
    'password123',
    '11111111',
    '00000000',
    'iloveyou',
    'qwerty123',
    'admin123',
  };

  static const List<String> _defaultCommonPrefixes = [
    'password',
    'qwerty',
    'admin',
    'letmein',
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordValidationConfig &&
          other.minLength == minLength &&
          other.maxLength == maxLength &&
          other.minComplexityScore == minComplexityScore &&
          other.minAsciiCode == minAsciiCode &&
          other.maxAsciiCode == maxAsciiCode &&
          other.sequentialRunFactor == sequentialRunFactor &&
          setEquals(other.commonPasswords, commonPasswords) &&
          listEquals(other.commonPrefixes, commonPrefixes);

  @override
  int get hashCode => Object.hash(
    minLength,
    maxLength,
    minComplexityScore,
    minAsciiCode,
    maxAsciiCode,
    sequentialRunFactor,
    Object.hashAllUnordered(commonPasswords),
    Object.hashAll(commonPrefixes),
  );
}
