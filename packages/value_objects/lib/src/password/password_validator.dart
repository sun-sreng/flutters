import 'package:fpdart/fpdart.dart';
import 'password_errors.dart';
import 'password_validation_config.dart';

final class PasswordValidator {
  final PasswordValidationConfig config;

  const PasswordValidator([this.config = const PasswordValidationConfig()]);

  Either<PasswordError, String> validate(String input) {
    if (input.isEmpty) {
      return const Left(PasswordEmpty());
    }

    if (input.length < config.minLength) {
      return Left(PasswordTooShort(currentLength: input.length, minLength: config.minLength));
    }

    if (input.length > config.maxLength) {
      return Left(PasswordTooLong(currentLength: input.length, maxLength: config.maxLength));
    }

    if (!_isAsciiOnly(input)) {
      return const Left(PasswordNonAscii());
    }

    final lowered = input.toLowerCase();

    if (_hasCommonPasswordPrefix(lowered)) {
      return const Left(PasswordTooCommon());
    }

    if (_allSameChar(input)) {
      return const Left(PasswordTooWeak());
    }

    final maxAllowedRun = (input.length * config.sequentialRunFactor).floor().clamp(3, 7);
    if (_hasLongSequentialRun(lowered, minRun: maxAllowedRun)) {
      return const Left(PasswordTooPredictable());
    }

    final score = _classScore(input);
    if (score < config.minComplexityScore) {
      return Left(PasswordComplexityRequired(currentScore: score, requiredScore: config.minComplexityScore));
    }

    return Right(input);
  }

  bool _isAsciiOnly(String s) {
    return s.codeUnits.every((c) => c >= config.minAsciiCode && c <= config.maxAsciiCode);
  }

  bool _hasCommonPasswordPrefix(String lowered) {
    if (config.commonPasswords.contains(lowered)) return true;

    return config.commonPrefixes.any((prefix) => lowered.startsWith(prefix) && lowered.length <= prefix.length + 4);
  }

  int _classScore(String s) {
    final hasLower = s.contains(RegExp(r'[a-z]'));
    final hasUpper = s.contains(RegExp(r'[A-Z]'));
    final hasDigit = s.contains(RegExp(r'\d'));
    final hasSymbol = s.contains(RegExp(r'[^A-Za-z0-9]'));

    return (hasLower ? 1 : 0) + (hasUpper ? 1 : 0) + (hasDigit ? 1 : 0) + (hasSymbol ? 1 : 0);
  }

  bool _allSameChar(String s) {
    if (s.isEmpty) return false;
    final first = s.codeUnitAt(0);
    return s.codeUnits.every((c) => c == first);
  }

  bool _hasLongSequentialRun(String s, {required int minRun}) {
    if (s.length < minRun) return false;

    int inc = 1;
    int dec = 1;

    for (var i = 1; i < s.length; i++) {
      final prev = s.codeUnitAt(i - 1);
      final curr = s.codeUnitAt(i);

      if (curr == prev + 1) {
        inc++;
        if (inc >= minRun) return true;
      } else {
        inc = 1;
      }

      if (curr == prev - 1) {
        dec++;
        if (dec >= minRun) return true;
      } else {
        dec = 1;
      }
    }

    return false;
  }
}
