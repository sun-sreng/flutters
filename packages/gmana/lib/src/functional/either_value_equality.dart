import 'package:meta/meta.dart';

/// Whether two `Left` or two `Right` values are equal.
///
/// This is `==`, except that two lists are equal when they have equal
/// elements in the same order. The comparison is shallow: nested lists are
/// still compared with `==`.
@internal
bool eitherValueEquals(Object? a, Object? b) {
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  return a == b;
}

/// A hash code consistent with [eitherValueEquals].
@internal
int eitherValueHash(Object? value) =>
    value is List ? Object.hashAll(value) : value.hashCode;
