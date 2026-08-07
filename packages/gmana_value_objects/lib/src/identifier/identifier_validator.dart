import 'package:gmana_functional/gmana_functional.dart';

import 'identifier_errors.dart';
import 'identifier_validation_config.dart';

/// Validator for identifier inputs.
final class IdentifierValidator {
  /// Configuration used during validation.
  final IdentifierValidationConfig config;

  /// Creates an [IdentifierValidator].
  const IdentifierValidator([
    this.config = const IdentifierValidationConfig(),
  ]);

  /// Validates [input] returning `Either<IdentifierError, String>`.
  Either<IdentifierError, String> validate(String input) {
    final value = config.trimWhitespace ? input.trim() : input;

    if (value.isEmpty) {
      return config.allowEmpty
          ? Right(value)
          : const Left(IdentifierEmpty());
    }

    return switch (config.requiredType) {
      IdentifierType.any => Right(value),
      IdentifierType.uuid =>
        _isUuid(value, config.uuidVersion)
            ? Right(value)
            : Left(IdentifierInvalidUuid(config.uuidVersion)),
      IdentifierType.ulid =>
        _isUlid(value) ? Right(value) : const Left(IdentifierInvalidUlid()),
      IdentifierType.imei =>
        _isImei(value) ? Right(value) : const Left(IdentifierInvalidImei()),
      IdentifierType.ean =>
        _isEan(value, config.eanVersion)
            ? Right(value)
            : Left(IdentifierInvalidEan(config.eanVersion)),
      IdentifierType.creditCard =>
        _isCreditCard(value)
            ? Right(value)
            : const Left(IdentifierInvalidCreditCard()),
      IdentifierType.mongoId =>
        _isMongoId(value)
            ? Right(value)
            : const Left(IdentifierInvalidMongoId()),
      IdentifierType.semVer =>
        _isSemVer(value)
            ? Right(value)
            : const Left(IdentifierInvalidSemVer()),
      IdentifierType.nanoId =>
        _isNanoId(value, config.nanoIdLength)
            ? Right(value)
            : Left(IdentifierInvalidNanoId(config.nanoIdLength)),
    };
  }

  static bool _isUuid(String str, String? version) {
    final reg = switch (version) {
      '3' => RegExp(r'^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-3[0-9A-Fa-f]{3}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$'),
      '4' => RegExp(r'^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-4[0-9A-Fa-f]{3}-[89abAB][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$'),
      '5' => RegExp(r'^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-5[0-9A-Fa-f]{3}-[89abAB][0-9A-Fa-f]{3}-[0-9A-Fa-f]{12}$'),
      _ => RegExp(r'^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$'),
    };
    return reg.hasMatch(str);
  }

  static bool _isUlid(String str) {
    return RegExp(r'^[0-7][0-9A-HJKMNP-TV-Z]{25}$', caseSensitive: false).hasMatch(str);
  }

  static bool _isImei(String str) {
    final sanitized = str.replaceAll(RegExp(r'[\s-]+'), '');
    return RegExp(r'^\d{15}$').hasMatch(sanitized) && _isLuhn(sanitized);
  }

  static bool _isEan(String str, String? version) {
    final sanitized = str.replaceAll(RegExp(r'[\s-]+'), '');
    if (version == '8' && RegExp(r'^\d{8}$').hasMatch(sanitized)) {
      return _checkEanChecksum(sanitized);
    } else if (version == '13' && RegExp(r'^\d{13}$').hasMatch(sanitized)) {
      return _checkEanChecksum(sanitized);
    } else if (version == null && (RegExp(r'^\d{8}$').hasMatch(sanitized) || RegExp(r'^\d{13}$').hasMatch(sanitized))) {
      return _checkEanChecksum(sanitized);
    }
    return false;
  }

  static bool _checkEanChecksum(String ean) {
    var sum = 0;
    final length = ean.length;
    for (var i = 0; i < length - 1; i++) {
      final digit = int.parse(ean[i]);
      final weight = (length - 1 - i) % 2 == 1 ? 3 : 1;
      sum += digit * weight;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(ean[length - 1]);
  }

  static bool _isCreditCard(String str) {
    final sanitized = str.replaceAll(RegExp(r'\D'), '');
    return sanitized.length >= 13 && sanitized.length <= 19 && _isLuhn(sanitized);
  }

  static bool _isLuhn(String str) {
    var sum = 0;
    var shouldDouble = false;
    for (var i = str.length - 1; i >= 0; i--) {
      var digit = int.parse(str[i]);
      if (shouldDouble) {
        digit *= 2;
        if (digit >= 10) digit -= 9;
      }
      sum += digit;
      shouldDouble = !shouldDouble;
    }
    return sum % 10 == 0;
  }

  static bool _isMongoId(String str) {
    return RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(str);
  }

  static bool _isSemVer(String str) {
    return RegExp(
      r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
    ).hasMatch(str);
  }

  static bool _isNanoId(String str, int len) {
    return str.length == len && RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(str);
  }
}
