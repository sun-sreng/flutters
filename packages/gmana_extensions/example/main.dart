// ignore_for_file: avoid_print
import 'package:gmana_extensions/gmana_extensions.dart';

Future<void> main() async {
  final duration = 5.seconds + 30.minutes;

  print('Duration');
  print('  human: ${duration.toHuman()}');
  // human: 30m 5s
  print('  compact: ${duration.toCompactString()}');
  // compact: 30m 5s
  print('  clock: ${duration.toHHMMSS()}');
  // clock: 30:05

  print('\nString');
  print('  title: ${'hello world'.toTitleCase}');
  // title: Hello World
  print('  slug: ${'Hello World! 2026'.toSlug}');
  // slug: hello-world-2026
  print('  duration: ${'01:15'.toDuration().toVerboseString()}');
  // duration: 1m 15s

  print('  initials: ${'ada lovelace'.initials()}');
  // initials: AL
  print('  similarity: ${'colour'.similarityTo('color').toFixed(2)}');
  // similarity: 0.83

  print('\nNumber');
  print('  range: ${1.to(5).toList()}');
  // range: [1, 2, 3, 4, 5]
  print('  rounded: ${27.roundToMultiple(5)}');
  // rounded: 25
  print('  progress: ${30.seconds.progressOf(2.minutes)}');
  // progress: 0.25
  print('  compact: ${2500000.toCompact()}');
  // compact: 2.5M
  print('  bytes: ${1572864.toBytes()}');
  // bytes: 1.5 MiB
  print('  money: ${1234.5.toCurrency()}');
  // money: $1,234.50
  print('  ordinal: ${23.toOrdinal}, roman: ${2026.toRoman}');
  // ordinal: 23rd, roman: MMXXVI

  final scores = [9, 4, 7, 10, 4, 8];

  print('\nIterable');
  print('  sum: ${scores.sum()}');
  // sum: 42
  print('  average: ${scores.average}');
  // average: 7.0
  print('  top 3: ${scores.top(3)}');
  // top 3: [10, 9, 8]
  print('  chunks: ${scores.chunked(2).toList()}');
  // chunks: [[9, 4], [7, 10], [4, 8]]
  print(
    '  grouped: ${scores.groupBy((score) => score.isEven ? 'even' : 'odd')}',
  );
  // grouped: {odd: [9, 7], even: [4, 10, 4, 8]}

  final nested = [
    ['dart', 'extensions'],
    ['streams', 'validation'],
  ];

  print('  highest: ${scores.maxBy((score) => score)}');
  // highest: 10
  print(
    '  rendered: ${scores.joinToString(prefix: '<', suffix: '>', limit: 3)}',
  );
  // rendered: <9, 4, 7, ...>

  print('\nList');
  print('  flattened: ${nested.flattenToList()}');
  // flattened: [dart, extensions, streams, validation]
  print('  compact: ${['A', null, 'B'].whereNotNull.toList()}');
  // compact: [A, B]
  print('  rotated: ${scores.rotated(2)}');
  // rotated: [7, 10, 4, 8, 9, 4]
  print('  distinct: ${scores.distinct()}');
  // distinct: [9, 4, 7, 10, 8]

  print('\nDate');
  final release = DateTime(2026, 1, 31);
  print('  next month: ${release.addMonths(1).toDateString()}');
  // next month: 2026-02-28
  print('  iso week: ${release.weekOfYear}');
  // iso week: 5
  print('  relative: ${release.toRelativeString(clock: DateTime(2026, 2, 3))}');
  // relative: 3 days ago

  print('\nValidation');
  print('  email: ${'hello@example.com'.isValidEmail}');
  // email: true
  print('  phone: ${'+15551234567'.isValidE164Phone}');
  // phone: true
  print('  hex color: ${'#00AEEF'.isValidHexColor}');
  // hex color: true

  final runningTotals =
      await Stream.fromIterable([
        1,
        2,
        3,
        4,
      ]).scan(0, (sum, n) => sum + n).toList();

  final batches =
      await Stream.fromIterable([1, 2, 3, 4, 5]).bufferCount(2).toList();

  print('\nStream');
  print('  running totals: $runningTotals');
  // running totals: [1, 3, 6, 10]
  print('  batches: $batches');
  // batches: [[1, 2], [3, 4], [5]]

  final fetched = await [
    'a',
    'bb',
    'ccc',
  ].mapConcurrent((word) async => word.length, concurrency: 2);

  print('\nAsync');
  print('  lengths: $fetched');
  // lengths: [1, 2, 3]
  print(
    '  timed out: ${await Future.delayed(50.ms, () => 1).timeoutOrNull(5.ms)}',
  );
  // timed out: null

  print('\nUri');
  final endpoint = Uri.parse(
    'https://api.example.com/v1',
  ).appendPath(['users']).withQueryParameters({'page': 2});
  print('  built: $endpoint');
  // built: https://api.example.com/v1/users?page=2
  print('  domain: ${endpoint.domain}');
  // domain: api.example.com
}
