// ignore_for_file: avoid_print
import 'package:gmana/gmana.dart';

Future<void> main() async {
  final duration = 90.seconds;
  final title = 'gmana facade'.toTitleCase;
  final scores = [8, 10, 7, 9];
  final email = const EmailValidator().validate(' User@Example.COM ');
  final id = IdGenerator.nanoid(size: 12);

  print('gmana facade');
  print('  title: $title');
  print('  duration: ${duration.toHHMMSS()}');
  print('  average score: ${scores.average}');
  print('  valid email: ${email.rightOrNull()}');
  print('  generated id: $id');
  print('  predicate email: ${isEmail('hello@example.com')}');

  final numbers = Stream.fromIterable([1, 2, 3]);
  final totals = await numbers.scan(0, (sum, value) => sum + value).toList();

  print('  running totals: $totals');
}