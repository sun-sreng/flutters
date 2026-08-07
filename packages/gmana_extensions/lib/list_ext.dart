import 'dart:math' as math;

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

  /// The first element, or `null` when empty.
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }

  /// The last element, or `null` when empty.
  T? get lastOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    var result = iterator.current;
    while (iterator.moveNext()) {
      result = iterator.current;
    }
    return result;
  }

  /// The element at [index], or `null` when out of range.
  ///
  /// Negative indices return `null` rather than throwing.
  T? elementAtOrNull(int index) {
    if (index < 0) return null;
    var remaining = index;
    for (final element in this) {
      if (remaining == 0) return element;
      remaining--;
    }
    return null;
  }

  /// Whether no element satisfies [test]. The inverse of [Iterable.any].
  bool none(bool Function(T element) test) => !any(test);

  /// Number of elements satisfying [test].
  int countWhere(bool Function(T element) test) {
    var count = 0;
    for (final element in this) {
      if (test(element)) count++;
    }
    return count;
  }

  /// Elements that do *not* satisfy [test].
  Iterable<T> whereNot(bool Function(T element) test) =>
      where((element) => !test(element));

  /// Maps each element and drops the `null` results.
  ///
  /// ```dart
  /// ['1', 'x', '3'].mapNotNull(int.tryParse); // (1, 3)
  /// ```
  Iterable<R> mapNotNull<R extends Object>(R? Function(T element) transform) =>
      map(transform).whereType<R>();

  /// Like [Iterable.map] but the transform also receives the index.
  Iterable<R> mapIndexed<R>(R Function(int index, T element) transform) sync* {
    var index = 0;
    for (final element in this) {
      yield transform(index++, element);
    }
  }

  /// Like [Iterable.where] but the test also receives the index.
  Iterable<T> whereIndexed(bool Function(int index, T element) test) sync* {
    var index = 0;
    for (final element in this) {
      if (test(index++, element)) yield element;
    }
  }

  /// Like [Iterable.forEach] but the action also receives the index.
  void forEachIndexed(void Function(int index, T element) action) {
    var index = 0;
    for (final element in this) {
      action(index++, element);
    }
  }

  /// Like [Iterable.fold] but [combine] also receives the index.
  R foldIndexed<R>(
    R initialValue,
    R Function(int index, R previous, T element) combine,
  ) {
    var index = 0;
    var value = initialValue;
    for (final element in this) {
      value = combine(index++, value, element);
    }
    return value;
  }

  /// Pairs elements positionally with [other], stopping at the shorter one.
  ///
  /// ```dart
  /// [1, 2, 3].zip(['a', 'b']); // ((1, 'a'), (2, 'b'))
  /// ```
  Iterable<(T, R)> zip<R>(Iterable<R> other) sync* {
    final a = iterator;
    final b = other.iterator;
    while (a.moveNext() && b.moveNext()) {
      yield (a.current, b.current);
    }
  }

  /// Combines elements positionally with [other] via [combine].
  Iterable<V> zipWith<R, V>(
    Iterable<R> other,
    V Function(T a, R b) combine,
  ) sync* {
    final a = iterator;
    final b = other.iterator;
    while (a.moveNext() && b.moveNext()) {
      yield combine(a.current, b.current);
    }
  }

  /// A new list sorted ascending by the key returned from [selector].
  ///
  /// ```dart
  /// people.sortedBy((p) => p.age);
  /// ```
  List<T> sortedBy(Comparable<Object?> Function(T element) selector) =>
      toList()..sort((a, b) => selector(a).compareTo(selector(b)));

  /// A new list sorted descending by the key returned from [selector].
  List<T> sortedByDescending(
    Comparable<Object?> Function(T element) selector,
  ) => toList()..sort((a, b) => selector(b).compareTo(selector(a)));

  /// A new list sorted with [compare], leaving this iterable untouched.
  List<T> sortedWith(Comparator<T> compare) => toList()..sort(compare);

  /// The element with the largest [selector] key, or `null` when empty.
  T? maxBy(Comparable<Object?> Function(T element) selector) =>
      _extremeBy(selector, greater: true);

  /// The element with the smallest [selector] key, or `null` when empty.
  T? minBy(Comparable<Object?> Function(T element) selector) =>
      _extremeBy(selector, greater: false);

  T? _extremeBy(
    Comparable<Object?> Function(T element) selector, {
    required bool greater,
  }) {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;

    var best = iterator.current;
    var bestKey = selector(best);
    while (iterator.moveNext()) {
      final candidate = iterator.current;
      final key = selector(candidate);
      final comparison = key.compareTo(bestKey);
      if (greater ? comparison > 0 : comparison < 0) {
        best = candidate;
        bestKey = key;
      }
    }
    return best;
  }

  /// Sum of [selector] applied to every element. Returns `0` when empty.
  num sumBy(num Function(T element) selector) {
    num total = 0;
    for (final element in this) {
      total += selector(element);
    }
    return total;
  }

  /// Mean of [selector] applied to every element, or `null` when empty.
  double? averageBy(num Function(T element) selector) {
    num total = 0;
    var count = 0;
    for (final element in this) {
      total += selector(element);
      count++;
    }
    return count == 0 ? null : total / count;
  }

  /// Renders the iterable as a string with fine-grained control.
  ///
  /// ```dart
  /// [1, 2, 3, 4].joinToString(prefix: '[', suffix: ']', limit: 2);
  /// // '[1, 2, ...]'
  /// ```
  String joinToString({
    String separator = ', ',
    String prefix = '',
    String suffix = '',
    String Function(T element)? transform,
    int? limit,
    String truncated = '...',
  }) {
    if (limit != null && limit < 0) {
      throw ArgumentError.value(limit, 'limit', 'must not be negative');
    }

    final buffer = StringBuffer(prefix);
    var count = 0;
    for (final element in this) {
      if (limit != null && count == limit) {
        buffer
          ..write(separator)
          ..write(truncated);
        break;
      }
      if (count > 0) buffer.write(separator);
      buffer.write(transform != null ? transform(element) : '$element');
      count++;
    }
    return (buffer..write(suffix)).toString();
  }

  /// A uniformly random element, or `null` when empty.
  T? randomOrNull([math.Random? random]) {
    final list = this is List<T> ? this as List<T> : toList();
    if (list.isEmpty) return null;
    return list[(random ?? _sharedRandom).nextInt(list.length)];
  }

  /// Splits into runs, starting a new run whenever [shouldSplit] returns
  /// `true` for a consecutive pair.
  ///
  /// ```dart
  /// [1, 2, 5, 6].splitWhen((a, b) => b - a > 1); // ([1, 2], [5, 6])
  /// ```
  Iterable<List<T>> splitWhen(
    bool Function(T previous, T current) shouldSplit,
  ) sync* {
    var current = <T>[];
    late T previous;
    var hasPrevious = false;

    for (final element in this) {
      if (hasPrevious && shouldSplit(previous, element)) {
        yield current;
        current = <T>[];
      }
      current.add(element);
      previous = element;
      hasPrevious = true;
    }
    if (current.isNotEmpty) yield current;
  }
}

