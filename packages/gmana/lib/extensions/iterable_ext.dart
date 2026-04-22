import 'dart:math' as math;

/// Comprehensive extensions on [Iterable] for numeric types.
extension IterableNumX<T extends num> on Iterable<T> {
  // ─── Aggregates ───────────────────────────────────────────────────────────

  /// Whether all elements are negative (< 0).
  bool get allNegative => every((e) => e < 0);

  /// Whether all elements are non-negative (≥ 0).
  bool get allNonNegative => every((e) => e >= 0);

  /// Whether all elements are positive (> 0).
  bool get allPositive => every((e) => e > 0);

  /// Arithmetic mean. Returns `null` if empty.
  double? get average => isEmpty ? null : sum() / length;

  // ─── Min / Max ────────────────────────────────────────────────────────────

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

  // ─── Statistics ───────────────────────────────────────────────────────────

  /// Smallest element. Throws [StateError] if empty.
  T get minOrThrow => minOrNull ?? (throw StateError('Empty iterable.'));

  /// Range (max − min), or `null` if empty.
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

  /// Population variance, or `null` if empty.
  double? get variance {
    final avg = average;
    if (avg == null) return null;
    return map((e) => (e - avg) * (e - avg)).sum() / length;
  }

  // ─── Predicates ──────────────────────────────────────────────────────────

  /// Returns the [n] smallest elements in ascending order.
  List<T> bottom(int n) => (toList()..sort()).take(n).toList();

  /// Clamps every element to [[lo], [hi]].
  Iterable<T> clampAll(T lo, T hi) => map((e) => e.clamp(lo, hi) as T);

  /// Normalizes elements to [0, 1] based on min/max scaling.
  /// Returns an empty list if empty or if min == max.
  List<double> normalize() {
    final mn = minOrNull;
    final mx = maxOrNull;
    if (mn == null || mx == null || mx == mn) return [];
    return map((e) => (e - mn) / (mx - mn)).toList();
  }

  // ─── Transforms ──────────────────────────────────────────────────────────

  /// Product of all elements. Returns [identity] (default 1) if empty.
  T product({T? identity}) {
    if (isEmpty) return (identity ?? 1) as T;
    return reduce((a, b) => (a * b) as T);
  }

  /// Cumulative product as a lazy iterable.
  Iterable<T> runningProduct() sync* {
    T acc = (1 as T);
    for (final e in this) {
      acc = (acc * e) as T;
      yield acc;
    }
  }

  /// Running (prefix) sum as a lazy iterable.
  Iterable<T> runningSum() sync* {
    T acc = (0 as T);
    for (final e in this) {
      acc = (acc + e) as T;
      yield acc;
    }
  }

  /// Sum of all elements. Returns [identity] (default 0) if empty.
  T sum({T? identity}) {
    if (isEmpty) return (identity ?? 0) as T;
    return reduce((a, b) => (a + b) as T);
  }

  /// Returns the [n] largest elements in descending order.
  List<T> top(int n) => (toList()..sort()).reversed.take(n).toList();
}
