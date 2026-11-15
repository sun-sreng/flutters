import 'package:meta/meta.dart';

import '../../../functional.dart';
import '../../core/collection_equality.dart';

import '../core/validation_issue.dart';

/// Default English messages for password validation issues.
String resolvePasswordValidationIssue(PasswordValidationIssue issue) {
  return switch (issue) {
    PasswordEmptyIssue() => 'Password is required',
    PasswordTooShortIssue(:final minLength) => 'Minimum $minLength characters',
    PasswordTooLongIssue(:final maxLength) => 'Maximum $maxLength characters',
    PasswordMissingUppercaseIssue() => 'At least one uppercase letter',
    PasswordMissingLowercaseIssue() => 'At least one lowercase letter',
    PasswordMissingDigitIssue() => 'At least one number',
    PasswordMissingSpecialCharacterIssue() => 'At least one special character',
    PasswordTooCommonIssue() => 'Password is too common',
    PasswordRepeatedCharacterIssue() => 'Password is too predictable',
    PasswordSequentialPatternIssue() => 'Password is too predictable',
    PasswordDisallowedCharacterIssue() =>
      'Password must contain only standard characters',
    PasswordTooFewCharacterClassesIssue(:final requiredClasses) =>
      'Use at least $requiredClasses of: uppercase, lowercase, number, symbol',
  };
}

/// Base type for password validation failures.
sealed class PasswordValidationIssue extends ValidationIssue {
  /// Creates a password validation issue.
  const PasswordValidationIssue();
}

/// Password input is empty.
final class PasswordEmptyIssue extends PasswordValidationIssue {
  /// Creates a password-empty issue.
  const PasswordEmptyIssue();

  @override
  String get code => 'password.empty';
}

/// Password is shorter than allowed.
final class PasswordTooShortIssue extends PasswordValidationIssue {
  /// The provided password length.
  final int currentLength;

  /// The configured minimum length.
  final int minLength;

  /// Creates a too-short issue.
  const PasswordTooShortIssue({
    required this.currentLength,
    required this.minLength,
  });

  @override
  String get code => 'password.tooShort';
}

/// Password is longer than allowed.
final class PasswordTooLongIssue extends PasswordValidationIssue {
  /// The provided password length.
  final int currentLength;

  /// The configured maximum length.
  final int maxLength;

  /// Creates a too-long issue.
  const PasswordTooLongIssue({
    required this.currentLength,
    required this.maxLength,
  });

  @override
  String get code => 'password.tooLong';
}

/// Password is missing an uppercase letter.
final class PasswordMissingUppercaseIssue extends PasswordValidationIssue {
  /// Creates a missing-uppercase issue.
  const PasswordMissingUppercaseIssue();

  @override
  String get code => 'password.missingUppercase';
}

/// Password is missing a lowercase letter.
final class PasswordMissingLowercaseIssue extends PasswordValidationIssue {
  /// Creates a missing-lowercase issue.
  const PasswordMissingLowercaseIssue();

  @override
  String get code => 'password.missingLowercase';
}

/// Password is missing a digit.
final class PasswordMissingDigitIssue extends PasswordValidationIssue {
  /// Creates a missing-digit issue.
  const PasswordMissingDigitIssue();

  @override
  String get code => 'password.missingDigit';
}

/// Password is missing a special character.
final class PasswordMissingSpecialCharacterIssue
    extends PasswordValidationIssue {
  /// Creates a missing-special-character issue.
  const PasswordMissingSpecialCharacterIssue();

  @override
  String get code => 'password.missingSpecialCharacter';
}

/// Password is too common.
final class PasswordTooCommonIssue extends PasswordValidationIssue {
  /// Creates a too-common issue.
  const PasswordTooCommonIssue();

  @override
  String get code => 'password.tooCommon';
}

/// Password uses a repeated-character pattern.
final class PasswordRepeatedCharacterIssue extends PasswordValidationIssue {
  /// Creates a repeated-character issue.
  const PasswordRepeatedCharacterIssue();

  @override
  String get code => 'password.repeatedCharacterPattern';
}

/// Password uses a sequential pattern.
final class PasswordSequentialPatternIssue extends PasswordValidationIssue {
  /// Creates a sequential-pattern issue.
  const PasswordSequentialPatternIssue();

  @override
  String get code => 'password.sequentialPattern';
}

/// Password contains a character outside the allowed code-unit range.
final class PasswordDisallowedCharacterIssue extends PasswordValidationIssue {
  /// Creates a disallowed-character issue.
  const PasswordDisallowedCharacterIssue();

