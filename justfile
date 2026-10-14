set dotenv-load := true

# Package selection lives in the `workspace` list of the root pubspec.yaml.
# No recipe here names a set of packages.

default:
    @just --list

# Show workspace packages.
packages:
    @dart pub workspace list

# Install workspace dependencies.
get:
    dart pub get

# Format Dart code in the workspace.
format:
    dart format .

# Check formatting without modifying files.
format-check:
    dart format --output=none --set-exit-if-changed .

# Analyze every package in the workspace.
analyze:
    dart analyze --fatal-infos --fatal-warnings .

# Run tests for all pure Dart packages.
test-dart:
    dart run scripts/test.dart --dart

# Run Flutter tests for all Flutter packages.
test-flutter:
    dart run scripts/test.dart --flutter

test: test-dart test-flutter

# Run analyzer and tests used before publishing.
check:
    just analyze
    just test-dart
    just test-flutter

# Run pub publish dry-run checks for all packages.
publish-dry:
    ./publish.sh --dry-run

# Publish all packages. Requires a clean git worktree.
publish:
    ./publish.sh

# Install dependencies for one package. Example: just pkg-get gmana
pkg-get package:
    cd packages/{{package}} && dart pub get

# Analyze one package. Example: just pkg-analyze gmana
pkg-analyze package:
    cd packages/{{package}} && dart analyze --fatal-infos --fatal-warnings

# Test one Dart package. Example: just pkg-test gmana
pkg-test package:
    cd packages/{{package}} && dart test

# Run pub publish dry-run for one package. Example: just pkg-publish-dry gmana
pkg-publish-dry package:
    ./publish.sh --dry-run {{package}}

# Publish one package. Requires a clean git worktree.
pkg-publish package:
    ./publish.sh {{package}}

# Convenience checks for the gmana package.
gmana-check:
    dart analyze --fatal-infos --fatal-warnings packages/gmana
    dart test packages/gmana
    cd packages/gmana && dart pub publish --dry-run

# Each argument is <package>:<major|minor|patch|x.y.z>, for example
# `just release gmana_utils:minor gmana:patch`. Add --dry-run to preview.
# Bump versions and dependents' constraints, date CHANGELOGs, commit and tag.
release +args:
    dart run scripts/release.dart {{args}}

# Packages with `publish_to: none` (the examples) are skipped. Bumps versions,
# dependents' constraints and README snippets, dates or writes CHANGELOGs,
# commits, tags, then pushes the tags dependencies first. Add --dry-run to
# preview.
# Patch-release every publishable package and publish it via CI.
publish-patch-all *flags:
    dart run scripts/release.dart all:patch --push {{flags}}

# GitHub starts no workflow for tags pushed more than three at a time, so each
# tag goes on its own, dependencies first.
# Push the release commit, then each of its tags (which publishes them).
release-push:
    dart run scripts/release.dart --push

# Local version of every package next to the latest on pub.dev.
versions:
    @dart run scripts/release.dart --status
