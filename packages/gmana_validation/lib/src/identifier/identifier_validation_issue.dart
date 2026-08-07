import '../core/validation_issue.dart';

/// Default English messages for identifier validation issues.
String resolveIdentifierValidationIssue(IdentifierValidationIssue issue) {
  return issue.defaultMessage;
}

/// Base type for identifier validation failures.
sealed class IdentifierValidationIssue extends ValidationIssue {
  /// Creates an identifier validation issue.
  const IdentifierValidationIssue();

  /// Default English message.
  String get defaultMessage;
}

/// Identifier input is empty.
final class IdentifierEmptyIssue extends IdentifierValidationIssue {
  /// Creates an empty identifier issue.
  const IdentifierEmptyIssue();

  @override
  String get code => 'identifier.empty';

  @override
  String get defaultMessage => 'Identifier is required';
}

/// Identifier is not a valid UUID.
final class IdentifierInvalidUuidIssue extends IdentifierValidationIssue {
  /// Specific version checked, if any.
  final String? version;

  /// Creates an invalid UUID issue.
  const IdentifierInvalidUuidIssue([this.version]);

  @override
  String get code => 'identifier.invalidUuid';

  @override
  String get defaultMessage =>
      version != null ? 'Invalid UUID v$version format' : 'Invalid UUID format';
}

/// Identifier is not a valid ULID.
final class IdentifierInvalidUlidIssue extends IdentifierValidationIssue {
  /// Creates an invalid ULID issue.
  const IdentifierInvalidUlidIssue();

  @override
  String get code => 'identifier.invalidUlid';

  @override
  String get defaultMessage => 'Invalid ULID format';
}

/// Identifier is not a valid IMEI number.
final class IdentifierInvalidImeiIssue extends IdentifierValidationIssue {
  /// Creates an invalid IMEI issue.
  const IdentifierInvalidImeiIssue();

  @override
  String get code => 'identifier.invalidImei';

  @override
  String get defaultMessage => 'Invalid IMEI number';
}

/// Identifier is not a valid EAN barcode number.
final class IdentifierInvalidEanIssue extends IdentifierValidationIssue {
  /// Specific EAN version checked.
  final String? version;

  /// Creates an invalid EAN issue.
  const IdentifierInvalidEanIssue([this.version]);

  @override
  String get code => 'identifier.invalidEan';

  @override
  String get defaultMessage =>
      version != null ? 'Invalid EAN-$version barcode' : 'Invalid EAN barcode';
}

/// Identifier is not a valid credit card number.
final class IdentifierInvalidCreditCardIssue extends IdentifierValidationIssue {
  /// Creates an invalid credit card issue.
  const IdentifierInvalidCreditCardIssue();

  @override
  String get code => 'identifier.invalidCreditCard';

  @override
  String get defaultMessage => 'Invalid credit card number';
}

/// Identifier is not a valid MongoDB ObjectId.
final class IdentifierInvalidMongoIdIssue extends IdentifierValidationIssue {
  /// Creates an invalid MongoId issue.
  const IdentifierInvalidMongoIdIssue();

  @override
  String get code => 'identifier.invalidMongoId';

  @override
  String get defaultMessage => 'Invalid MongoDB ObjectId';
}

/// Identifier is not a valid Semantic Version.
final class IdentifierInvalidSemVerIssue extends IdentifierValidationIssue {
  /// Creates an invalid SemVer issue.
  const IdentifierInvalidSemVerIssue();

  @override
  String get code => 'identifier.invalidSemVer';

  @override
  String get defaultMessage => 'Invalid Semantic Version format';
}

/// Identifier is not a valid Nano ID.
final class IdentifierInvalidNanoIdIssue extends IdentifierValidationIssue {
  /// Expected length.
  final int expectedLength;

  /// Creates an invalid Nano ID issue.
  const IdentifierInvalidNanoIdIssue(this.expectedLength);

  @override
  String get code => 'identifier.invalidNanoId';

  @override
  String get defaultMessage =>
      'Invalid Nano ID format (expected $expectedLength characters)';
}
