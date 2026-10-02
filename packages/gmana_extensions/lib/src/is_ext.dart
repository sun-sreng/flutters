// `StringValidation` now lives in gmana_validation, next to the validators it
// calls. It is re-exported here so `package:gmana_extensions` keeps exposing
// the same declaration.
export 'package:gmana_validation/gmana_validation.dart'
    show
        PasswordStrength,
        PasswordValidationConfig,
        PasswordValidator,
        StringValidation;
