// Versions packages of this pub workspace. Nobody edits a `version:` line by
// hand; this does it for every package named on the command line:
//
//   dart run scripts/release.dart gmana_utils:minor gmana:patch
//   dart run scripts/release.dart gmana:0.3.0 --dry-run
//   dart run scripts/release.dart all:patch --push
//
// `all:<bump>` stands for every package not marked `publish_to: none`.
//
// For each package it sets the new version in pubspec.yaml and turns the
// `## Unreleased` heading of its CHANGELOG.md into `## <version> - <date>`; a
// CHANGELOG without that heading gets a new section listing the commits that
// touched the package since its last tag. Every `^` constraint on the package
// in a workspace pubspec, and every `<package>: ^x.y.z` snippet in a tracked
// Markdown file, moves to the new version. It then checks that the workspace
// still resolves, commits, and tags `<package>-v<version>`.
//
// --push then pushes the commit and each tag on its own, dependencies first,
// so CI publishes them in an order that resolves. Given alone, it pushes HEAD
// and the release tags on it.
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
  final push = args.contains('--push');
  final bumps = _expandAll(
    args.where((a) => !a.startsWith('--')).toList(),
    members,
  );
  if (bumps.isEmpty) {
    if (push) {
      final tags = _git(['tag', '--points-at', 'HEAD']).split('\n');
      return _push(members, tags, dryRun: dryRun);
    }
    _fail(
      'Usage: dart run scripts/release.dart <package|all>:'
      '<major|minor|patch|x.y.z> ... [--dry-run] [--push]\n'
      '       dart run scripts/release.dart --push [--dry-run]\n'
      '       dart run scripts/release.dart --status',
    );
  }

  if (!dryRun && _git(['status', '--porcelain']).trim().isNotEmpty) {
    _fail('The working tree has uncommitted changes. Commit or stash them.');
  }

  // Work out every change before writing any file, so a bad argument leaves
  // the workspace untouched.
  final edits = <String, String>{}; // path -> new contents
  final released = <String, String>{}; // package -> new version
  final today = DateTime.now().toIso8601String().substring(0, 10);

  for (final MapEntry(key: name, value: kind) in bumps.entries) {
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
    final String notes;
    if (_unreleased.hasMatch(changelog)) {
      edits[changelogPath] = changelog.replaceFirst(
        _unreleased,
        '## $next - $today',
      );
      notes = 'dated "## Unreleased"';
    } else {
      final subjects = _commitsSince('$name-v$current', dir);
      final section =
          '## $next - $today\n\n'
          '${subjects.isEmpty ? '- Updated dependencies.' : subjects.map((s) => '- $s').join('\n')}\n';
      final first = RegExp(r'^## ', multiLine: true).firstMatch(changelog);
      edits[changelogPath] = first != null
          ? '${changelog.substring(0, first.start)}$section\n'
                '${changelog.substring(first.start)}'
          : changelog.trim().isEmpty
          ? section
          : '${changelog.trimRight()}\n\n$section';
      notes = 'generated from ${subjects.length} commit(s)';
    }

    edits[pubspecPath] = pubspec.replaceFirst(_versionLine, 'version: $next');
    released[name] = next;
    stdout.writeln('$name: $current -> $next (CHANGELOG $notes)');
  }

  for (final MapEntry(key: member, value: dir) in members.entries) {
    final path = '$dir/pubspec.yaml';
    final pubspec = edits[path] ?? File(path).readAsStringSync();
    final updated = _bumpReferences(
      pubspec,
      released,
      r'[ \t]+',
      (name, old, version) =>
          stdout.writeln('  $member: $name $old -> ^$version'),
    );
    if (updated != pubspec) edits[path] = updated;
  }

  final docs = _git([
    'ls-files',
    '*.md',
  ]).split('\n').where((p) => p.isNotEmpty && !p.endsWith('CHANGELOG.md'));
  for (final path in docs) {
    final text = edits[path] ?? File(path).readAsStringSync();
    final updated = _bumpReferences(
      text,
      released,
      r'[ \t]*',
      (name, old, version) =>
          stdout.writeln('  $path: $name $old -> ^$version'),
    );
    if (updated != text) edits[path] = updated;
  }

  final tags = [for (final e in released.entries) '${e.key}-v${e.value}'];

  if (dryRun) {
    if (push) _push(members, tags, dryRun: true);
    stdout.writeln('\nDry run: nothing written.');
    return;
  }

  final created = [
    for (final p in edits.keys)
      if (!File(p).existsSync()) p,
  ];
  edits.forEach((path, contents) => File(path).writeAsStringSync(contents));

  final get = Process.runSync('dart', ['pub', 'get'], runInShell: true);
  if (get.exitCode != 0) {
    for (final path in created) {
      File(path).deleteSync();
    }
    _git(['checkout', '--', ...edits.keys.where((p) => !created.contains(p))]);
    _fail('dart pub get failed, changes reverted:\n${get.stderr}${get.stdout}');
  }

  _git([
    'add',
    ...edits.keys,
    if (File('pubspec.lock').existsSync()) 'pubspec.lock',
  ]);
  _git(['commit', '-m', 'chore(release): ${tags.join(', ')}']);
  for (final tag in tags) {
    _git(['tag', '-a', tag, '-m', tag]);
  }
  stdout.writeln('\nCommitted and tagged ${tags.join(', ')}.');

  if (push) {
    _push(members, tags, dryRun: false);
  } else {
    stdout.writeln('Run `just release-push` to push and publish.');
  }
}

