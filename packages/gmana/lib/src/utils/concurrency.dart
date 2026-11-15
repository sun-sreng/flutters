import 'dart:async';

import 'semaphore.dart';

/// Maps [items] through [convert] with at most [concurrency] running at once.
///
/// The returned list is in the same order as [items] regardless of the order
/// in which the individual conversions complete.
///
/// The first error aborts the run: no further items are started, and the
/// returned future completes with that error once the already-started work has
/// settled.
///
/// Throws an [ArgumentError] if [concurrency] is not positive.
///
/// Example:
/// ```dart
/// // Fetch 200 users, but never hammer the API with more than 8 at a time.
/// final users = await mapConcurrent(
///   userIds,
///   (id) => api.fetchUser(id),
///   concurrency: 8,
/// );
/// ```
Future<List<R>> mapConcurrent<T, R>(
  Iterable<T> items,
  FutureOr<R> Function(T item) convert, {
  int concurrency = 4,
}) async {
  if (concurrency <= 0) {
    throw ArgumentError.value(concurrency, 'concurrency', 'must be positive');
  }

  final source = items.toList(growable: false);
  if (source.isEmpty) return <R>[];

  final results = List<R?>.filled(source.length, null);
  await _runBounded(source.length, concurrency, (index) async {
    results[index] = await convert(source[index]);
  });

  return List<R>.from(results);
}

/// Runs [action] for every item in [items], at most [concurrency] at once.
///
/// Completion order is not defined. The first error aborts the run on the same
/// terms as [mapConcurrent].
///
/// Throws an [ArgumentError] if [concurrency] is not positive.
///
/// Example:
/// ```dart
/// await forEachConcurrent(
///   pendingJobs,
///   (job) => job.run(),
///   concurrency: 4,
/// );
/// ```
Future<void> forEachConcurrent<T>(
  Iterable<T> items,
  FutureOr<void> Function(T item) action, {
  int concurrency = 4,
}) async {
  if (concurrency <= 0) {
    throw ArgumentError.value(concurrency, 'concurrency', 'must be positive');
  }

  final source = items.toList(growable: false);
  if (source.isEmpty) return;

  await _runBounded(
    source.length,
    concurrency,
    (index) async => action(source[index]),
  );
}

/// Runs [task] for every index below [count], at most [concurrency] at once.
///
/// Stops starting new tasks after the first error and rethrows it, with its
/// original stack trace, once the in-flight tasks have settled.
Future<void> _runBounded(
  int count,
  int concurrency,
  Future<void> Function(int index) task,
) async {
  final semaphore = Semaphore(concurrency);
  final pending = <Future<void>>[];
  Object? firstError;
  StackTrace? firstStackTrace;

  for (var i = 0; i < count; i++) {
    if (firstError != null) break;

    final index = i;
    pending.add(
      semaphore
          .withPermit(() async {
            if (firstError != null) return;
            await task(index);
          })
          .catchError((Object error, StackTrace stackTrace) {
            firstError ??= error;
            firstStackTrace ??= stackTrace;
          }),
    );
  }

  await Future.wait(pending);

  if (firstError != null) {
    Error.throwWithStackTrace(firstError!, firstStackTrace!);
  }
}
