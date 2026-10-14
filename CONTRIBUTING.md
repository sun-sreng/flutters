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
   dart run scripts/test.dart
   ```

### Tooling

The repo is a plain [pub workspace](https://dart.dev/tools/pub/workspaces); there is no other
monorepo tool. The `just` recipes, CI, and the publish workflow use the SDK directly, plus a few
scripts:

- [`scripts/test.dart`](scripts/test.dart) runs `flutter test` or `dart test` in each package
  with a `test/` directory (`--dart` / `--flutter` to pick one kind).
- [`publish.sh`](publish.sh) checks and publishes packages in dependency order.
- [`scripts/release.dart`](scripts/release.dart) versions packages (see [Releasing](#releasing)).

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

### Releasing

Never edit a `version:` line by hand. On a clean `main`:

```bash
just release gmana_utils:minor gmana:patch   # <package>:<major|minor|patch|x.y.z>, --dry-run to preview
just release-push

just publish-patch-all                       # every publishable package, patch bump, pushed
```

`just release` runs [`scripts/release.dart`](scripts/release.dart), which for each
named package (`all:<bump>` names every package not marked `publish_to: none`):

- sets the new `version:` in its pubspec;
- turns its `## Unreleased` heading into `## <version> - <YYYY-MM-DD>`, or, when there
  is none, writes that section from the commits that touched the package since its
  last tag (`- Updated dependencies.` when there are none);
- moves every `^` constraint on it in a workspace pubspec, examples included, to the
  new version;
- moves every `<package>: ^x.y.z` snippet in a tracked Markdown file (CHANGELOGs
  excepted) to the new version;

then runs `dart pub get`, commits, and tags `<package>-v<version>`. It refuses to run
with uncommitted changes. `just release-push` pushes the commit, then each tag on its
own with dependencies first; every tag starts the publish workflow for that one
package. `just versions` shows local versus pub.dev versions.

Bumps follow plain semver (`minor`: 0.1.2 → 0.2.0, `patch`: 0.1.2 → 0.1.3). Below
1.0.0, `^0.x.y` only allows `0.x.*` and `^0.0.y` only allows `0.0.y`, so a breaking
change is a `minor` bump on `0.x` and any change to a `0.0.x` package changes what
its dependents can use. Dependents get the new constraint in the repo but are not
released for you; name them too (or use `all:patch`) so pub.dev gets it.

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
