// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';

import 'package:gmana_utils/gmana_utils.dart';

Future<void> main() async {
  final debouncer = Debouncer(milliseconds: 40);
  final throttler = Throttler(milliseconds: 40);
  final events = <String>[];

  debouncer.run(() => events.add('debounced first'));
  debouncer.run(() => events.add('debounced latest'));

  throttler.run(() => events.add('throttled immediate'));
  throttler.run(() => events.add('throttled skipped'));

  await Future<void>.delayed(const Duration(milliseconds: 60));
  throttler.run(() => events.add('throttled after cooldown'));

  print('Timing utilities');
  print('  events: $events');

  final encoded = IdGenerator.encodeToBase64(['package', 'gmana_utils']);
  final decoded = json.decode(utf8.decode(base64.decode(encoded)));

  print('\nIDs');
  print('  nanoid: ${IdGenerator.nanoid(size: 10)}');
  print('  timestamp: ${IdGenerator.timestampId()}');
  print('  uuid-shaped: ${IdGenerator.uuidV4Like()}');
  print('  encoded payload: $decoded');

  debouncer.dispose();
  throttler.dispose();
}