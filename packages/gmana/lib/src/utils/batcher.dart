import 'dart:async';
import 'dart:math' as math;

class _BatchItem<T, R> {
  final T input;
  final Completer<R> completer;

  _BatchItem(this.input, this.completer);
}

/// Batches individual calls into bulk requests based on size or time thresholds.
///
/// A batch is sent when [maxBatchSize] items are queued or [maxDelay] has
/// passed since the first one. Batches are sent one at a time and never hold
/// more than [maxBatchSize] items; items added while a batch is being sent
/// go out in the following batches.
class Batcher<T, R> {
  /// Maximum number of items in a single batch.
  final int maxBatchSize;

  /// Maximum delay before flushing a non-full batch.
  final Duration maxDelay;

  /// Bulk handler function executed when a batch flushes.
  final Future<List<R>> Function(List<T> items) handler;

  final List<_BatchItem<T, R>> _queue = [];
  Timer? _timer;
  Completer<void>? _draining;
  bool _disposed = false;

  /// Whether [dispose] has been called.
  ///
  /// A disposed batcher rejects further [add] calls.
  bool get isDisposed => _disposed;

  /// Number of items waiting to be flushed.
  int get pendingCount => _queue.length;

  /// Creates a [Batcher].
  Batcher({
    required this.maxBatchSize,
    required this.maxDelay,
    required this.handler,
  }) : assert(maxBatchSize > 0, 'maxBatchSize must be > 0');

  /// Adds [item] to the batch queue and returns a `Future` that completes when the batch processes.
  ///
  /// Returns a failed future with a [StateError] if this batcher has already
  /// been disposed, rather than a future that never completes.
  Future<R> add(T item) {
    if (_disposed) {
      return Future<R>.error(
        StateError('Cannot add to a disposed Batcher'),
        StackTrace.current,
      );
    }

    final completer = Completer<R>();
    _queue.add(_BatchItem(item, completer));

    if (_queue.length >= maxBatchSize) {
      unawaited(_flush());
    } else {
      _timer ??= Timer(maxDelay, () => unawaited(_flush()));
    }

    return completer.future;
  }

  /// Sends every queued item now, in batches of at most [maxBatchSize].
  ///
  /// The returned future completes once the queue is empty, including items
  /// added while it runs. If batches are already being sent, this waits for
  /// them and for the rest of the queue.
  Future<void> flush() => _flush();

  Future<void> _flush() {
    _timer?.cancel();
    _timer = null;

    final running = _draining;
    if (running != null) return running.future;
    if (_queue.isEmpty) return Future<void>.value();

    final draining = _draining = Completer<void>();
    unawaited(_drain(draining));
    return draining.future;
  }

  /// Sends the queue one batch at a time until it is empty.
  ///
  /// Only one drain runs at a time. It clears [_draining] in the same
  /// synchronous step that finds the queue empty, so an item added afterwards
  /// always starts a new drain.
  Future<void> _drain(Completer<void> draining) async {
    try {
      while (_queue.isNotEmpty) {
        _timer?.cancel();
        _timer = null;

        final count = math.min(_queue.length, maxBatchSize);
        final batch = _queue.sublist(0, count);
        _queue.removeRange(0, count);
        await _send(batch);
      }
    } finally {
      _draining = null;
      draining.complete();
    }
  }

  /// Runs [handler] on [batch] and settles each item's future.
  ///
  /// Never throws: a handler error, or a result count that does not match,
  /// fails every item in the batch instead.
  Future<void> _send(List<_BatchItem<T, R>> batch) async {
    try {
      final inputs = batch.map((b) => b.input).toList();
      final results = await handler(inputs);

      if (results.length != batch.length) {
        final error = StateError(
          'Batch handler returned ${results.length} results for ${batch.length} items.',
        );
        for (final item in batch) {
          item.completer.completeError(error);
        }
      } else {
        for (var i = 0; i < batch.length; i++) {
          batch[i].completer.complete(results[i]);
        }
      }
    } catch (e, st) {
      for (final item in batch) {
        item.completer.completeError(e, st);
      }
    }
  }

  /// Cancels pending timer and rejects queued futures.
  ///
  /// After this call [add] rejects immediately and [isDisposed] is `true`.
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    for (final item in _queue) {
      item.completer.completeError(StateError('Batcher disposed'));
    }
    _queue.clear();
  }
}