final _unreleased = RegExp(r'^## Unreleased[ \t]*$', multiLine: true);
final _version = RegExp(r'^(\d+)\.(\d+)\.(\d+)([-+].*)?$');

final _versionLine = RegExp(r'^version:[ \t]*(\S+)[ \t]*$', multiLine: true);

/// Package -> bump, with `all:<bump>` expanded to every publishable package.
/// A package named on its own wins over `all`.
Map<String, String> _expandAll(List<String> args, Map<String, String> members) {
  final bumps = <String, String>{};
  for (final arg in args) {
    final [name, kind] = arg.contains(':')
        ? arg.split(':')
        : _fail('"$arg" is not <package>:<bump>.');
    if (name != 'all') continue;
    for (final MapEntry(key: member, value: dir) in members.entries) {
      if (_isPublishable(File('$dir/pubspec.yaml').readAsStringSync())) {
        bumps[member] = kind;
      }
    }
  }
  for (final arg in args) {
    final [name, kind] = arg.split(':');
    if (name != 'all') bumps[name] = kind;
  }
  return bumps;
}

bool _isPublishable(String pubspec) =>
    !RegExp(r'''^publish_to:\s*["']?none''', multiLine: true).hasMatch(pubspec);

/// Rewrites every `<package>: ^x.y.z` line in [text] whose version is older
/// than the one in [released] to `^<new version>`. [indent] is what may come
/// before the package name: pubspecs need some, so `name:` is never touched.
String _bumpReferences(
  String text,
  Map<String, String> released,
  String indent,
  void Function(String name, String old, String version) report,
) {
  var result = text;
  for (final MapEntry(key: name, value: version) in released.entries) {
    final reference = RegExp(
      '^($indent$name:[ \\t]*)["\']?(\\^?)(\\d+\\.\\d+\\.\\d+\\S*?)'
      '["\']?([ \\t]*(?:#.*)?)\$',
      multiLine: true,
    );
    result = result.replaceAllMapped(reference, (m) {
      final old = m.group(3)!;
      if (!_version.hasMatch(old) || _compare(old, version) >= 0) {
        return m.group(0)!;
      }
      report(name, '${m.group(2)}$old', version);
      return '${m.group(1)}^$version${m.group(4)}';
    });
  }
  return result;
}

/// Subjects of the commits that touched [dir] since [tag], release commits
/// left out. Empty when the tag does not exist.
List<String> _commitsSince(String tag, String dir) {
  final exists = Process.runSync('git', [
    'rev-parse',
    '-q',
    '--verify',
    'refs/tags/$tag',
  ]).exitCode;
  if (exists != 0) return [];
  return _git(['log', '--format=%s', '$tag..HEAD', '--', dir])
      .split('\n')
      .where((s) => s.isNotEmpty && !s.startsWith('chore(release)'))
      .toList();
}

/// Pushes HEAD, then each release tag in [tags] on its own (GitHub starts no
/// workflow for more than three tags in one push), dependencies first.
void _push(
  Map<String, String> members,
  List<String> tags, {
  required bool dryRun,
}) {
  final order = _dependencyOrder(members);
  int rank(String tag) =>
      order.indexOf(tag.substring(0, tag.lastIndexOf('-v')));
  final ordered = [
    for (final tag in tags)
      if (tag.contains('-v') && rank(tag) >= 0) tag,
  ]..sort((a, b) => rank(a).compareTo(rank(b)));

  if (dryRun) {
    stdout.writeln('\nWould push HEAD, then: ${ordered.join(' ')}');
    return;
  }

  _git(['push', 'origin', 'HEAD']);
  stdout.writeln('Pushed HEAD.');
  for (final tag in ordered) {
    _git(['push', 'origin', 'refs/tags/$tag']);
    stdout.writeln('Pushed $tag.');
  }
}

/// Workspace packages ordered so that each comes after the members it
/// depends on.
List<String> _dependencyOrder(Map<String, String> members) {
  final dependencies = {
    for (final MapEntry(key: name, value: dir) in members.entries)
      name: [
        for (final other in members.keys)
          if (other != name &&
              RegExp(
                '^[ \\t]+$other:',
                multiLine: true,
              ).hasMatch(File('$dir/pubspec.yaml').readAsStringSync()))
            other,
      ],
  };

  final order = <String>[];
  final visiting = <String>{};
  void visit(String name) {
    if (order.contains(name)) return;
    if (!visiting.add(name)) _fail('Circular dependency involving $name.');
    dependencies[name]!.forEach(visit);
    visiting.remove(name);
    order.add(name);
  }

  members.keys.forEach(visit);
  return order;
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
    if (!_isPublishable(pubspec)) continue;
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
