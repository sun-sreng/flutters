/// Pure-Dart value objects for common text, numeric, contact, identifier,
/// network, money, and date-range domains.
///
/// Includes configurable validation, typed failures, presentation messages,
/// and extensions for inspecting and composing validated values.
library;

export 'package:gmana_functional/gmana_functional.dart'
    show Either, Left, Right;

// Core
export 'src/core/validation_error.dart';
export 'src/core/value_object.dart';
export 'src/core/value_object_exception.dart';

// Date Range
export 'src/date/date_range.dart';
export 'src/date/date_range_errors.dart';
export 'src/date/date_range_validator.dart';
export 'src/date/date_range_value.dart';

// Email
export 'src/email/email.dart';
export 'src/email/email_errors.dart';
export 'src/email/email_validation_config.dart';
export 'src/email/email_validator.dart';

// Extensions
export 'src/extensions/date_range_extensions.dart';
export 'src/extensions/validation_config_extensions.dart';
export 'src/extensions/value_object_result_extensions.dart';

// Identifier
export 'src/identifier/identifier_errors.dart';
export 'src/identifier/identifier_validation_config.dart';
export 'src/identifier/identifier_validator.dart';
export 'src/identifier/identifier_value.dart';

// Money
export 'src/money/currency.dart';
export 'src/money/money.dart';
export 'src/money/money_errors.dart';
export 'src/money/money_validation_config.dart';
export 'src/money/money_validator.dart';

// Network
export 'src/network/network_address_value.dart';
export 'src/network/network_errors.dart';
export 'src/network/network_validation_config.dart';
export 'src/network/network_validator.dart';

// Number
export 'src/number/number_errors.dart';
export 'src/number/number_validation_config.dart';
export 'src/number/number_validator.dart';
export 'src/number/number_value.dart';

// Password
export 'src/password/password.dart';
export 'src/password/password_errors.dart';
export 'src/password/password_validation_config.dart';
export 'src/password/password_validator.dart';

// Phone
export 'src/phone/phone.dart';
export 'src/phone/phone_errors.dart';
export 'src/phone/phone_validation_config.dart';
export 'src/phone/phone_validator.dart';

// Text
export 'src/text/text_errors.dart';
export 'src/text/text_validation_config.dart';
export 'src/text/text_validator.dart';
export 'src/text/text_value.dart';

// URL
export 'src/url/url.dart';
export 'src/url/url_errors.dart';
export 'src/url/url_validation_config.dart';
export 'src/url/url_validator.dart';

// Presentation
export 'src/presentation/validation_error_messages.dart';
