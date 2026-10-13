import 'dart:io';

/// Package name -> directory, from the `workspace:` list of the root pubspec.
///
/// Must be called from the workspace root.
Map<String, String> workspaceMembers() {
  final root = File('pubspec.yaml').readAsLinesSync();
  final start = root.indexWhere((l) => l.trim() == 'workspace:');
  if (start < 0) {
    stderr.writeln('Run this from the workspace root.');
    exit(1);
  }

  final members = <String, String>{};
  for (final line in root.skip(start + 1)) {
    final entry = RegExp(r'^\s+-\s+(\S+)\s*$').firstMatch(line);
    if (entry == null) {
      if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
      break;
    }
    final dir = entry.group(1)!;
    final name = RegExp(
      r'^name:\s*(\S+)',
      multiLine: true,
    ).firstMatch(File('$dir/pubspec.yaml').readAsStringSync())!.group(1)!;
    members[name] = dir;
  }
  return members;
}
