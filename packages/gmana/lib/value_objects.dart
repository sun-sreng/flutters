/// Pure-Dart value objects for common text, numeric, contact, identifier,
/// network, money, and date-range domains.
///
/// Each value object validates with the matching validator from
/// `validation.dart` and reports failures as its `*ValidationIssue` types.
library;

export 'functional.dart' show Either, Left, Right;

// Core
export 'src/value_objects/core/value_object.dart';
export 'src/value_objects/core/value_object_exception.dart';

// Date range
export 'src/value_objects/date/date_range.dart';
export 'src/value_objects/date/date_range_validation_issue.dart';
export 'src/value_objects/date/date_range_validator.dart';
export 'src/value_objects/date/date_range_value.dart';
export 'src/value_objects/extensions/date_range_extensions.dart';

// Contact, text, numeric, identifier, network
export 'src/value_objects/email/email.dart';
export 'src/value_objects/identifier/identifier_value.dart';
export 'src/value_objects/network/network_address_value.dart';
export 'src/value_objects/number/number_value.dart';
export 'src/value_objects/password/password.dart';
export 'src/value_objects/phone/phone_value.dart';
export 'src/value_objects/text/text_value.dart';
export 'src/value_objects/url/url_value.dart';

// Money
export 'src/value_objects/money/currency.dart';
export 'src/value_objects/money/money.dart';
export 'src/value_objects/money/money_validation_config.dart';
export 'src/value_objects/money/money_validation_issue.dart';
export 'src/value_objects/money/money_validator.dart';
