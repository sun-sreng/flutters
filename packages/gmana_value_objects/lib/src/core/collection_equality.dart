import 'package:meta/meta.dart';

/// Returns `true` when [a] and [b] are both null, or contain the same elements.
///
/// Internal helper so `@immutable` config classes can implement structural
/// equality without depending on `package:collection`.
@internal
bool setEquals<T>(Set<T>? a, Set<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final element in a) {
    if (!b.contains(element)) return false;
  }
  return true;
}

/// Returns `true` when [a] and [b] are both null, or are equal element-by-element.
@internal
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
