import '../core/validation_error.dart';

sealed class PasswordError extends ValidationError {
  const PasswordError();
}

final class PasswordEmpty extends PasswordError {
  const PasswordEmpty();
}

final class PasswordTooShort extends PasswordError {
  final int currentLength;
  final int minLength;
  
  const PasswordTooShort({
    required this.currentLength,
    required this.minLength,
  });
}

final class PasswordTooLong extends PasswordError {
  final int currentLength;
  final int maxLength;
  
  const PasswordTooLong({
    required this.currentLength,
    required this.maxLength,
  });
}

final class PasswordNonAscii extends PasswordError {
  const PasswordNonAscii();
}

final class PasswordTooCommon extends PasswordError {
  const PasswordTooCommon();
}

final class PasswordTooWeak extends PasswordError {
  const PasswordTooWeak();
}

final class PasswordTooPredictable extends PasswordError {
  const PasswordTooPredictable();
}

final class PasswordComplexityRequired extends PasswordError {
  final int currentScore;
  final int requiredScore;
  
  const PasswordComplexityRequired({
    required this.currentScore,
    required this.requiredScore,
  });
}
