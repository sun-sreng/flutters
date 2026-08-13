# Gmana Workspace

A layered ecosystem of Dart and Flutter packages engineered to accelerate development, enforce clean architecture, and standardize your codebase.

## 📦 Packages

The monorepo is organized into three layers. The `gmana` facade gives you everything in the Pure Dart layer from one import; the Flutter packages are opt-in.

### Pure Dart — foundation

| Package                                             | Version | Description                                                                                 |
| --------------------------------------------------- | ------- | ------------------------------------------------------------------------------------------- |
| [**gmana**](./packages/gmana)                       | `0.2.0` | Convenience facade — re-exports all Pure Dart packages below from a single import.          |
| [**gmana_extensions**](./packages/gmana_extensions) | `0.0.1` | Extension methods on `Duration`, `String`, `num`, `Iterable`, and `Stream`.                 |
| [**gmana_functional**](./packages/gmana_functional) | `0.0.1` | Functional primitives — `Either<L,R>`, `Result`, `UseCase`, `Failure`, `Unit`.              |
| [**gmana_predicates**](./packages/gmana_predicates) | `0.0.1` | Boolean predicate functions — email, alpha, date, UUID, credit card, and more.              |
| [**gmana_utils**](./packages/gmana_utils)           | `0.0.1` | Resilience and timing utilities — retry, `CircuitBreaker`, `Semaphore`, `AsyncCache`, `Batcher`, debounce/throttle, `Result`, ID generation. |
| [**gmana_validation**](./packages/gmana_validation) | `0.0.1` | Typed validators for email, password, text, and number inputs using `Either`-based results. |

### Pure Dart — domain

| Package                                                   | Version | Description                                                                                                   |
| --------------------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------- |
| [**gmana_value_objects**](./packages/gmana_value_objects) | `0.0.6` | Production-ready value objects with configurable validation — `Email`, `Password`, `Text`, `Number`, `Money`. |

### Flutter — presentation

| Package                                                             | Version | Description                                                                                                       |
| ------------------------------------------------------------------- | ------- | ----------------------------------------------------------------------------------------------------------------- |
| [**gmana_flutter**](./packages/gmana_flutter)                       | `0.0.8` | UI library — branded `G*` widgets, theme management, and a compatibility re-export of all Flutter packages below. |
| [**gmana_flutter_extensions**](./packages/gmana_flutter_extensions) | `0.0.1` | Flutter extension methods — color, layout, `BuildContext`, icons, time, and theme mode.                           |
| [**gmana_form**](./packages/gmana_form)                             | `0.0.1` | Form fields, validators, and submit controls — `GEmailField`, `GPasswordField`, `GElevatedButton`, and more.      |
| [**gmana_spinner**](./packages/gmana_spinner)                       | `0.0.1` | Loading indicators — `GCircularSpinner`, `GWaveDotSpinner`, `GDotSpinner`, and more.                              |

---

## 🚀 Getting Started

### 1. Pure Dart — server / API / domain layer

```bash
dart pub add gmana gmana_value_objects
```

- `gmana` gives you extensions, functional primitives, validation, and utilities in one import.
- `gmana_value_objects` enforces strongly-typed domain models before data reaches your database or state.

### 2. Full Flutter app

```bash
flutter pub add gmana gmana_flutter gmana_value_objects
```

- `gmana_flutter` re-exports all Flutter packages, so one import covers widgets, forms, spinners, and extensions.
- Use focused packages directly when you only need part of the stack:

```bash
flutter pub add gmana_flutter_extensions   # just context/color/layout helpers
flutter pub add gmana_form                 # just form fields
flutter pub add gmana_spinner              # just loading indicators
```

### 3. Manual `pubspec.yaml` setup

```yaml
dependencies:
  # Pure Dart
  gmana: ^0.2.0
  gmana_value_objects: ^0.0.6

  # Flutter (use gmana_flutter as the umbrella, or pick individually)
  gmana_flutter: ^0.0.8
  gmana_flutter_extensions: ^0.0.1
  gmana_form: ^0.0.1
  gmana_spinner: ^0.0.1
```

---

## 🧑‍💻 Development

This repository uses Dart/Flutter's native workspace.

```bash
# Install all dependencies across every package
flutter pub get

# Run all tests
dart test
```

---

## 📖 Package READMEs

Each package has its own full API guide with examples:

- [gmana](./packages/gmana/README.md)
- [gmana_extensions](./packages/gmana_extensions/README.md)
- [gmana_functional](./packages/gmana_functional/README.md)
- [gmana_predicates](./packages/gmana_predicates/README.md)
- [gmana_utils](./packages/gmana_utils/README.md)
- [gmana_validation](./packages/gmana_validation/README.md)
- [gmana_value_objects](./packages/gmana_value_objects/README.md)
- [gmana_flutter](./packages/gmana_flutter/README.md)
- [gmana_flutter_extensions](./packages/gmana_flutter_extensions/README.md)
- [gmana_form](./packages/gmana_form/README.md)
- [gmana_spinner](./packages/gmana_spinner/README.md)

---

## 📄 License

MIT
