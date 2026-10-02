library;

// The two compat extensions are hidden because every member they declare —
// `isEmail`, `isUrl`, `isDate`, `isNullOrEmpty` and the rest — is also declared
// on `String` by gmana_predicates, which `validation.dart` exports. Two
// extensions declaring the same member on the same type make every call
// ambiguous, so `'a@b.c'.isEmail` failed to compile for anyone importing this
// library. `extensions.dart` on its own still exports them.
export 'extensions.dart'
    hide StringNullablePredicateCompatX, StringPredicateCompatX;
export 'functional.dart';
export 'src/result_bridge.dart';
export 'utilities.dart';
export 'validation.dart';
export 'value_objects.dart'
    hide
        EmailValidationConfig,
        EmailValidator,
        IdentifierType,
        IdentifierValidationConfig,
        IdentifierValidator,
        NetworkAddressType,
        NetworkValidationConfig,
        NetworkValidator,
        NumberValidationConfig,
        NumberValidator,
        PasswordValidationConfig,
        PasswordValidator,
        PhoneValidationConfig,
        PhoneValidator,
        TextValidationConfig,
        TextValidator,
        UrlValidationConfig,
        UrlValidator;
