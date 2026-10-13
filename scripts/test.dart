// Runs the tests of every workspace package that has a `test/` directory,
// one package at a time: `flutter test` for packages that depend on the
// Flutter SDK, `dart test` for the rest.
//
//   dart run scripts/test.dart            # every package
//   dart run scripts/test.dart --dart     # pure Dart packages only
//   dart run scripts/test.dart --flutter  # Flutter packages only
import 'dart:io';

import 'src/workspace.dart';

final _flutterSdk = RegExp(r'^\s+sdk:\s*flutter\s*$', multiLine: true);

Future<void> main(List<String> args) async {
  final onlyDart = args.contains('--dart');
  final onlyFlutter = args.contains('--flutter');
  final failed = <String>[];

  for (final MapEntry(key: name, value: dir) in workspaceMembers().entries) {
    if (!Directory('$dir/test').existsSync()) continue;

    final flutter = _flutterSdk.hasMatch(
      File('$dir/pubspec.yaml').readAsStringSync(),
    );
    if ((onlyDart && flutter) || (onlyFlutter && !flutter)) continue;

    final tool = flutter ? 'flutter' : 'dart';
    stdout.writeln('\n== $name: $tool test');
    final process = await Process.start(
      tool,
      ['test'],
      workingDirectory: dir,
      mode: ProcessStartMode.inheritStdio,
      runInShell: true,
    );
    if (await process.exitCode != 0) failed.add(name);
  }

  if (failed.isNotEmpty) {
    stderr.writeln('\nTests failed in: ${failed.join(', ')}');
    exit(1);
  }
}
