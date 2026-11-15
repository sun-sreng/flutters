# Gmana Workspace

Dart and Flutter packages that speed up development, enforce clean architecture, and standardize your codebase.

## 📦 Packages

| Package                                       | Platform  | Description                                                                                                                                         |
| --------------------------------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| [**gmana**](./packages/gmana)                 | Pure Dart | Functional types (`Either`, `Option`, `GResult`), extensions, predicates, typed validators, value objects (`Email`, `Password`, `Money`, …), and resilience utilities. |
| [**gmana_flutter**](./packages/gmana_flutter) | Flutter   | Design tokens, `G*` widgets, typed form fields, loading spinners, and Flutter extensions. Depends on and re-exports `gmana`.                        |

`gmana_lints` holds the shared analysis options both packages use as a dev dependency.

---

## 🚀 Getting Started

### Pure Dart — server, CLI, or domain layer

```bash
dart pub add gmana
```

```dart
import 'package:gmana/gmana.dart';
```

### Flutter app

```bash
flutter pub add gmana_flutter
```

```dart
import 'package:gmana_flutter/gmana_flutter.dart'; // includes everything in gmana
```

Both packages also ship topic libraries (`package:gmana/validation.dart`, `package:gmana_flutter/form.dart`, and others) when you want a narrower import.

### Migrating from the split packages

`gmana_functional`, `gmana_utils`, `gmana_extensions`, `gmana_predicates`, `gmana_validation`, and `gmana_value_objects` are now part of `gmana`. `gmana_flutter_extensions`, `gmana_form`, and `gmana_spinner` are now part of `gmana_flutter`. The old packages are discontinued. See the migration tables in the [gmana](./packages/gmana/CHANGELOG.md) and [gmana_flutter](./packages/gmana_flutter/CHANGELOG.md) changelogs.

---

## 🧑‍💻 Development

This repository uses Dart/Flutter's native workspace.

```bash
# Install all dependencies across every package
flutter pub get

# Run all Dart and Flutter tests (requires `just`)
just test
```

---

## 📖 Guides

- [gmana](./packages/gmana/README.md): functional types, extensions, predicates, validation, value objects, and utilities, each with a guide in [`doc/`](./packages/gmana/doc)
- [gmana_flutter](./packages/gmana_flutter/README.md): widgets, design tokens, forms, spinners, and Flutter extensions, with guides in [`doc/`](./packages/gmana_flutter/doc)

---

## 📄 License

MIT
