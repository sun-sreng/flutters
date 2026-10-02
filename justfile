set dotenv-load := true

# Package selection lives in the root pubspec.yaml: the `workspace` list, and
# the melos scripts that filter it. No recipe here names a set of packages.

default:
    @just --list

# Show workspace packages.
packages:
    @dart run melos list

# Install workspace dependencies.
get:
    dart pub get

# Format Dart code in the workspace.
format:
    dart run melos run format:fix

# Check formatting without modifying files.
format-check:
    dart run melos run format

# Analyze every package in the workspace.
analyze:
    dart run melos run lint

# Run tests for all pure Dart packages.
test-dart:
    dart run melos run test:dart

# Run Flutter tests for all Flutter packages.
test-flutter:
    dart run melos run test:flutter

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

# Melos monorepo helpers
melos-bootstrap:
    dart run melos bootstrap

melos-version:
    dart run melos version

melos-list:
    dart run melos list
