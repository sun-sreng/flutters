# Contributing to Gmana

Thank you for your interest in contributing to the Gmana ecosystem! We welcome contributions, bug reports, and suggestions.

---

## 🏛 Workspace Architecture

Gmana is a Dart & Flutter monorepo organized into three layers:

- **Foundation (Pure Dart)**: `gmana_functional`, `gmana_predicates`, `gmana_utils`, `gmana_extensions`, `gmana_validation`, and `gmana_lints`.
- **Domain (Pure Dart)**: `gmana_value_objects`.
- **Presentation (Flutter)**: `gmana_flutter`, `gmana_flutter_extensions`, `gmana_form`, and `gmana_spinner`.
- **Facade**: `gmana` re-exports all pure Dart packages from a single import.

---

## 🛠 Local Development Setup

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install), current stable. The workspace root
  requires Dart >= 3.10.7, which is newer than the minimum the published packages declare.
  The Dart SDK on its own is not enough: `pub get` cannot resolve a workspace that contains
  Flutter packages without Flutter.
- Optional: [Just command runner](https://github.com/casey/just)

### Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/sun-sreng/flutters.git
   cd flutters
   ```

2. Install all dependencies across every package:
   ```bash
   flutter pub get
   # or with just:
   just get
   ```

3. Run the analyzer:
   ```bash
   dart analyze --fatal-infos --fatal-warnings .
   # or:
   just analyze
   ```

4. Format code:
   ```bash
   dart format .
   # or:
   just format
   ```

5. Run all tests:
   ```bash
   just test
   # or without just:
   dart run melos run test
   ```

### Tooling

[Melos](https://melos.invertase.dev) is a dev dependency of the workspace root and is configured in
the root `pubspec.yaml` under `melos:`. Its scripts — `lint`, `format`, `test:dart`, `test:flutter`,
`publish:dry-run` — are what CI, the publish workflow, and the `just` recipes run.

To add a package, create it under `packages/` and add it to `workspace:` in the root `pubspec.yaml`.
Nothing else lists packages: the scripts pick Dart or Flutter packages by their dependencies, and
the publish order follows the dependency graph.

### Changelog format

Each package's `CHANGELOG.md`:

- Starts at the newest entry, with no `# Changelog` title.
- Collects pending changes under `## Unreleased`. At release that heading becomes
  `## <version> - <YYYY-MM-DD>`.
- Groups entries under `### Added`, `### Changed`, `### Deprecated`, `### Removed`, and
  `### Fixed`, in that order, leaving out the empty ones. Prefix a breaking entry with
  `**Breaking:**`.

---

## 📋 Pull Request Checklist

Before submitting a pull request, ensure:

- [ ] Code follows standard formatting (`dart format .`).
- [ ] Static analyzer passes without warnings (`dart analyze --fatal-infos --fatal-warnings .`).
- [ ] All unit and widget tests pass (`just test`).
- [ ] New features or bug fixes include corresponding tests in `test/`.
- [ ] Public API methods and classes have descriptive doc comments (`///`).
- [ ] Relevant package `CHANGELOG.md` files are updated under the `## Unreleased` section.
- [ ] Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) format (e.g. `feat(gmana_utils): ...`, `fix(gmana_form): ...`).
