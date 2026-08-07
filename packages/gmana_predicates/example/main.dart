// ignore_for_file: avoid_print
import 'package:gmana_predicates/gmana_predicates.dart';

void main() {
  print('Strings');
  print('  email: ${isEmail('hello@example.com')}');
  print('  alpha numeric: ${isAlphaNumeric('Gmana2026')}');
  print('  hex color: ${isHexColor('#0F766E')}');
  print('  json: ${isJson('{"ok":true}')}');

  print('\nNetwork and identifiers');
  print('  ipv4: ${isIpv4('192.168.1.10')}');
  print('  uuid v4: ${isUuid('550e8400-e29b-41d4-a716-446655440000', '4')}');
  print('  credit card: ${isCreditCard('4242 4242 4242 4242')}');
  print('  postal code US: ${isPostalCode('90210', 'US')}');

  print('\nDates and numbers');
  print('  leap year: ${isLeapYear('2024-02-29')}');
  print('  weekday: ${isWeekday('2026-05-18T12:00:00Z')}');
  print('  divisible: ${isDivisibleBy('42', '7')}');
  print('  iban: ${isIban('GB82 WEST 1234 5698 7654 32')}');

  print('\nComposing predicates');
  final username = Predicates.all<String>([
    isNotBlank,
    (value) => value.isLength(3, 16),
    isAlphaNumeric.or(isSnakeCase),
  ]);
  for (final candidate in ['sun_sreng', 'ab', 'has spaces']) {
    print('  $candidate: ${username(candidate)}');
  }

  final contact = isEmail.or(isUrl);
  print('  either email or url: ${contact('https://gmana.dev')}');
}