  @override
  String get code => 'password.disallowedCharacter';
}

/// Password mixes too few character classes.
///
/// Reported only when [PasswordValidationConfig.minCharacterClasses] is set.
final class PasswordTooFewCharacterClassesIssue
    extends PasswordValidationIssue {
  /// Creates a too-few-character-classes issue.
  const PasswordTooFewCharacterClassesIssue({
    required this.currentClasses,
    required this.requiredClasses,
  });

  /// Character classes (uppercase, lowercase, digit, symbol) present.
  final int currentClasses;

  /// Character classes required.
  final int requiredClasses;

  @override
  String get code => 'password.tooFewCharacterClasses';
}

/// Configuration for password validation.
@immutable
final class PasswordValidationConfig {
  static const Set<String> _defaultCommonPasswords = {
    '00000000',
    '11111111',
    '12345678',
    '123456789',
    'admin123',
    'iloveyou',
    'password',
    'password123',
    'qwerty123',
  };

  static const List<String> _defaultCommonPrefixes = [
    'admin',
    'letmein',
    'password',
    'qwerty',
  ];

  /// Minimum allowed password length.
  final int minLength;

  /// Maximum allowed password length.
  final int maxLength;

  /// Whether at least one uppercase letter is required.
  final bool requireUppercase;

  /// Whether at least one lowercase letter is required.
  final bool requireLowercase;

  /// Whether at least one digit is required.
  final bool requireDigit;

  /// Whether at least one special character is required.
  final bool requireSpecialCharacter;

  /// Whether common passwords should be rejected.
  final bool rejectCommonPasswords;

  /// Whether repeated-character passwords should be rejected.
  final bool rejectRepeatedCharacters;

  /// Whether sequential character runs should be rejected.
  final bool rejectSequentialPatterns;

  /// Minimum run length that counts as sequential.
  final int minSequentialRun;

  /// List of exact blacklisted passwords.
  final Set<String> commonPasswords;

  /// List of blacklisted prefixes.
  final List<String> commonPrefixes;

  /// When set, at least this many of the four character classes (uppercase,
  /// lowercase, digit, symbol) are required, checked after every other rule.
  ///
  /// The individual `require*` flags are ignored while this is set.
  final int? minCharacterClasses;

  /// Smallest allowed UTF-16 code unit, or `null` for no lower bound.
  final int? minCodeUnit;

  /// Largest allowed UTF-16 code unit, or `null` for no upper bound.
  final int? maxCodeUnit;

  /// When set, the sequential-run threshold scales with the password length:
  /// `(length * sequentialRunFactor).floor()` clamped to 3–7. Overrides
  /// [minSequentialRun].
  final double? sequentialRunFactor;

  /// Creates a password validation config.
  const PasswordValidationConfig({
    this.minLength = 8,
    this.maxLength = 128,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireDigit = true,
    this.requireSpecialCharacter = true,
    this.rejectCommonPasswords = true,
    this.rejectRepeatedCharacters = true,
    this.rejectSequentialPatterns = true,
    this.minSequentialRun = 4,
    this.commonPasswords = _defaultCommonPasswords,
    this.commonPrefixes = _defaultCommonPrefixes,
    this.minCharacterClasses,
    this.minCodeUnit,
    this.maxCodeUnit,
    this.sequentialRunFactor,
  }) : assert(
         minCharacterClasses == null ||
             (minCharacterClasses >= 1 && minCharacterClasses <= 4),
         'minCharacterClasses must be between 1 and 4',
       );

  /// Lenient preset that only enforces a minimum length.
  factory PasswordValidationConfig.lenient() {
    return const PasswordValidationConfig(
      minLength: 4,
      requireUppercase: false,
      requireLowercase: false,
      requireDigit: false,
      requireSpecialCharacter: false,
      rejectCommonPasswords: false,
      rejectRepeatedCharacters: false,
      rejectSequentialPatterns: false,
    );
  }

  /// Strong preset equivalent to the package default.
  factory PasswordValidationConfig.strong() {
    return const PasswordValidationConfig();
  }

  /// Printable ASCII only, at least three of the four character classes, and
  /// a sequential-run limit that scales with length.
  ///
  /// This is the default policy of the `Password` value object.
  static const PasswordValidationConfig balanced = PasswordValidationConfig(
    minCharacterClasses: 3,
    minCodeUnit: 32,
    maxCodeUnit: 126,
    sequentialRunFactor: 0.5,
  );

