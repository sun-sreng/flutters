## Unreleased

- Added `==`, `hashCode`, and `copyWith` to `EmailValidationConfig`,
  `IdentifierValidationConfig`, `NetworkValidationConfig`,
  `NumberValidationConfig`, `PhoneValidationConfig`, and `UrlValidationConfig`.
  `gmana_value_objects` now uses these classes instead of its own copies.
- Added `NumberValidationConfig` presets `naturalNumber`, `percentage`,
  `price`, `age`, and `rating`.
- Changed `NumberValidationConfig.positiveInteger()` to default `min` to `0`
  instead of `null`. Validation results are unchanged, because negatives were
  already rejected; only `config.min` reads differently.
- Added `StringValidation` (`isValidEmail`, `isValidPassword`,
  `passwordStrength`, `isValidPhone`, and the other boolean shortcuts). It
  moved here from `gmana_extensions`, which re-exports it.
- Added `throwaway.email` to `kDefaultDisposableDomains`. It was the one domain
  in the `gmana_value_objects` list that this list lacked.
- Added a dependency on `package:meta` for `@immutable`.
- Added `GmanaValidationStringX` shortcuts for date, email, identifier,
  network, number, password, phone, text, and URL validation.
- Added `GmanaValidationResultX` inspection helpers: `isValid`, `isInvalid`,
  `issueOrNull`, `valueOrNull`, and `messageOrNull`.

## 0.0.1

- Initial
