## Unreleased

### Added

- `==`, `hashCode`, and `copyWith` on `EmailValidationConfig`,
  `IdentifierValidationConfig`, `NetworkValidationConfig`,
  `NumberValidationConfig`, `PhoneValidationConfig`, and `UrlValidationConfig`.
  `gmana_value_objects` now uses these classes instead of its own copies.
- `NumberValidationConfig` presets `naturalNumber`, `percentage`, `price`,
  `age`, and `rating`.
- `StringValidation` (`isValidEmail`, `isValidPassword`, `passwordStrength`,
  `isValidPhone`, and the other boolean shortcuts). It moved here from
  `gmana_extensions`, which re-exports it.
- `GmanaValidationStringX` shortcuts for date, email, identifier, network,
  number, password, phone, text, and URL validation.
- `GmanaValidationResultX` inspection helpers: `isValid`, `isInvalid`,
  `issueOrNull`, `valueOrNull`, and `messageOrNull`.
- `throwaway.email` in `kDefaultDisposableDomains`. It was the one domain in
  the `gmana_value_objects` list that this list lacked.
- A dependency on `package:meta`, for `@immutable`.

### Changed

- `NumberValidationConfig.positiveInteger()` defaults `min` to `0` instead of
  `null`. Validation results are unchanged, because negatives were already
  rejected; only `config.min` reads differently.

## 0.0.1

- Initial
