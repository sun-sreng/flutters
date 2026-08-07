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
}

/// Error indicating that the identifier is not a valid UUID.
final class IdentifierInvalidUuid extends IdentifierError {
  /// Specified version checked.
  final String? version;

  /// Creates an [IdentifierInvalidUuid] error.
  const IdentifierInvalidUuid([this.version]);
}

/// Error indicating that the identifier is not a valid ULID.
final class IdentifierInvalidUlid extends IdentifierError {
  /// Creates an [IdentifierInvalidUlid] error.
  const IdentifierInvalidUlid();
}

/// Error indicating that the identifier is not a valid IMEI.
final class IdentifierInvalidImei extends IdentifierError {
  /// Creates an [IdentifierInvalidImei] error.
  const IdentifierInvalidImei();
}

/// Error indicating that the identifier is not a valid EAN.
final class IdentifierInvalidEan extends IdentifierError {
  /// Specified EAN version checked.
  final String? version;

  /// Creates an [IdentifierInvalidEan] error.
  const IdentifierInvalidEan([this.version]);
}

/// Error indicating that the identifier is not a valid credit card.
final class IdentifierInvalidCreditCard extends IdentifierError {
  /// Creates an [IdentifierInvalidCreditCard] error.
  const IdentifierInvalidCreditCard();
}

/// Error indicating that the identifier is not a valid MongoId.
final class IdentifierInvalidMongoId extends IdentifierError {
  /// Creates an [IdentifierInvalidMongoId] error.
  const IdentifierInvalidMongoId();
}

/// Error indicating that the identifier is not a valid SemVer.
final class IdentifierInvalidSemVer extends IdentifierError {
  /// Creates an [IdentifierInvalidSemVer] error.
  const IdentifierInvalidSemVer();
}

/// Error indicating that the identifier is not a valid NanoId.
final class IdentifierInvalidNanoId extends IdentifierError {
  /// Expected length.
  final int expectedLength;

  /// Creates an [IdentifierInvalidNanoId] error.
  const IdentifierInvalidNanoId(this.expectedLength);
}
