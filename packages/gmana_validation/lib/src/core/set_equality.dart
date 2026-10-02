/// Whether [a] and [b] contain the same elements.
bool setEquals<T>(Set<T> a, Set<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  return a.containsAll(b);
}

/// Marks a `copyWith` argument as omitted, so `null` can mean "clear".
const Object unsetConfigValue = Object();
