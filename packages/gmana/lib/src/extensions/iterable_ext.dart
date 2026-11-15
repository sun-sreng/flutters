import 'dart:math' as math;

T _zeroFor<T extends num>() {
  if (T == double) return 0.0 as T;
  return 0 as T;
}

T _oneFor<T extends num>() {
  if (T == double) return 1.0 as T;
  return 1 as T;
}

/// Comprehensive extensions on [Iterable] for numeric types.
extension IterableNumX<T extends num> on Iterable<T> {
  /// Whether all elements are negative (< 0).
  bool get allNegative => every((e) => e < 0);

  /// Whether all elements are non-negative (>= 0).
  bool get allNonNegative => every((e) => e >= 0);

  /// Whether all elements are positive (> 0).
  bool get allPositive => every((e) => e > 0);

  /// Whether all elements are zero.
  bool get allZero => every((e) => e == 0);

  /// Whether any element is negative (< 0).
  bool get anyNegative => any((e) => e < 0);

  /// Whether any element is positive (> 0).
  bool get anyPositive => any((e) => e > 0);

  /// Whether any element is zero.
  bool get anyZero => any((e) => e == 0);

  /// Arithmetic mean. Returns `null` if empty.
  double? get average => isEmpty ? null : sum() / length;

  /// Arithmetic mean. Throws [StateError] if empty.
  double get averageOrThrow {
    if (isEmpty) throw StateError('Cannot compute average of empty iterable.');
    return sum() / length;
  }

  /// Largest element, or `null` if empty.
  T? get maxOrNull => isEmpty ? null : reduce((a, b) => a > b ? a : b);

  /// Largest element. Throws [StateError] if empty.
  T get maxOrThrow => maxOrNull ?? (throw StateError('Empty iterable.'));

  /// Median value, or `null` if empty.
  /// Averages the two middle values for even-length iterables.
  double? get median {
    if (isEmpty) return null;
    final sorted = toList()..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid].toDouble()
        : (sorted[mid - 1] + sorted[mid]) / 2;
  }

  /// Smallest element, or `null` if empty.
  T? get minOrNull => isEmpty ? null : reduce((a, b) => a < b ? a : b);

  /// Smallest element. Throws [StateError] if empty.
  T get minOrThrow => minOrNull ?? (throw StateError('Empty iterable.'));

  /// Most frequent value or values, preserving first-seen order.
  ///
  /// Returns an empty list for an empty iterable.
  List<T> get modes {
    if (isEmpty) return [];

    final counts = frequencyMap();
    final maxCount = counts.values.reduce(math.max);
    return counts.entries
        .where((entry) => entry.value == maxCount)
        .map((entry) => entry.key)
        .toList();
  }

  /// Range (max - min), or `null` if empty.
  num? get range {
    final mn = minOrNull;
    final mx = maxOrNull;
    return (mn != null && mx != null) ? mx - mn : null;
  }

  /// Population standard deviation, or `null` if empty.
  double? get stdDev {
    final v = variance;
    return v != null ? math.sqrt(v) : null;
  }

  /// Sample standard deviation, or `null` when fewer than two values exist.
  double? get sampleStdDev {
    final v = sampleVariance;
    return v != null ? math.sqrt(v) : null;
  }

  /// Sample variance, or `null` when fewer than two values exist.
  double? get sampleVariance {
    if (length < 2) return null;
    final avg = averageOrThrow;
    return map((e) => (e - avg) * (e - avg)).sum() / (length - 1);
  }

  /// Population variance, or `null` if empty.
  double? get variance {
    final avg = average;
    if (avg == null) return null;
    return map((e) => (e - avg) * (e - avg)).sum() / length;
  }

  /// Returns the [n] smallest elements in ascending order.
  List<T> bottom(int n) {
    _checkNonNegativeCount(n);
    return (toList()..sort()).take(n).toList();
  }

  /// Clamps every element to [[lo], [hi]].
  Iterable<T> clampAll(T lo, T hi) => map((e) => e.clamp(lo, hi) as T);

  /// Difference between each adjacent pair as a lazy iterable.
  Iterable<num> deltas() sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;

    var previous = iterator.current;
    while (iterator.moveNext()) {
      final current = iterator.current;
      yield current - previous;
      previous = current;
    }
  }

  /// Counts occurrences of each value, preserving first-seen key order.
  Map<T, int> frequencyMap() {
    final map = <T, int>{};
    for (final e in this) {
      map[e] = (map[e] ?? 0) + 1;
    }
    return map;
  }

  /// Normalizes elements to [0, 1] based on min/max scaling.
  /// Returns an empty list if empty or if min == max.
  List<double> normalize() {
    final mn = minOrNull;
    final mx = maxOrNull;
    if (mn == null || mx == null || mx == mn) return [];
    return map((e) => (e - mn) / (mx - mn)).toList();
  }

  /// Normalizes elements into the range [[toMin], [toMax]].
  ///
  /// Returns an empty list if empty or if all values are equal.
  List<double> normalizeTo(num toMin, num toMax) {
    final normalized = normalize();
    if (normalized.isEmpty) return [];
    final span = toMax - toMin;
    return normalized.map((e) => toMin + e * span).toList();
  }

  /// Percentile using linear interpolation.
  ///
  /// [p] must be between 0 and 100. Returns `null` for an empty iterable.
  double? percentile(num p) {
    if (p < 0 || p > 100) {
      throw ArgumentError.value(p, 'p', 'must be between 0 and 100');
    }
    if (isEmpty) return null;

    final sorted = toList()..sort();
    if (sorted.length == 1) return sorted.first.toDouble();

    final rank = (p / 100) * (sorted.length - 1);
    final lower = rank.floor();
    final upper = rank.ceil();
    if (lower == upper) return sorted[lower].toDouble();

    final weight = rank - lower;
    return sorted[lower] + (sorted[upper] - sorted[lower]) * weight;
  }

  /// Product of all elements. Returns [identity] (default 1) if empty.
  T product({T? identity}) {
    if (isEmpty) return identity ?? _oneFor<T>();
    return reduce((a, b) => (a * b) as T);
  }

  /// Cumulative product as a lazy iterable.
  Iterable<T> runningProduct() sync* {
    var acc = _oneFor<T>();
    for (final e in this) {
      acc = (acc * e) as T;
      yield acc;
    }
  }

  /// Running (prefix) sum as a lazy iterable.
  Iterable<T> runningSum() sync* {
    var acc = _zeroFor<T>();
    for (final e in this) {
      acc = (acc + e) as T;
      yield acc;
    }
  }

  /// Running arithmetic mean as a lazy iterable.
  Iterable<double> runningAverage() sync* {
    var count = 0;
    num total = 0;
    for (final e in this) {
      count++;
      total += e;
      yield total / count;
    }
  }

  /// Sum of all elements. Returns [identity] (default 0) if empty.
  T sum({T? identity}) {
    if (isEmpty) return identity ?? _zeroFor<T>();
    return reduce((a, b) => (a + b) as T);
  }

  /// Returns the [n] largest elements in descending order.
  List<T> top(int n) {
    _checkNonNegativeCount(n);
    return (toList()..sort()).reversed.take(n).toList();
  }
}

void _checkNonNegativeCount(int count) {
  if (count < 0) {
    throw ArgumentError.value(count, 'n', 'must not be negative');
  }
}
