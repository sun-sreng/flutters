// ignore_for_file: avoid_print
import 'dart:async';

import 'package:gmana_utils/gmana_utils.dart';

Future<void> main() async {
  await _timingUtilities();
  await _streamTiming();
  _identifiers();
  await _concurrencyLimits();
  await _resilience();
  await _cachingAndBatching();
  _fallibleWorkflows();
  _lazyValues();
}

Future<void> _timingUtilities() async {
  print('== Debouncer & Throttler ==');

  final debouncer = Debouncer(milliseconds: 40);
  final throttler = Throttler(milliseconds: 40, trailing: true);
  final events = <String>[];

  debouncer.run(() => events.add('debounced first'));
  debouncer.run(() => events.add('debounced latest'));

  throttler.run(() => events.add('throttled immediate'));
  throttler.run(() => events.add('throttled trailing'));

  await Future<void>.delayed(const Duration(milliseconds: 80));
  print('  events: $events');

  // runAsync returns the debounced action's result. Superseded calls complete
  // with a DebouncedException instead of hanging.
  final superseded = debouncer.runAsync(() async => 'stale');
  final winner = debouncer.runAsync(() async => 'fresh');

  print('  runAsync winner: ${await winner}');
  try {
    await superseded;
  } on DebouncedException catch (e) {
    print('  superseded call: $e');
  }

  debouncer.dispose();
  throttler.dispose();
}

Future<void> _streamTiming() async {
  print('\n== Stream timing ==');

  // Broadcast so both operators can observe the same source.
  final controller = StreamController<int>.broadcast();
  final debounced = <int>[];
  final throttled = <int>[];

  final subscriptions = [
    controller.stream.debounce(const Duration(milliseconds: 30)).listen(debounced.add),
    controller.stream.throttle(const Duration(milliseconds: 30)).listen(throttled.add),
  ];

  for (final value in [1, 2, 3]) {
    controller.add(value);
  }
  await Future<void>.delayed(const Duration(milliseconds: 60));

  print('  debounce keeps the last of a burst: $debounced');
  print('  throttle keeps the first: $throttled');

  await controller.close();
  for (final subscription in subscriptions) {
    await subscription.cancel();
  }
}

void _identifiers() {
  print('\n== Identifiers ==');

  print('  nanoid: ${IdGenerator.nanoid(size: 10)}');
  print('  shortId: ${IdGenerator.shortId()}');
  print('  prefixed: ${IdGenerator.prefixed('cus', length: 12)}');
  print('  timestampId: ${IdGenerator.timestampId()}');
  print('  uuid-shaped: ${IdGenerator.uuidV4Like()}');

  // Plain ULIDs share a millisecond and so do not sort against each other.
  // Eight of them land in order only by luck; the monotonic variant always does.
  final plain = List.generate(8, (_) => IdGenerator.ulid());
  final monotonic = List.generate(8, (_) => IdGenerator.ulidMonotonic());

  print('  ulid sorted?          ${_isSorted(plain)}');
  print('  ulidMonotonic sorted? ${_isSorted(monotonic)}');

  final token = SecureIdGenerator.prefixed('sk', length: 24);
  print('  secure api key: $token');
  print('  safeEqual(self): ${SecureIdGenerator.safeEqual(token, token)}');

  final encoded = IdGenerator.encodeToBase64(['package', 'gmana_utils']);
  print('  round-tripped payload: ${IdGenerator.decodeFromBase64(encoded)}');
}

bool _isSorted(List<String> ids) {
  final sorted = [...ids]..sort();
  return '$ids' == '$sorted';
}

Future<void> _concurrencyLimits() async {
  print('\n== Concurrency ==');

  var running = 0;
  var peak = 0;

  final doubled = await mapConcurrent<int, int>(
    List.generate(8, (i) => i + 1),
    (value) async {
      running++;
      peak = running > peak ? running : peak;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      running--;
      return value * 2;
    },
    concurrency: 3,
  );

  print('  mapConcurrent result (input order): $doubled');
  print('  peak concurrent workers: $peak');

  // KeyedLock serializes per key while distinct keys still overlap.
  final lock = KeyedLock<String>();
  final order = <String>[];
  await Future.wait([
    lock.synchronized('account', () async {
      order.add('first-start');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      order.add('first-end');
    }),
    lock.synchronized('account', () async => order.add('second')),
  ]);
  print('  KeyedLock order: $order');
}

