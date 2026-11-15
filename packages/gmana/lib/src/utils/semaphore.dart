import 'dart:async';
import 'dart:collection';

/// A counting semaphore that bounds how many operations run at once.
///
/// Permits are handed to waiters in FIFO order, so a long queue cannot starve
/// its earliest members.
///
/// Prefer [withPermit] over a manual [acquire]/[release] pair — it releases the
/// permit even when the action throws.
///
/// Example:
/// ```dart
/// final uploads = Semaphore(3);
///
/// await Future.wait([
///   for (final file in files) uploads.withPermit(() => upload(file)),
/// ]);
/// // At most three uploads are in flight at any moment.
/// ```
class Semaphore {
  /// The maximum number of permits held by this semaphore.
  final int permits;

  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();
  int _available;

  /// Creates a semaphore that allows [permits] concurrent holders.
  ///
  /// Throws an [ArgumentError] if [permits] is not positive.
  Semaphore(this.permits) : _available = permits {
    if (permits <= 0) {
      throw ArgumentError.value(permits, 'permits', 'must be positive');
    }
  }

  /// Number of permits currently free.
  int get available => _available;

  /// Number of callers waiting for a permit.
  int get queueLength => _waiters.length;

  /// Acquires a permit, waiting if none is free.
  ///
  /// Every successful acquire must be paired with exactly one [release].
  Future<void> acquire() {
    if (_available > 0) {
      _available--;
      return Future<void>.value();
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  /// Returns a permit to the semaphore.
  ///
  /// Throws a [StateError] if this would push the free permits above [permits],
  /// which means a release was not paired with an acquire.
  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
      return;
    }
    if (_available >= permits) {
      throw StateError(
        'Semaphore released more times than it was acquired '
        '(permits: $permits)',
      );
    }
    _available++;
  }

  /// Runs [action] while holding a permit, releasing it afterwards.
  ///
  /// The permit is released whether [action] returns normally or throws,
  /// including a synchronous throw.
  Future<T> withPermit<T>(FutureOr<T> Function() action) async {
    await acquire();
    try {
      return await action();
    } finally {
      release();
    }
  }
}

/// Serializes asynchronous operations per key.
///
/// Operations sharing a key run one at a time in arrival order; operations on
/// different keys run concurrently. Keys are dropped once no operation holds
/// them, so a long-lived lock over high-cardinality keys does not leak.
///
/// Example:
/// ```dart
/// final lock = KeyedLock<String>();
///
/// // Two concurrent writes to the same account are serialized; writes to
/// // different accounts still overlap.
/// await lock.synchronized(accountId, () => applyTransaction(accountId, delta));
/// ```
class KeyedLock<K> {
  final Map<K, Semaphore> _locks = {};
  final Map<K, int> _holders = {};

  /// Number of keys currently held or queued.
  int get activeKeys => _locks.length;

  /// Whether [key] is currently held by an operation.
  bool isLocked(K key) {
    final semaphore = _locks[key];
    return semaphore != null && semaphore.available == 0;
  }

  /// Runs [action] with exclusive access to [key].
  ///
  /// The key is released whether [action] returns normally or throws.
  Future<T> synchronized<T>(K key, FutureOr<T> Function() action) async {
    final semaphore = _locks.putIfAbsent(key, () => Semaphore(1));
    _holders.update(key, (count) => count + 1, ifAbsent: () => 1);

    await semaphore.acquire();
    try {
      return await action();
    } finally {
      semaphore.release();
      final remaining = _holders[key]! - 1;
      if (remaining == 0) {
        _holders.remove(key);
        _locks.remove(key);
      } else {
        _holders[key] = remaining;
      }
    }
  }
}
