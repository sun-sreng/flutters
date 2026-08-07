import 'dart:async';

/// Caches the result of an async computation so that subsequent calls return the memoized result.
class AsyncMemoizer<T> {
  final _completer = Completer<T>();

  /// Returns `true` if the memoized calculation has started.
  bool get hasRun => _completer.isCompleted;

  /// Returns the future for the memoized calculation.
  ///
  /// Runs [computation] only the first time this method is called.
  Future<T> runOnce(Future<T> Function() computation) {
    if (!hasRun) {
      unawaited(
        computation()
            .then(_completer.complete)
            .catchError(_completer.completeError),
      );
    }
    return _completer.future;
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime createdAt;

  _CacheEntry(this.value, this.createdAt);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(createdAt) > ttl;
  }
}

/// An asynchronous key-value cache supporting TTL expiration and request deduplication.
class AsyncCache<K, V> {
  /// Default Time-To-Live duration for cached entries.
  final Duration? defaultTtl;

  final Map<K, _CacheEntry<V>> _cache = {};
  final Map<K, Future<V>> _inFlight = {};

  /// Creates an [AsyncCache].
  AsyncCache({this.defaultTtl});

  /// Fetches [key] from cache if valid, or invokes [ifAbsent] to load and cache the value.
  ///
  /// Concurrent calls for the same missing [key] will share a single in-flight `Future`.
  Future<V> get(
    K key, {
    required Future<V> Function() ifAbsent,
    Duration? ttl,
  }) async {
    final effectiveTtl = ttl ?? defaultTtl;

    // Check existing entry
    final entry = _cache[key];
    if (entry != null) {
      if (effectiveTtl == null || !entry.isExpired(effectiveTtl)) {
        return entry.value;
      } else {
        _cache.remove(key);
      }
    }

    // Check in-flight request deduplication
    if (_inFlight.containsKey(key)) {
      return _inFlight[key]!;
    }

    final completer = Completer<V>();
    _inFlight[key] = completer.future;

    unawaited(
      _fetchAndCache(key, ifAbsent)
          .then(completer.complete)
          .catchError(completer.completeError),
    );

    return completer.future;
  }

  Future<V> _fetchAndCache(K key, Future<V> Function() ifAbsent) async {
    try {
      final val = await ifAbsent();
      _cache[key] = _CacheEntry(val, DateTime.now());
      return val;
    } finally {
      // ignore: unawaited_futures
      _inFlight.remove(key);
    }
  }

  /// Manually invalidates [key] in the cache.
  void invalidate(K key) {
    _cache.remove(key);
  }

  /// Clears all cached entries and pending operations.
  void clear() {
    _cache.clear();
    _inFlight.clear();
  }

  /// Returns `true` if [key] exists in cache and has not expired.
  bool containsKey(K key, [Duration? ttl]) {
    final entry = _cache[key];
    if (entry == null) return false;
    final effectiveTtl = ttl ?? defaultTtl;
    if (effectiveTtl != null && entry.isExpired(effectiveTtl)) {
      return false;
    }
    return true;
  }
}

