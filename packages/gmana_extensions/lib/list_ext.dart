/// Extension on [Iterable] providing utilities for filtering and transforming nullable elements safely.
extension IterableNullableX<T extends Object> on Iterable<T?> {
  /// Removes null values, returning `Iterable<T>`.
  ///
  /// ```dart
  /// [1, null, 2].whereNotNull; // (1, 2)
  /// ```
  Iterable<T> get whereNotNull => whereType<T>();

  /// Shorthand for [compactMap] when you only want to strip nulls with
  /// no transformation - just `whereNotNull` as a method call for
  /// symmetry with [compactMap].
  Iterable<T> compact() => whereNotNull;

  /// Filters nulls after applying [transform].
  ///
  /// Unlike the original, [R] is the actual return type of the transform,
  /// so mapping to a different type is safe.
  ///
  /// ```dart
  /// [1, 2, null, 3].compactMap((e) => e?.isEven == true ? 'even' : null);
  /// // ('even')
  /// ```
  Iterable<R> compactMap<R extends Object>(R? Function(T?) transform) =>
      map(transform).whereType<R>();
}

/// Extension on [Iterable] of [Iterable]s providing methods to flatten nested collections.
extension IterableOfIterablesX<E> on Iterable<Iterable<E>> {
  /// Single-level flatten. Works on any `Iterable<Iterable<E>>`.
  ///
  /// ```dart
  /// [[1, 2], [3, 4]].flatten(); // (1, 2, 3, 4)
  /// ```
  Iterable<E> flatten() => expand((e) => e);

  /// Flatten to a [List].
  List<E> flattenToList() => [for (final inner in this) ...inner];
}

/// General utility extension on [Iterable] providing flat-mapping, grouping, and chunking capabilities.
extension IterableX<T> on Iterable<T> {
  /// Splits the iterable into chunks of [size].
  /// The last chunk may be smaller.
  ///
  /// ```dart
  /// [1, 2, 3, 4, 5].chunked(2); // ([1,2], [3,4], [5])
  /// ```
  Iterable<List<T>> chunked(int size) sync* {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be greater than zero');
    }

    var chunk = <T>[];
    for (final e in this) {
      chunk.add(e);
      if (chunk.length == size) {
        yield chunk;
        chunk = [];
      }
    }
    if (chunk.isNotEmpty) yield chunk;
  }

  /// Returns distinct elements by a derived key, preserving first-seen order.
  ///
  /// ```dart
  /// [1, 2, 1, 3, 2].distinctBy((e) => e); // (1, 2, 3)
  /// ```
  Iterable<T> distinctBy<K>(K Function(T) keyOf) sync* {
    final seen = <K>{};
    for (final e in this) {
      if (seen.add(keyOf(e))) yield e;
    }
  }

  /// Maps each element to an iterable, then flattens one level.
  ///
  /// Equivalent to `expand`, but named `flatMap` to match Kotlin/Swift/Rx
  /// conventions and pair naturally with [compactMap].
  ///
  /// ```dart
  /// [1, 2, 3].flatMap((e) => [e, e * 10]); // (1, 10, 2, 20, 3, 30)
  /// ```
  Iterable<R> flatMap<R>(Iterable<R> Function(T) transform) =>
      expand(transform);

  /// [flatMap] that discards nulls from the produced iterables.
  ///
  /// ```dart
  /// ['hello', 'hi', 'world']
  ///     .flatMapNotNull((s) => [s.startsWith('h') ? s.toUpperCase() : null]);
  /// // ('HELLO', 'HI')
  /// ```
  Iterable<R> flatMapNotNull<R extends Object>(
    Iterable<R?> Function(T) transform,
  ) => expand(transform).whereType<R>();

  /// Groups elements by a key derived from [keyOf].
  ///
  /// ```dart
  /// [1, 2, 3, 4].groupBy((e) => e.isEven ? 'even' : 'odd');
  /// // {odd: [1, 3], even: [2, 4]}
  /// ```
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final map = <K, List<T>>{};
    for (final e in this) {
      (map[keyOf(e)] ??= []).add(e);
    }
    return map;
  }

  /// Returns the first element matching [test], or `null` if none found.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Returns the last element matching [test], or `null` if none found.
  T? lastWhereOrNull(bool Function(T element) test) {
    T? result;
    var found = false;
    for (final element in this) {
      if (test(element)) {
        result = element;
        found = true;
      }
    }
    return found ? result : null;
  }

  /// Returns the single element matching [test], or `null` if zero or more than one match.
  T? singleWhereOrNull(bool Function(T element) test) {
    T? result;
    var matchCount = 0;
    for (final element in this) {
      if (test(element)) {
        matchCount++;
        if (matchCount > 1) return null;
        result = element;
      }
    }
    return matchCount == 1 ? result : null;
  }

  /// Splits elements into a pair of lists: `(matching, nonMatching)`.
  (List<T> matching, List<T> nonMatching) partition(
    bool Function(T element) predicate,
  ) {
    final matching = <T>[];
    final nonMatching = <T>[];
    for (final element in this) {
      if (predicate(element)) {
        matching.add(element);
      } else {
        nonMatching.add(element);
      }
    }
    return (matching, nonMatching);
  }

  /// Returns a sliding window of elements of size [size].
  ///
  /// [step] defines the window shift (default 1).
  /// If [partial] is true, smaller windows at the end are included.
  Iterable<List<T>> windowed(
    int size, {
    int step = 1,
    bool partial = false,
  }) sync* {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be greater than zero');
    }
    if (step <= 0) {
      throw ArgumentError.value(step, 'step', 'must be greater than zero');
    }

    final list = toList();
    for (var i = 0; i < list.length; i += step) {
      final end = i + size;
      if (end <= list.length) {
        yield list.sublist(i, end);
      } else if (partial && i < list.length) {
        yield list.sublist(i);
      }
    }
  }

  /// Associates each element into a [MapEntry] returned by [transform].
  Map<K, V> associate<K, V>(MapEntry<K, V> Function(T element) transform) {
    final result = <K, V>{};
    for (final element in this) {
      final entry = transform(element);
      result[entry.key] = entry.value;
    }
    return result;
  }

  /// Associates each element by a key derived from [keyOf].
  Map<K, T> associateBy<K>(K Function(T element) keyOf) {
    final result = <K, T>{};
    for (final element in this) {
      result[keyOf(element)] = element;
    }
    return result;
  }

  /// Associates each element with a value derived from [valueOf].
  Map<T, V> associateWith<V>(V Function(T element) valueOf) {
    final result = <T, V>{};
    for (final element in this) {
      result[element] = valueOf(element);
    }
    return result;
  }

  /// Inserts [element] between every element in this iterable.
  Iterable<T> intersperse(T element) sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;
    yield iterator.current;
    while (iterator.moveNext()) {
      yield element;
      yield iterator.current;
    }
  }

  /// Yields elements while [predicate] holds, plus the first element that fails [predicate].
  Iterable<T> takeWhileInclusive(bool Function(T element) predicate) sync* {
    for (final element in this) {
      yield element;
      if (!predicate(element)) break;
    }
  }
}
