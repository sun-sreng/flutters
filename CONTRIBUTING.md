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
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.29.0)
- [Dart SDK](https://dart.dev/get-dart) (>= 3.7.0)
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
   ```

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