  /// Returns a copy with the supplied fields replaced.
  ///
  /// Pass `null` explicitly to clear [minCharacterClasses], [minCodeUnit],
  /// [maxCodeUnit] or [sequentialRunFactor]; omitted fields keep their values.
  PasswordValidationConfig copyWith({
    int? minLength,
    int? maxLength,
    bool? requireUppercase,
    bool? requireLowercase,
    bool? requireDigit,
    bool? requireSpecialCharacter,
    bool? rejectCommonPasswords,
    bool? rejectRepeatedCharacters,
    bool? rejectSequentialPatterns,
    int? minSequentialRun,
    Set<String>? commonPasswords,
    List<String>? commonPrefixes,
    Object? minCharacterClasses = unsetConfigValue,
    Object? minCodeUnit = unsetConfigValue,
    Object? maxCodeUnit = unsetConfigValue,
    Object? sequentialRunFactor = unsetConfigValue,
  }) {
    return PasswordValidationConfig(
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      requireUppercase: requireUppercase ?? this.requireUppercase,
      requireLowercase: requireLowercase ?? this.requireLowercase,
      requireDigit: requireDigit ?? this.requireDigit,
      requireSpecialCharacter:
          requireSpecialCharacter ?? this.requireSpecialCharacter,
      rejectCommonPasswords:
          rejectCommonPasswords ?? this.rejectCommonPasswords,
      rejectRepeatedCharacters:
          rejectRepeatedCharacters ?? this.rejectRepeatedCharacters,
      rejectSequentialPatterns:
          rejectSequentialPatterns ?? this.rejectSequentialPatterns,
      minSequentialRun: minSequentialRun ?? this.minSequentialRun,
      commonPasswords: commonPasswords ?? this.commonPasswords,
      commonPrefixes: commonPrefixes ?? this.commonPrefixes,
      minCharacterClasses:
          identical(minCharacterClasses, unsetConfigValue)
              ? this.minCharacterClasses
              : minCharacterClasses as int?,
      minCodeUnit:
          identical(minCodeUnit, unsetConfigValue)
              ? this.minCodeUnit
              : minCodeUnit as int?,
      maxCodeUnit:
          identical(maxCodeUnit, unsetConfigValue)
              ? this.maxCodeUnit
              : maxCodeUnit as int?,
      sequentialRunFactor:
          identical(sequentialRunFactor, unsetConfigValue)
              ? this.sequentialRunFactor
              : sequentialRunFactor as double?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordValidationConfig &&
          other.minLength == minLength &&
          other.maxLength == maxLength &&
          other.requireUppercase == requireUppercase &&
          other.requireLowercase == requireLowercase &&
          other.requireDigit == requireDigit &&
          other.requireSpecialCharacter == requireSpecialCharacter &&
          other.rejectCommonPasswords == rejectCommonPasswords &&
          other.rejectRepeatedCharacters == rejectRepeatedCharacters &&
          other.rejectSequentialPatterns == rejectSequentialPatterns &&
          other.minSequentialRun == minSequentialRun &&
          other.minCharacterClasses == minCharacterClasses &&
          other.minCodeUnit == minCodeUnit &&
          other.maxCodeUnit == maxCodeUnit &&
          other.sequentialRunFactor == sequentialRunFactor &&
          setEquals(other.commonPasswords, commonPasswords) &&
          listEquals(other.commonPrefixes, commonPrefixes);

  @override
  int get hashCode => Object.hash(
    minLength,
    maxLength,
    requireUppercase,
    requireLowercase,
    requireDigit,
    requireSpecialCharacter,
    rejectCommonPasswords,
    rejectRepeatedCharacters,
    rejectSequentialPatterns,
    minSequentialRun,
    minCharacterClasses,
    minCodeUnit,
    maxCodeUnit,
    sequentialRunFactor,
    Object.hashAllUnordered(commonPasswords),
    Object.hashAll(commonPrefixes),
  );
}

/// Canonical validator for password inputs.
final class PasswordValidator {
  /// Rules used during validation.
  final PasswordValidationConfig config;

  /// Creates a password validator.
  const PasswordValidator([this.config = const PasswordValidationConfig()]);

  /// Validates a password against the configured policy.
  ValidationResult<PasswordValidationIssue, String> validate(String input) {
    if (input.isEmpty) {
      return const Left(PasswordEmptyIssue());
    }

    if (input.length < config.minLength) {
      return Left(
        PasswordTooShortIssue(
          currentLength: input.length,
          minLength: config.minLength,
        ),
      );
    }

    if (input.length > config.maxLength) {
      return Left(
        PasswordTooLongIssue(
          currentLength: input.length,
          maxLength: config.maxLength,
        ),
      );
    }

    final minCodeUnit = config.minCodeUnit;
    final maxCodeUnit = config.maxCodeUnit;
    if ((minCodeUnit != null || maxCodeUnit != null) &&
        input.codeUnits.any(
          (unit) =>
              (minCodeUnit != null && unit < minCodeUnit) ||
              (maxCodeUnit != null && unit > maxCodeUnit),
        )) {
      return const Left(PasswordDisallowedCharacterIssue());
    }

    final checkClassesIndividually = config.minCharacterClasses == null;
    if (checkClassesIndividually &&
        config.requireUppercase &&
        !hasUppercase(input)) {
      return const Left(PasswordMissingUppercaseIssue());
    }

    if (checkClassesIndividually &&
        config.requireLowercase &&
        !hasLowercase(input)) {
      return const Left(PasswordMissingLowercaseIssue());
    }

    if (checkClassesIndividually && config.requireDigit && !hasDigit(input)) {
      return const Left(PasswordMissingDigitIssue());
    }

    if (checkClassesIndividually &&
        config.requireSpecialCharacter &&
        !hasSpecialCharacter(input)) {
      return const Left(PasswordMissingSpecialCharacterIssue());
    }

    final lowered = input.toLowerCase();

    if (config.rejectCommonPasswords) {
      if (config.commonPasswords.contains(lowered)) {
        return const Left(PasswordTooCommonIssue());
      }

      final hasCommonPrefix = config.commonPrefixes.any(
        (prefix) =>
            lowered.startsWith(prefix) && lowered.length <= prefix.length + 4,
      );
      if (hasCommonPrefix) {
        return const Left(PasswordTooCommonIssue());
      }
    }

    if (config.rejectRepeatedCharacters && hasOnlyRepeatedCharacters(input)) {
      return const Left(PasswordRepeatedCharacterIssue());
    }

    final runFactor = config.sequentialRunFactor;
    final sequentialThreshold =
        runFactor != null
            ? (input.length * runFactor).floor().clamp(3, 7)
            : config.minSequentialRun < 3
            ? 3
            : config.minSequentialRun;
    if (config.rejectSequentialPatterns &&
        hasSequentialRun(input, minRun: sequentialThreshold)) {
      return const Left(PasswordSequentialPatternIssue());
    }

    final requiredClasses = config.minCharacterClasses;
    if (requiredClasses != null) {
      final classes = characterClassCount(input);
      if (classes < requiredClasses) {
        return Left(
          PasswordTooFewCharacterClassesIssue(
            currentClasses: classes,
            requiredClasses: requiredClasses,
          ),
        );
      }
    }

    return Right(input);
  }

  /// How many of uppercase, lowercase, digit and symbol appear in [input].
  static int characterClassCount(String input) =>
      (hasUppercase(input) ? 1 : 0) +
      (hasLowercase(input) ? 1 : 0) +
      (hasDigit(input) ? 1 : 0) +
      (hasSpecialCharacter(input) ? 1 : 0);

  /// Returns whether the input contains a digit.
  static bool hasDigit(String input) => RegExp(r'\d').hasMatch(input);

  /// Returns whether the input contains a lowercase letter.
  static bool hasLowercase(String input) => RegExp(r'[a-z]').hasMatch(input);

  /// Returns whether every character in the input is identical.
  static bool hasOnlyRepeatedCharacters(String input) {
    if (input.isEmpty) return false;
    final first = input.codeUnitAt(0);
    return input.codeUnits.every((unit) => unit == first);
  }

  /// Returns whether the input contains a long increasing or decreasing run.
  static bool hasSequentialRun(String input, {int minRun = 4}) {
    if (input.length < minRun) return false;

    final lowered = input.toLowerCase();
    var increasing = 1;
    var decreasing = 1;

    for (var index = 1; index < lowered.length; index++) {
      final previous = lowered.codeUnitAt(index - 1);
      final current = lowered.codeUnitAt(index);

      if (current == previous + 1) {
        increasing++;
        if (increasing >= minRun) return true;
      } else {
        increasing = 1;
      }

      if (current == previous - 1) {
        decreasing++;
        if (decreasing >= minRun) return true;
      } else {
        decreasing = 1;
      }
    }

    return false;
  }

  /// Returns whether the input contains a special character.
  static bool hasSpecialCharacter(String input) =>
      RegExp(r'[^A-Za-z\d]').hasMatch(input);

  /// Returns whether the input contains an uppercase letter.
  static bool hasUppercase(String input) => RegExp(r'[A-Z]').hasMatch(input);
}
