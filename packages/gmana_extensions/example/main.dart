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

  print('\nNumber');
  print('  range: ${1.to(5).toList()}');
  // range: [1, 2, 3, 4, 5]
  print('  rounded: ${27.roundToMultiple(5)}');
  // rounded: 25
  print('  progress: ${30.seconds.progressOf(2.minutes)}');
  // progress: 0.25

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

  print('\nList');
  print('  flattened: ${nested.flattenToList()}');
  // flattened: [dart, extensions, streams, validation]
  print('  compact: ${['A', null, 'B'].whereNotNull.toList()}');
  // compact: [A, B]

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

  print('\nStream');
  print('  running totals: $runningTotals');
  // running totals: [1, 3, 6, 10]
}
