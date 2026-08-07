/// Pure Dart boolean predicate functions for string classification.
///
/// Predicates are grouped by concern:
/// - `string_predicates` — alpha, alphanumeric, base64, email, hex, JSON, etc.
/// - `date_predicates` — date parsing, past/future/today, weekday, leap year
/// - `identifier_predicates` — UUID, credit card, ISBN, IBAN, MongoId, FQDN
/// - `network_predicates` — IPv4, IPv6, hostnames, postal codes
/// - `numeric_predicates` — divisibility, sign, primality
/// - `combinators` — composing predicates with and/or/not
///
/// Regex constants live under `lib/src/` and are not part of the public API.
library;

export 'annotations.dart';
export 'predicates/combinators.dart';
export 'predicates/date_predicates.dart';
export 'predicates/extensions.dart';
export 'predicates/identifier_predicates.dart';
export 'predicates/network_predicates.dart';
export 'predicates/numeric_predicates.dart';
export 'predicates/string_predicates.dart';