Future<void> _resilience() async {
  print('\n== Resilience ==');

  var attempts = 0;
  final value = await retry<String>(
    () {
      attempts++;
      if (attempts < 3) throw StateError('not ready');
      return 'ready after $attempts attempts';
    },
    maxAttempts: 4,
    delay: const Duration(milliseconds: 10),
    maxDelay: const Duration(milliseconds: 50),
    jitter: true,
    onRetry: (attempt, error, nextDelay) =>
        print('  attempt $attempt failed ($error); waiting $nextDelay'),
  );
  print('  retry: $value');

  final breaker = CircuitBreaker(
    failureThreshold: 2,
    resetTimeout: const Duration(milliseconds: 50),
    onStateChange: (state) => print('  circuit -> $state'),
  );

  for (var i = 0; i < 2; i++) {
    try {
      await breaker.run<void>(() async => throw StateError('dependency down'));
    } on StateError {
      // Expected: these two failures trip the breaker.
    }
  }

  try {
    await breaker.run<void>(() async {});
  } on CircuitBreakerOpenException catch (e) {
    print('  rejected while open: ${e.message}');
  }

  final limiter = RateLimiter(
    maxRequests: 2,
    duration: const Duration(seconds: 1),
  );
  final accepted = List.generate(4, (_) => limiter.tryRun(() {})).where((ok) => ok).length;
  print('  rate limiter accepted $accepted of 4');
}

Future<void> _cachingAndBatching() async {
  print('\n== Caching & batching ==');

  var loads = 0;
  final cache = AsyncCache<String, String>(
    defaultTtl: const Duration(minutes: 5),
    maxEntries: 2,
  );

  Future<String> load(String key) async {
    loads++;
    return 'value-for-$key';
  }

  await cache.get('a', ifAbsent: () => load('a'));
  await cache.get('a', ifAbsent: () => load('a')); // served from cache
  await cache.get('b', ifAbsent: () => load('b'));
  cache.getIfPresent('a'); // marks 'a' as recently used
  await cache.get('c', ifAbsent: () => load('c')); // evicts 'b'

  print('  loads: $loads (second read of "a" was cached)');
  print('  keys after LRU eviction: ${cache.keys}');

  final memoizer = AsyncMemoizer<int>();
  var memoRuns = 0;
  Future<int> expensive() async {
    memoRuns++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return 42;
  }

  // Concurrent callers share one run.
  await Future.wait([memoizer.runOnce(expensive), memoizer.runOnce(expensive)]);
  print('  memoizer ran $memoRuns time(s) for 2 concurrent callers');

  final batcher = Batcher<int, String>(
    maxBatchSize: 3,
    maxDelay: const Duration(milliseconds: 20),
    handler: (items) async {
      print('  handler received a batch of ${items.length}');
      return items.map((i) => 'item-$i').toList();
    },
  );

  final batched = await Future.wait([batcher.add(1), batcher.add(2), batcher.add(3)]);
  print('  batched results: $batched');
  batcher.dispose();
}

void _fallibleWorkflows() {
  print('\n== Result ==');

  final parsed = Result.captureWith<int, String>(
    () => int.parse('8080'),
    (error, stackTrace) => 'Not a number: $error',
  );

  final port = parsed
      .filter((value) => value > 0 && value < 65536, orElse: (v) => '$v is out of range')
      .inspectSuccess((value) => print('  using port $value'))
      .getOrElse(80);
  print('  port: $port');

  final bad = Result.captureWith<int, String>(
    () => int.parse('not-a-port'),
    (error, stackTrace) => 'Not a number',
  );
  print('  fold on failure: ${bad.fold(onSuccess: (v) => 'ok $v', onFailure: (e) => 'err $e')}');
  print('  recovered: ${bad.recover((_) => 8080).getOrThrow()}');

  final results = <Result<int, String>>[
    const Result<int, String>.success(10),
    const Result<int, String>.failure('bad row'),
    const Result<int, String>.success(30),
  ];
  final partition = results.partitionResults();
  print('  successes: ${partition.successes}, failures: ${partition.failures}');

  print('  tryOrNull: ${tryOrNull(() => int.parse('nope'))}');
  print(
    '  tryOrElse: ${tryOrElse(() => int.parse('nope'), (error, stackTrace) => -1)}',
  );
}

void _lazyValues() {
  print('\n== Lazy ==');

  var built = 0;
  final config = ResettableLazy<String>(() {
    built++;
    return 'config#$built';
  });

  print('  initialized before access: ${config.isInitialized}');
  print('  value: ${config.value}, again: ${config.value}');
  config.reset();
  print('  after reset: ${config.value} (factory ran $built times)');
}
