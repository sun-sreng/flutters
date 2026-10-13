// Versions packages of this pub workspace. Nobody edits a `version:` line by
// hand; this does it for every package named on the command line:
//
//   dart run scripts/release.dart gmana_utils:minor gmana:patch
//   dart run scripts/release.dart gmana:0.3.0 --dry-run
// dart run scripts/release.dart gmana_utils:patch gmana:patch gmana_extensions:patch gmana_flutter:patch gmana_flutter_extensions:patch gmana_flutter_validation:patch gmana_flutter_predicates:patch gmana_validation:patch gmana_predicates:patch
//
// For each package it sets the new version in pubspec.yaml, turns the
// `## Unreleased` heading of its CHANGELOG.md into `## <version> - <date>`, and
// rewrites the `^` constraint of every workspace member that depends on it
// when the old constraint no longer allows the new version. It then checks
// that the workspace still resolves, commits, and tags `<package>-v<version>`.
//
//   dart run scripts/release.dart --status
//
// lists every package with its local version and the latest on pub.dev.
import 'dart:convert';
import 'dart:io';

import 'src/workspace.dart';

Future<void> main(List<String> args) async {
  final members = workspaceMembers();

  if (args.contains('--status')) return _status(members);

  final dryRun = args.contains('--dry-run');
  final bumps = args.where((a) => !a.startsWith('--')).toList();
  if (bumps.isEmpty) {
    _fail(
      'Usage: dart run scripts/release.dart <package>:<major|minor|patch|x.y.z>'
      ' ... [--dry-run]\n       dart run scripts/release.dart --status',
    );
  }

  if (!dryRun && _git(['status', '--porcelain']).trim().isNotEmpty) {
    _fail('The working tree has uncommitted changes. Commit or stash them.');
  }

  // Work out every change before writing any file, so a bad argument or a
  // missing changelog entry leaves the workspace untouched.
  final edits = <String, String>{}; // path -> new contents
  final released = <String, String>{}; // package -> new version
  final today = DateTime.now().toIso8601String().substring(0, 10);

  for (final bump in bumps) {
    final [name, kind] = bump.contains(':')
        ? bump.split(':')
        : _fail('"$bump" is not <package>:<bump>.');
    final dir = members[name] ?? _fail('"$name" is not a workspace package.');

    final pubspecPath = '$dir/pubspec.yaml';
    final pubspec = File(pubspecPath).readAsStringSync();
    final current =
        _versionLine.firstMatch(pubspec)?.group(1) ??
        _fail('$pubspecPath has no version.');
    final next = _next(current, kind);
    if (_compare(next, current) <= 0) {
      _fail('$name: $next is not newer than $current.');
    }

    final changelogPath = '$dir/CHANGELOG.md';
    final changelog = File(changelogPath).existsSync()
        ? File(changelogPath).readAsStringSync()
        : '';
    if (!_unreleased.hasMatch(changelog)) {
      _fail(
        '$name: $changelogPath has no "## Unreleased" section. '
        'Write the release notes there first.',
      );
    }

    edits[pubspecPath] = pubspec.replaceFirst(_versionLine, 'version: $next');
    edits[changelogPath] = changelog.replaceFirst(
      _unreleased,
      '## $next - $today',
    );
    released[name] = next;
    stdout.writeln('$name: $current -> $next');
  }

  for (final MapEntry(key: member, value: dir) in members.entries) {
    final path = '$dir/pubspec.yaml';
    var pubspec = edits[path] ?? File(path).readAsStringSync();
    var changed = false;

    for (final MapEntry(key: name, value: version) in released.entries) {
      final dependency = RegExp(
        '^([ \\t]+$name:[ \\t]*)["\']?\\^(\\S+?)["\']?[ \\t]*\$',
        multiLine: true,
      );
      final match = dependency.firstMatch(pubspec);
      if (match == null || _caretAllows(match.group(2)!, version)) continue;

      pubspec = pubspec.replaceFirst(dependency, '${match.group(1)}^$version');
      changed = true;
      stdout.writeln('  $member: $name ^${match.group(2)} -> ^$version');
    }
    if (changed) edits[path] = pubspec;
  }

  if (dryRun) {
    stdout.writeln('\nDry run: nothing written.');
    return;
  }

  edits.forEach((path, contents) => File(path).writeAsStringSync(contents));

  final get = Process.runSync('dart', ['pub', 'get'], runInShell: true);
  if (get.exitCode != 0) {
    _git(['checkout', '--', ...edits.keys]);
    _fail('dart pub get failed, changes reverted:\n${get.stderr}${get.stdout}');
  }

  final tags = [for (final e in released.entries) '${e.key}-v${e.value}'];
  _git([
    'add',
    ...edits.keys,
    if (File('pubspec.lock').existsSync()) 'pubspec.lock',
  ]);
  _git(['commit', '-m', 'chore(release): ${tags.join(', ')}']);
  for (final tag in tags) {
    _git(['tag', '-a', tag, '-m', tag]);
  }

  stdout.writeln(
    '\nCommitted and tagged ${tags.join(', ')}.\n'
    'Run `just release-push` to push and publish.',
  );
}

