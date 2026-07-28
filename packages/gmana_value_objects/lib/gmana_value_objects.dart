/// A package to handle domain value objects like Email, Password, Text, Number, Money, URL, and Phone.
///
/// It provides core abstractions for value objects as well as
/// concrete implementations for common use cases.
library;

export 'package:gmana_functional/gmana_functional.dart'
    show Either, Left, Right;

// Core
export 'src/core/validation_error.dart';
export 'src/core/value_object.dart';
export 'src/core/value_object_exception.dart';

// Email
export 'src/email/email.dart';
export 'src/email/email_errors.dart';
export 'src/email/email_validation_config.dart';
export 'src/email/email_validator.dart';

// Password
export 'src/password/password.dart';
export 'src/password/password_errors.dart';
export 'src/password/password_validation_config.dart';
export 'src/password/password_validator.dart';

// Text
export 'src/text/text_value.dart';
export 'src/text/text_errors.dart';
export 'src/text/text_validation_config.dart';
export 'src/text/text_validator.dart';

// Number
export 'src/number/number_value.dart';
export 'src/number/number_errors.dart';
export 'src/number/number_validation_config.dart';
export 'src/number/number_validator.dart';

// Money
export 'src/money/currency.dart';
export 'src/money/money.dart';
export 'src/money/money_errors.dart';
export 'src/money/money_validation_config.dart';
export 'src/money/money_validator.dart';

// URL
export 'src/url/url.dart';
export 'src/url/url_errors.dart';
export 'src/url/url_validation_config.dart';
export 'src/url/url_validator.dart';

// Phone
export 'src/phone/phone.dart';
export 'src/phone/phone_errors.dart';
export 'src/phone/phone_validation_config.dart';
export 'src/phone/phone_validator.dart';

// Presentation
export 'src/presentation/validation_error_messages.dart';
