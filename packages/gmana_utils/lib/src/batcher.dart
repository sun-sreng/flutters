import 'dart:async';

class _BatchItem<T, R> {
  final T input;
  final Completer<R> completer;

  _BatchItem(this.input, this.completer);
}

/// Batches individual calls into bulk requests based on size or time thresholds.
class Batcher<T, R> {
  /// Maximum number of items in a single batch.
  final int maxBatchSize;

  /// Maximum delay before flushing a non-full batch.
  final Duration maxDelay;

  /// Bulk handler function executed when a batch flushes.
  final Future<List<R>> Function(List<T> items) handler;

  final List<_BatchItem<T, R>> _queue = [];
  Timer? _timer;
  bool _isProcessing = false;

  /// Creates a [Batcher].
  Batcher({
    required this.maxBatchSize,
    required this.maxDelay,
    required this.handler,
  })  : assert(maxBatchSize > 0, 'maxBatchSize must be > 0');

  /// Adds [item] to the batch queue and returns a `Future` that completes when the batch processes.
  Future<R> add(T item) {
    final completer = Completer<R>();
    _queue.add(_BatchItem(item, completer));

    if (_queue.length >= maxBatchSize) {
      unawaited(_flush());
    } else {
      _timer ??= Timer(maxDelay, () => unawaited(_flush()));
    }


    return completer.future;
  }

  /// Manually triggers an immediate flush of queued items.
  Future<void> flush() async {
    await _flush();
  }

  Future<void> _flush() async {
    _timer?.cancel();
    _timer = null;

    if (_queue.isEmpty || _isProcessing) return;

    final batch = List<_BatchItem<T, R>>.from(_queue);
    _queue.clear();

    _isProcessing = true;
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
    } finally {
      _isProcessing = false;
      if (_queue.isNotEmpty) {
        unawaited(_flush());
      }
    }
  }

  /// Cancels pending timer and rejects queued futures.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    for (final item in _queue) {
      item.completer.completeError(StateError('Batcher disposed'));
    }
    _queue.clear();
  }
}
