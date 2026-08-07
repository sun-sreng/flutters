/// Re-exports predicates and typed validators.
///
/// NOTE: `asFormValidator` has moved to `package:gmana_form/gmana_form.dart`.
library;

// Boolean string/date/identifier predicates.
//
// `GmanaDateTimePredicatesExt` is hidden because its four members —
// `isWeekend`, `isWeekday`, `isLeapYear`, `isToday` — are all also on
// `DateTimeX` from gmana_extensions, which this facade exports too. Two
// extensions declaring the same member on the same type make every call
// ambiguous, so `DateTime.now().isWeekend` failed to compile for anyone
// importing this library. `DateTimeX` is a superset, so nothing is lost.
export 'package:gmana_predicates/gmana_predicates.dart'
    hide GmanaDateTimePredicatesExt;

// Typed validators with Either-based results
export 'package:gmana_validation/gmana_validation.dart';
