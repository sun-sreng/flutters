import '../core/validation_error.dart';

/// Base class for all identifier-related validation errors.
sealed class IdentifierError extends ValidationError {
  /// Internal constructor for [IdentifierError].
  const IdentifierError();
}

/// Error indicating that the identifier string is empty.
final class IdentifierEmpty extends IdentifierError {
  /// Creates an [IdentifierEmpty] error.
  const IdentifierEmpty();

  @override
  String get code => 'identifier_empty';
}

/// Error indicating that the identifier is not a valid UUID.
final class IdentifierInvalidUuid extends IdentifierError {
  /// Specified version checked.
  final String? version;

  /// Creates an [IdentifierInvalidUuid] error.
  const IdentifierInvalidUuid([this.version]);

  @override
  String get code => 'identifier_invalid_uuid';
}

/// Error indicating that the identifier is not a valid ULID.
final class IdentifierInvalidUlid extends IdentifierError {
  /// Creates an [IdentifierInvalidUlid] error.
  const IdentifierInvalidUlid();

  @override
  String get code => 'identifier_invalid_ulid';
}

/// Error indicating that the identifier is not a valid IMEI.
final class IdentifierInvalidImei extends IdentifierError {
  /// Creates an [IdentifierInvalidImei] error.
  const IdentifierInvalidImei();

  @override
  String get code => 'identifier_invalid_imei';
}

/// Error indicating that the identifier is not a valid EAN.
final class IdentifierInvalidEan extends IdentifierError {
  /// Specified EAN version checked.
  final String? version;

  /// Creates an [IdentifierInvalidEan] error.
  const IdentifierInvalidEan([this.version]);

  @override
  String get code => 'identifier_invalid_ean';
}

/// Error indicating that the identifier is not a valid credit card.
final class IdentifierInvalidCreditCard extends IdentifierError {
  /// Creates an [IdentifierInvalidCreditCard] error.
  const IdentifierInvalidCreditCard();

  @override
  String get code => 'identifier_invalid_credit_card';
}

/// Error indicating that the identifier is not a valid MongoId.
final class IdentifierInvalidMongoId extends IdentifierError {
  /// Creates an [IdentifierInvalidMongoId] error.
  const IdentifierInvalidMongoId();

  @override
  String get code => 'identifier_invalid_mongo_id';
}

/// Error indicating that the identifier is not a valid SemVer.
final class IdentifierInvalidSemVer extends IdentifierError {
  /// Creates an [IdentifierInvalidSemVer] error.
  const IdentifierInvalidSemVer();

  @override
  String get code => 'identifier_invalid_sem_ver';
}

/// Error indicating that the identifier is not a valid NanoId.
final class IdentifierInvalidNanoId extends IdentifierError {
  /// Expected length.
  final int expectedLength;

  /// Creates an [IdentifierInvalidNanoId] error.
  const IdentifierInvalidNanoId(this.expectedLength);

  @override
  String get code => 'identifier_invalid_nano_id';
}
