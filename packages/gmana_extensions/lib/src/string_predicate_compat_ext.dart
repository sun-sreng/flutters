import 'package:gmana_predicates/gmana_predicates.dart'
    as dates
    show
        isAfter,
        isBefore,
        isBetween,
        isDate,
        isFuture,
        isLeapYear,
        isPast,
        isToday,
        isWeekday,
        isWeekend;
import 'package:gmana_predicates/gmana_predicates.dart'
    as preds
    show isAlpha, isEmail;

/// String classification members that duplicate `gmana_predicates`.
///
/// These used to live on `StringX` and `StringDateX`. `gmana_predicates`
/// declares members with the same names on [String], and two extensions
/// declaring the same member on the same type make every call ambiguous once
/// both are imported. They are kept here, unchanged, in an extension of their
/// own so `package:gmana/gmana.dart` can hide it.
extension StringPredicateCompatX on String {
  /// Returns true if the string only contains letters.
  @Deprecated(
    'Use isAlpha from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isAlpha => preds.isAlpha(this);

  /// Returns true if the string is a valid email format.
  ///
  /// Surrounding whitespace is ignored.
  @Deprecated(
    'Use trim().isEmail from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isEmail => preds.isEmail(trim());

  /// Returns true if the string represents a valid number.
  @Deprecated(
    'Use double.tryParse(value) != null instead; isNumeric from '
    'package:gmana_predicates accepts digits only. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isNumeric => double.tryParse(this) != null;

  /// Returns true if the string is a valid URL.
  @Deprecated(
    "Use isUrl(allowedSchemes: {'http', 'https'}) from "
    'package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isUrl {
    final uri = Uri.tryParse(trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  /// Case-insensitive [String.contains].
  @Deprecated(
    'Use containsIgnoreCase from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool containsIgnoreCase(String other) =>
      toLowerCase().contains(other.toLowerCase());

  /// Whether this string is a recognizable date value.
  ///
  /// Returns `true` for valid ISO 8601 date strings.
  @Deprecated(
    'Use isDate from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isDate => dates.isDate(this);

  /// Whether this date is after [reference].
  ///
  /// When [reference] is omitted, compares against the current date/time (now).
  @Deprecated(
    'Use isAfter from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool isAfter([String? reference]) => dates.isAfter(this, reference);

  /// Whether this date is before [reference].
  ///
  /// When [reference] is omitted, compares against the current date/time (now).
  @Deprecated(
    'Use isBefore from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool isBefore([String? reference]) => dates.isBefore(this, reference);

  /// Whether this date falls within the range [[from], [to]] exclusively.
  @Deprecated(
    'Use isBetween from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool isBetween(String from, String to) => dates.isBetween(this, from, to);

  /// Whether this date represents today's date (UTC).
  @Deprecated(
    'Use isToday from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isToday => dates.isToday(this);

  /// Whether this date is strictly before today.
  @Deprecated(
    'Use isPast from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isPast => dates.isPast(this);

  /// Whether this date is strictly after today.
  @Deprecated(
    'Use isFuture from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isFuture => dates.isFuture(this);

  /// Whether this date falls on a Saturday or Sunday.
  @Deprecated(
    'Use isWeekend from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isWeekend => dates.isWeekend(this);

  /// Whether this date falls on a Monday through Friday.
  @Deprecated(
    'Use isWeekday from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isWeekday => dates.isWeekday(this);

  /// Whether the year of this date is a leap year.
  @Deprecated(
    'Use isLeapYear from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isLeapYear => dates.isLeapYear(this);
}

/// Nullable [String] classification members that duplicate `gmana_predicates`.
///
/// Split out of `StringNullableX` for the same reason as
/// [StringPredicateCompatX].
extension StringNullablePredicateCompatX on String? {
  /// Returns true if the string is null or strictly empty.
  @Deprecated(
    'Use isNullOrEmpty from package:gmana_predicates instead. '
    'This duplicate will be removed before 1.0.',
  )
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
