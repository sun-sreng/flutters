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
export 'utilities.dart';
export 'validation.dart';
// gmana_value_objects still declares its own validators, and its own email,
// password and text configs, under the names gmana_validation uses. Those are
// hidden so the gmana_validation declarations win. The identifier, network,
// number, phone and URL configs are no longer listed: both packages now export
// the same class.
export 'value_objects.dart'
    hide
        EmailValidationConfig,
        EmailValidator,
        IdentifierValidator,
        NetworkValidator,
        NumberValidator,
        PasswordValidationConfig,
        PasswordValidator,
        PhoneValidator,
        TextValidationConfig,
        TextValidator,
        UrlValidator;
