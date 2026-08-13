import 'dart:async';

import 'package:clock/clock.dart';

/// Caches the result of an async computation so that subsequent calls return the memoized result.
class AsyncMemoizer<T> {
  final _completer = Completer<T>();
  bool _started = false;

  /// Returns `true` if the memoized calculation has started.
  ///
  /// This becomes `true` as soon as [runOnce] first invokes the computation,
  /// not when that computation finishes. Concurrent callers therefore share
  /// the single in-flight run rather than starting their own.
  bool get hasRun => _started;

  /// Returns the future for the memoized calculation.
  ///
  /// Runs [computation] only the first time this method is called. Every
  /// caller — including callers that arrive while the first run is still in
  /// flight — receives the same value or the same error.
  Future<T> runOnce(Future<T> Function() computation) {
    if (!_started) {
      _started = true;
      try {
        unawaited(
          computation().then(_completer.complete, onError: _completer.completeError),
        );
      } catch (error, stackTrace) {
        // The computation threw synchronously, before returning a future.
        _completer.completeError(error, stackTrace);
      }
    }
    return _completer.future;
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime createdAt;

  _CacheEntry(this.value, this.createdAt);

  bool isExpired(Duration ttl) {
    return clock.now().difference(createdAt) >= ttl;
  }
}

/// An asynchronous key-value cache supporting TTL expiration and request deduplication.
class AsyncCache<K, V> {
  /// Default Time-To-Live duration for cached entries.
  final Duration? defaultTtl;

  /// Maximum number of entries retained, or `null` for no limit.
  ///
  /// When the cache exceeds this size the least recently used entry is
  /// evicted. Reads through [get] and [getIfPresent] count as uses.
  final int? maxEntries;

  final Map<K, _CacheEntry<V>> _cache = {};
  final Map<K, Future<V>> _inFlight = {};

  /// Creates an [AsyncCache].
  ///
  /// Throws an [ArgumentError] if [maxEntries] is not positive.
  AsyncCache({this.defaultTtl, this.maxEntries}) {
    final limit = maxEntries;
    if (limit != null && limit <= 0) {
      throw ArgumentError.value(limit, 'maxEntries', 'must be positive');
    }
  }

  /// Number of entries currently held, including any that have expired but
  /// have not yet been evicted.
  int get length => _cache.length;

  /// Cached keys, from least to most recently used.
  List<K> get keys => _cache.keys.toList();

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
        _touch(key, entry);
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
      _store(key, val);
      return val;
    } finally {
      // ignore: unawaited_futures
      _inFlight.remove(key);
    }
  }

  /// Returns the cached value for [key], or `null` if absent or expired.
  ///
  /// Never invokes a loader — use [get] when a miss should fetch. A hit counts
  /// as a use for [maxEntries] eviction.
  V? getIfPresent(K key, [Duration? ttl]) {
    final entry = _cache[key];
    if (entry == null) return null;

    final effectiveTtl = ttl ?? defaultTtl;
    if (effectiveTtl != null && entry.isExpired(effectiveTtl)) {
      _cache.remove(key);
      return null;
    }

    _touch(key, entry);
    return entry.value;
  }

  /// Stores [value] under [key], replacing any existing entry.
  ///
  /// The entry's TTL starts now.
  void set(K key, V value) {
    _store(key, value);
  }

  /// Manually invalidates [key] in the cache.
  void invalidate(K key) {
    _cache.remove(key);
  }

  /// Removes every entry whose key satisfies [test], returning how many went.
  ///
  /// Example:
  /// ```dart
  /// // Drop everything cached for one tenant after a permissions change.
  /// cache.invalidateWhere((key) => key.startsWith('tenant:$tenantId:'));
  /// ```
  int invalidateWhere(bool Function(K key) test) {
    final doomed = _cache.keys.where(test).toList();
    for (final key in doomed) {
      _cache.remove(key);
    }
    return doomed.length;
  }

  /// Drops every expired entry, returning how many were removed.
  ///
  /// Expired entries are otherwise only removed when their key is next read,
  /// so a cache whose keys are never read again holds them indefinitely. Call
  /// this periodically for a long-lived cache, or set [maxEntries].
  int evictExpired([Duration? ttl]) {
    final effectiveTtl = ttl ?? defaultTtl;
    if (effectiveTtl == null) return 0;

    final doomed = <K>[];
    for (final entry in _cache.entries) {
      if (entry.value.isExpired(effectiveTtl)) doomed.add(entry.key);
    }
    for (final key in doomed) {
      _cache.remove(key);
    }
    return doomed.length;
  }

  /// Marks [key] as most recently used by reinserting it at the end.
  void _touch(K key, _CacheEntry<V> entry) {
    if (maxEntries == null) return;
    _cache
      ..remove(key)
      ..[key] = entry;
  }

  /// Inserts an entry, evicting the least recently used one if over capacity.
  void _store(K key, V value) {
    _cache
      ..remove(key)
      ..[key] = _CacheEntry(value, clock.now());

    final limit = maxEntries;
    if (limit == null) return;
    while (_cache.length > limit) {
      _cache.remove(_cache.keys.first);
    }
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

