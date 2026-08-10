import '../date/date_range.dart';

/// Inclusive interval operations for [DateRange].
///
/// Each operation uses the UTC-normalized endpoints stored by [DateRange] and
/// leaves both input ranges unchanged.
///
/// Both ranges are expected to have ordered endpoints. For untrusted dates,
/// construct the range through `DateRangeValue.tryParse` before using these
/// operations.
extension GmanaDateRangeX on DateRange {
  /// Whether this range and [other] share at least one instant.
  ///
  /// Endpoints are inclusive, so ranges that only touch at one endpoint
  /// overlap.
  bool overlaps(DateRange other) {
    return !end.isBefore(other.start) && !other.end.isBefore(start);
  }

  /// Whether this range fully contains [other], including equal endpoints.
  bool containsRange(DateRange other) {
    return !other.start.isBefore(start) && !other.end.isAfter(end);
  }

  /// The shared portion of this range and [other], or `null` when disjoint.
  ///
  /// Ranges that touch at one endpoint return a zero-duration range at that
  /// instant.
  DateRange? intersection(DateRange other) {
    if (!overlaps(other)) {
      return null;
    }

    final intersectionStart = start.isAfter(other.start) ? start : other.start;
    final intersectionEnd = end.isBefore(other.end) ? end : other.end;
    return DateRange(start: intersectionStart, end: intersectionEnd);
  }

  /// The smallest range that contains both this range and [other].
  ///
  /// Disjoint ranges are spanned without requiring them to overlap.
  DateRange span(DateRange other) {
    final spanStart = start.isBefore(other.start) ? start : other.start;
    final spanEnd = end.isAfter(other.end) ? end : other.end;
    return DateRange(start: spanStart, end: spanEnd);
  }
}