final _unreleased = RegExp(r'^## Unreleased[ \t]*$', multiLine: true);
final _version = RegExp(r'^(\d+)\.(\d+)\.(\d+)([-+].*)?$');

final _versionLine = RegExp(r'^version:[ \t]*(\S+)[ \t]*$', multiLine: true);

/// Whether `^base` allows [version], following pub's rules: below 1.0.0 the
/// first non-zero part is the one that may not change.
bool _caretAllows(String base, String version) {
  if (!_version.hasMatch(base) || _compare(version, base) < 0) return false;
  final b = _parts(base), v = _parts(version);
  if (b[0] > 0) return v[0] == b[0];
  if (b[1] > 0) return v[0] == 0 && v[1] == b[1];
  return v[0] == 0 && v[1] == 0 && v[2] == b[2];
}

int _compare(String a, String b) {
  final x = _parts(a), y = _parts(b);
  for (var i = 0; i < 3; i++) {
    if (x[i] != y[i]) return x[i].compareTo(y[i]);
  }
  return 0;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}

String _git(List<String> args) {
  final result = Process.runSync('git', args);
  if (result.exitCode != 0) _fail('git ${args.join(' ')}:\n${result.stderr}');
  return result.stdout as String;
}

/// The version after [current] for a bump of [kind], or [kind] itself when it
/// is an exact version.
String _next(String current, String kind) {
  if (_version.hasMatch(kind)) return kind;
  final m = _version.firstMatch(current) ?? _fail('Cannot parse $current.');
  final [major, minor, patch] = [
    1,
    2,
    3,
  ].map((i) => int.parse(m.group(i)!)).toList();
  return switch (kind) {
    'major' => '${major + 1}.0.0',
    'minor' => '$major.${minor + 1}.0',
    'patch' => '$major.$minor.${patch + 1}',
    _ => _fail('Unknown bump "$kind": use major, minor, patch, or x.y.z.'),
  };
}

List<int> _parts(String version) {
  final m = _version.firstMatch(version) ?? _fail('Cannot parse $version.');
  return [for (var i = 1; i <= 3; i++) int.parse(m.group(i)!)];
}

Future<void> _status(Map<String, String> members) async {
  final client = HttpClient();
  for (final MapEntry(key: name, value: dir) in members.entries) {
    final pubspec = File('$dir/pubspec.yaml').readAsStringSync();
    if (RegExp(
      r'''^publish_to:\s*["']?none''',
      multiLine: true,
    ).hasMatch(pubspec)) {
      continue;
    }
    final local = _versionLine.firstMatch(pubspec)?.group(1) ?? '-';
    String published;
    try {
      final request = await client.getUrl(
        Uri.parse('https://pub.dev/api/packages/$name'),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      published = response.statusCode == 200
          ? switch (jsonDecode(body)) {
              {'latest': {'version': final String version}} => version,
              _ => '?',
            }
          : '-';
    } on IOException {
      published = '?';
    }
    final mark = local == published ? '' : '  <- unpublished';
    stdout.writeln(
      '${name.padRight(30)}${local.padRight(12)}${published.padRight(12)}$mark',
    );
  }
  client.close();
}
