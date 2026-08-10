import '../identifier/identifier_validation_config.dart';
import '../network/network_validation_config.dart';
import '../phone/phone_validation_config.dart';
import '../url/url_validation_config.dart';

const Object _unsetConfigValue = Object();

/// Copy helpers for [PhoneValidationConfig].
extension GmanaPhoneValidationConfigX on PhoneValidationConfig {
  /// Returns a copy with the supplied fields replaced.
  ///
  /// Omitted fields retain their current values.
  PhoneValidationConfig copyWith({
    bool? requirePlusPrefix,
    int? minDigits,
    int? maxDigits,
  }) {
    return PhoneValidationConfig(
      requirePlusPrefix: requirePlusPrefix ?? this.requirePlusPrefix,
      minDigits: minDigits ?? this.minDigits,
      maxDigits: maxDigits ?? this.maxDigits,
    );
  }
}

/// Copy helpers for [UrlValidationConfig].
extension GmanaUrlValidationConfigX on UrlValidationConfig {
  /// Returns a copy with the supplied fields replaced.
  ///
  /// Omitted fields retain their current values.
  UrlValidationConfig copyWith({
    Set<String>? allowedSchemes,
    bool? requireHost,
  }) {
    return UrlValidationConfig(
      allowedSchemes: allowedSchemes ?? this.allowedSchemes,
      requireHost: requireHost ?? this.requireHost,
    );
  }
}

/// Copy helpers for [IdentifierValidationConfig].
extension GmanaIdentifierValidationConfigX on IdentifierValidationConfig {
  /// Returns a copy with the supplied fields replaced.
  ///
  /// Pass `null` explicitly to clear [IdentifierValidationConfig.uuidVersion]
  /// or [IdentifierValidationConfig.eanVersion]. Omitted fields retain their
  /// current values.
  IdentifierValidationConfig copyWith({
    bool? allowEmpty,
    bool? trimWhitespace,
    IdentifierType? requiredType,
    Object? uuidVersion = _unsetConfigValue,
    Object? eanVersion = _unsetConfigValue,
    int? nanoIdLength,
  }) {
    return IdentifierValidationConfig(
      allowEmpty: allowEmpty ?? this.allowEmpty,
      trimWhitespace: trimWhitespace ?? this.trimWhitespace,
      requiredType: requiredType ?? this.requiredType,
      uuidVersion:
          identical(uuidVersion, _unsetConfigValue)
              ? this.uuidVersion
              : uuidVersion as String?,
      eanVersion:
          identical(eanVersion, _unsetConfigValue)
              ? this.eanVersion
              : eanVersion as String?,
      nanoIdLength: nanoIdLength ?? this.nanoIdLength,
    );
  }
}

/// Copy helpers for [NetworkValidationConfig].
extension GmanaNetworkValidationConfigX on NetworkValidationConfig {
  /// Returns a copy with the supplied fields replaced.
  ///
  /// Pass `null` explicitly to clear [NetworkValidationConfig.ipVersion]. An
  /// omitted field retains its current value.
  NetworkValidationConfig copyWith({
    bool? allowEmpty,
    bool? trimWhitespace,
    NetworkAddressType? requiredType,
    Object? ipVersion = _unsetConfigValue,
  }) {
    return NetworkValidationConfig(
      allowEmpty: allowEmpty ?? this.allowEmpty,
      trimWhitespace: trimWhitespace ?? this.trimWhitespace,
      requiredType: requiredType ?? this.requiredType,
      ipVersion:
          identical(ipVersion, _unsetConfigValue)
              ? this.ipVersion
              : ipVersion as int?,
    );
  }
}
