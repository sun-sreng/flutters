import 'package:meta/meta.dart';

@immutable
final class PasswordValidationConfig {
  final int minLength;
  final int maxLength;
  final int minComplexityScore;
  final int minAsciiCode;
  final int maxAsciiCode;
  final double sequentialRunFactor;
  final Set<String> commonPasswords;
  final List<String> commonPrefixes;
  
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
  
  factory PasswordValidationConfig.lenient() {
    return const PasswordValidationConfig(
      minLength: 4,
      minComplexityScore: 1,
    );
  }
  
  factory PasswordValidationConfig.strict() {
    return const PasswordValidationConfig(
      minLength: 12,
      minComplexityScore: 4,
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
}
