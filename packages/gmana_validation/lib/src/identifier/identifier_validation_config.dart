import 'package:meta/meta.dart';

import '../core/set_equality.dart';

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
@immutable
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

  /// Returns a copy with the supplied fields replaced.
  ///
  /// Pass `null` explicitly to clear [uuidVersion] or [eanVersion]. Omitted
  /// fields retain their current values.
  IdentifierValidationConfig copyWith({
    bool? allowEmpty,
    bool? trimWhitespace,
    IdentifierType? requiredType,
    Object? uuidVersion = unsetConfigValue,
    Object? eanVersion = unsetConfigValue,
    int? nanoIdLength,
  }) {
    return IdentifierValidationConfig(
      allowEmpty: allowEmpty ?? this.allowEmpty,
      trimWhitespace: trimWhitespace ?? this.trimWhitespace,
      requiredType: requiredType ?? this.requiredType,
      uuidVersion:
          identical(uuidVersion, unsetConfigValue)
              ? this.uuidVersion
              : uuidVersion as String?,
      eanVersion:
          identical(eanVersion, unsetConfigValue)
              ? this.eanVersion
              : eanVersion as String?,
      nanoIdLength: nanoIdLength ?? this.nanoIdLength,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentifierValidationConfig &&
          other.allowEmpty == allowEmpty &&
          other.trimWhitespace == trimWhitespace &&
          other.requiredType == requiredType &&
          other.uuidVersion == uuidVersion &&
          other.eanVersion == eanVersion &&
          other.nanoIdLength == nanoIdLength;

  @override
  int get hashCode => Object.hash(
    allowEmpty,
    trimWhitespace,
    requiredType,
    uuidVersion,
    eanVersion,
    nanoIdLength,
  );
}