/// Index-safe access and immutable reordering helpers on [List].
extension ListX<T> on List<T> {
  /// Whether [index] addresses an existing element.
  bool isValidIndex(int index) => index >= 0 && index < length;

  /// The element at [index], or `null` when out of range.
  T? getOrNull(int index) => isValidIndex(index) ? this[index] : null;

  /// The element at [index], or the result of [defaultValue] when out of range.
  T getOrElse(int index, T Function(int index) defaultValue) =>
      isValidIndex(index) ? this[index] : defaultValue(index);

  /// Swaps the elements at [first] and [second] in place.
  void swap(int first, int second) {
    _checkIndex(first, 'first');
    _checkIndex(second, 'second');
    final temp = this[first];
    this[first] = this[second];
    this[second] = temp;
  }

  /// A copy with the elements at [first] and [second] swapped.
  List<T> swapped(int first, int second) => toList()..swap(first, second);

  /// A copy with the element at [from] relocated to index [to].
  ///
  /// ```dart
  /// ['a', 'b', 'c'].moved(0, 2); // ['b', 'c', 'a']
  /// ```
  List<T> moved(int from, int to) {
    _checkIndex(from, 'from');
    _checkIndex(to, 'to');
    final result = toList();
    result.insert(to, result.removeAt(from));
    return result;
  }

  /// A copy rotated left by [positions] (negative rotates right).
  ///
  /// ```dart
  /// [1, 2, 3, 4].rotated(1);  // [2, 3, 4, 1]
  /// [1, 2, 3, 4].rotated(-1); // [4, 1, 2, 3]
  /// ```
  List<T> rotated(int positions) {
    if (isEmpty) return <T>[];
    final offset = positions % length;
    if (offset == 0) return toList();
    return [...sublist(offset), ...sublist(0, offset)];
  }

  /// A copy where every element satisfying [test] is passed through [replace].
  List<T> replaceWhere(
    bool Function(T element) test,
    T Function(T element) replace,
  ) => [for (final element in this) test(element) ? replace(element) : element];

  /// A shuffled copy, leaving this list untouched.
  List<T> shuffled([math.Random? random]) =>
      toList()..shuffle(random ?? _sharedRandom);

  /// A copy with duplicates removed, preserving first-seen order.
  List<T> distinct() {
    final seen = <T>{};
    return [
      for (final element in this)
        if (seen.add(element)) element,
    ];
  }

  /// The last [n] elements, or all of them when the list is shorter.
  List<T> takeLast(int n) {
    _checkNonNegative(n, 'n');
    return n >= length ? toList() : sublist(length - n);
  }

  /// All but the last [n] elements.
  List<T> dropLast(int n) {
    _checkNonNegative(n, 'n');
    return n >= length ? <T>[] : sublist(0, length - n);
  }

  void _checkIndex(int index, String name) {
    if (!isValidIndex(index)) {
      throw RangeError.index(index, this, name);
    }
  }
}

/// Safe defaults for nullable [List] references.
extension ListNullableX<T> on List<T>? {
  /// Whether this list is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Whether this list is non-null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns this list, or an empty list if null.
  List<T> get orEmpty => this ?? <T>[];
}

final math.Random _sharedRandom = math.Random();

void _checkNonNegative(int value, String name) {
  if (value < 0) {
    throw ArgumentError.value(value, name, 'must not be negative');
  }
}
