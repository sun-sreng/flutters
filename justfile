set dotenv-load := true

default:
    @just --list

# Show workspace packages.
packages:
    @find packages -mindepth 2 -maxdepth 2 -name pubspec.yaml -print | sed 's#packages/##; s#/pubspec.yaml##' | sort

# Install workspace dependencies.
get:
    dart pub get

# Format Dart code in the workspace.
format:
    dart format .

# Analyze every package in the workspace.
analyze:
    dart analyze .

# Run tests for the core Dart packages.
test-dart:
    dart test packages/gmana
    dart test packages/gmana_value_objects

# Run Flutter tests for gmana_flutter.
test-flutter:
    flutter test packages/gmana_flutter

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
    cd packages/{{package}} && dart analyze

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
    dart analyze packages/gmana
    dart test packages/gmana
    cd packages/gmana && dart pub publish --dry-run
