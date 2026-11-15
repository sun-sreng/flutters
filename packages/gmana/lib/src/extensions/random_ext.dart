import 'dart:math';

/// Extension methods for [Random].
extension RandomX on Random {
  /// Generates a random integer in inclusive range `[min, max]`.
  int nextIntInRange(int min, int max) {
    if (min > max) {
      throw ArgumentError('min ($min) must be <= max ($max)');
    }
    return min + nextInt(max - min + 1);
  }

  /// Generates a random double in range `[min, max)`.
  double nextDoubleInRange(double min, double max) {
    if (min > max) {
      throw ArgumentError('min ($min) must be <= max ($max)');
    }
    return min + (nextDouble() * (max - min));
  }

  /// Returns `true` with the specified [probability] (between 0.0 and 1.0).
  bool nextBoolWithProbability(double probability) {
    if (probability < 0.0 || probability > 1.0) {
      throw ArgumentError('probability must be between 0.0 and 1.0');
    }
    return nextDouble() < probability;
  }

  /// Returns a random element from [items].
  T nextElement<T>(List<T> items) {
    if (items.isEmpty) {
      throw ArgumentError('items list must not be empty');
    }
    return items[nextInt(items.length)];
  }
}
