// ─── Null-safety utilities ────────────────────────────────────────────────

/// Extension on [Iterable] providing utilities for filtering and transforming nullable elements safely.
extension IterableNullableX<T extends Object> on Iterable<T?> {
  /// Removes null values, returning `Iterable<T>`.
  ///
  /// ```dart
  /// [1, null, 2].whereNotNull; // (1, 2)
  /// ```
  Iterable<T> get whereNotNull => whereType<T>();

  /// Shorthand for [compactMap] when you only want to strip nulls with
  /// no transformation — just `whereNotNull` as a method call for
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

// ─── Flatten / FlatMap ───────────────────────────────────────────────────

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
    assert(size > 0, 'Chunk size must be > 0');
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
}
