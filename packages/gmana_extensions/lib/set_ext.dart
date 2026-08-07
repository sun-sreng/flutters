/// Set algebra and membership helpers on [Set].
extension SetX<T> on Set<T> {
  /// Adds [value] when absent, removes it when present.
  ///
  /// Mutates this set and returns `true` when [value] ended up added.
  ///
  /// ```dart
  /// final selected = <int>{1, 2};
  /// selected.toggle(2); // false — 2 removed
  /// selected.toggle(3); // true  — 3 added
  /// ```
  bool toggle(T value) {
    if (contains(value)) {
      remove(value);
      return false;
    }
    add(value);
    return true;
  }

  /// Returns a new set with [value] added when absent, removed when present.
  Set<T> toggled(T value) {
    final result = Set<T>.of(this);
    result.toggle(value);
    return result;
  }

  /// Whether every element of this set is also in [other].
  bool isSubsetOf(Set<T> other) => every(other.contains);

  /// Whether this set contains every element of [other].
  bool isSupersetOf(Set<T> other) => other.every(contains);

  /// Whether this set is a subset of [other] but not equal to it.
  bool isProperSubsetOf(Set<T> other) =>
      length < other.length && isSubsetOf(other);

  /// Whether this set is a superset of [other] but not equal to it.
  bool isProperSupersetOf(Set<T> other) =>
      length > other.length && isSupersetOf(other);

  /// Whether this set shares at least one element with [other].
  bool intersects(Iterable<T> other) => other.any(contains);

  /// Whether this set shares no element with [other].
  bool isDisjointFrom(Iterable<T> other) => !intersects(other);

  /// Elements present in exactly one of this set and [other].
  ///
  /// ```dart
  /// {1, 2, 3}.symmetricDifference({3, 4}); // {1, 2, 4}
  /// ```
  Set<T> symmetricDifference(Set<T> other) =>
      difference(other)..addAll(other.difference(this));

  /// Adds every element of [values] that is not already present.
  ///
  /// Returns the elements that were actually added.
  Set<T> addAllNew(Iterable<T> values) {
    final added = <T>{};
    for (final value in values) {
      if (add(value)) added.add(value);
    }
    return added;
  }
}

/// Safe defaults for nullable [Set] references.
extension SetNullableX<T> on Set<T>? {
  /// Whether this set is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Whether this set is non-null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns this set, or an empty set if null.
  Set<T> get orEmpty => this ?? <T>{};
}
