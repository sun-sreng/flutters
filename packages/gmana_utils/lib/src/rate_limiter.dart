/// A sliding-window rate limiter utility.
class RateLimiter {
  /// Maximum number of allowed executions within [duration].
  final int maxRequests;

  /// Time window duration for rate limiting.
  final Duration duration;

  final List<DateTime> _timestamps = [];

  /// Creates a [RateLimiter] allowing up to [maxRequests] executions per [duration].
  RateLimiter({
    required this.maxRequests,
    required this.duration,
  }) {
    if (maxRequests <= 0) {
      throw ArgumentError.value(maxRequests, 'maxRequests', 'must be positive');
    }
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'must be positive');
    }
  }

  /// Number of remaining executions allowed in the current window.
  int get remainingRequests {
    _purgeOldTimestamps();
    return maxRequests - _timestamps.length;
  }

  /// Whether execution is allowed under the current rate limit.
  bool get canRun => remainingRequests > 0;

  /// Attempts to run [action]. Returns `true` if executed, `false` if rate-limited.
  bool tryRun(void Function() action) {
    _purgeOldTimestamps();
    if (_timestamps.length >= maxRequests) return false;

    _timestamps.add(DateTime.now());
    action();
    return true;
  }

  /// Resets the rate limiter history.
  void reset() {
    _timestamps.clear();
  }

  void _purgeOldTimestamps() {
    final cutoff = DateTime.now().subtract(duration);
    _timestamps.removeWhere((timestamp) => timestamp.isBefore(cutoff));
  }
}
