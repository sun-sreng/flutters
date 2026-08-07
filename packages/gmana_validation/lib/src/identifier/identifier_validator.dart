import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_predicates/gmana_predicates.dart' as predicates;

import '../core/validation_issue.dart';
import 'identifier_validation_config.dart';
import 'identifier_validation_issue.dart';

/// Canonical validator for identifier inputs.
final class IdentifierValidator {
  /// Rules used during validation.
  final IdentifierValidationConfig config;

  /// Creates an identifier validator.
  const IdentifierValidator([
    this.config = const IdentifierValidationConfig(),
  ]);

  /// Validates and normalizes [input].
  ValidationResult<IdentifierValidationIssue, String> validate(String input) {
    final value = config.trimWhitespace ? input.trim() : input;

    if (value.isEmpty) {
      return config.allowEmpty
          ? Right(value)
          : const Left(IdentifierEmptyIssue());
    }

    return switch (config.requiredType) {
      IdentifierType.any => Right(value),
      IdentifierType.uuid =>
        predicates.isUuid(value, config.uuidVersion)
            ? Right(value)
            : Left(IdentifierInvalidUuidIssue(config.uuidVersion)),
      IdentifierType.ulid =>
        predicates.isULID(value)
            ? Right(value)
            : const Left(IdentifierInvalidUlidIssue()),
      IdentifierType.imei =>
        predicates.isIMEI(value)
            ? Right(value)
            : const Left(IdentifierInvalidImeiIssue()),
      IdentifierType.ean =>
        predicates.isEAN(value, config.eanVersion)
            ? Right(value)
            : Left(IdentifierInvalidEanIssue(config.eanVersion)),
      IdentifierType.creditCard =>
        predicates.isCreditCard(value)
            ? Right(value)
            : const Left(IdentifierInvalidCreditCardIssue()),
      IdentifierType.mongoId =>
        predicates.isMongoId(value)
            ? Right(value)
            : const Left(IdentifierInvalidMongoIdIssue()),
      IdentifierType.semVer =>
        predicates.isSemVer(value)
            ? Right(value)
            : const Left(IdentifierInvalidSemVerIssue()),
      IdentifierType.nanoId =>
        predicates.isNanoId(value, config.nanoIdLength)
            ? Right(value)
            : Left(IdentifierInvalidNanoIdIssue(config.nanoIdLength)),
    };
  }
}
