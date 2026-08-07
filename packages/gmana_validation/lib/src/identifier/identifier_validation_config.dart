/// Supported identifier validation types.
enum IdentifierType {
  /// Accepts any string non-empty.
  any,

  /// UUID validation.
  uuid,

  /// ULID validation.
  ulid,

  /// IMEI validation.
  imei,

  /// EAN-8 or EAN-13 barcode validation.
  ean,

  /// Credit card number (Luhn) validation.
  creditCard,

  /// MongoDB ObjectId validation.
  mongoId,

  /// Semantic Versioning (SemVer) validation.
  semVer,

  /// Nano ID validation.
  nanoId,
}

/// Configuration options for identifier validation.
final class IdentifierValidationConfig {
  /// Whether an empty or whitespace-only string is considered valid.
  final bool allowEmpty;

  /// Whether whitespace around the input should be trimmed before validation.
  final bool trimWhitespace;

  /// The required identifier type.
  final IdentifierType requiredType;

  /// Specific UUID version to require ('3', '4', '5', or null for any).
  final String? uuidVersion;

  /// Specific EAN version to require ('8', '13', or null for any).
  final String? eanVersion;

  /// Expected length for Nano ID (defaults to 21).
  final int nanoIdLength;

  /// Creates an [IdentifierValidationConfig].
  const IdentifierValidationConfig({
    this.allowEmpty = false,
    this.trimWhitespace = true,
    this.requiredType = IdentifierType.any,
    this.uuidVersion,
    this.eanVersion,
    this.nanoIdLength = 21,
  });
}
