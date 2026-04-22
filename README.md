# Gmana Workspace

<p align="center">
  A powerful ecosystem of Dart and Flutter packages engineered to accelerate development, enforce clean architecture, and standardize your codebase.
</p>

---

## 📦 Packages

This repository is structured as a monorepo containing the following packages:

| Package | Version | Description | Environment |
| --- | --- | --- | --- |
| [**gmana**](./packages/gmana) | `^0.1.5` | The foundation layer. Provides functional helpers, extensions, low-level validation primitives, and utility classes. | Pure Dart |
| [**gmana_flutter**](./packages/gmana_flutter) | `^0.0.8` | The presentation layer. A curated library of branded `G*` widgets, theme management services, color contrast utilities, and form helpers. | Flutter |
| [**gmana_value_objects**](./packages/gmana_value_objects) | `^0.0.4` | The domain layer. Provides typed value objects and rich validation errors for domain-safe input handling. | Pure Dart |

---

## 🚀 Getting Started

The packages in this workspace are designed to be used collectively or independently based on your project's needs.

### 1. Pure Dart Server / API Layer
If you are strictly building out a backend using Dart (Shelf, Dart Frog, etc) or establishing your application's Domain layer without relying on Flutter UI imports:

```bash
dart pub add gmana gmana_value_objects
```
- Utilize `gmana` for `IdGenerator` logic, extensions, and pure functional tools.
- Utilize `gmana_value_objects` to enforce strongly-typed domain models before parsing logic into your database.

### 2. Full Flutter Frontend
For standard Flutter app development, importing all three brings maximum efficiency:

```bash
flutter pub add gmana gmana_flutter gmana_value_objects
```
- Map data elegantly through `gmana` extensions (`myString.toTitleCase`, `timeout.toDuration()`).
- Build UIs instantly with `gmana_flutter` (`GSpinnerWaveDot`, `GAppBar`, `SizedBoxHeight`, `GEmailField`).
- Connect them safely to your state management (Riverpod/Bloc) via `gmana_value_objects` error validation.

---

## 🧑‍💻 Contributing & Development

This repository relies on Dart/Flutter's native workspace capabilities.

### Setup
To get started modifying the packages locally:
1. Clone the repository
2. Run standard workspace checks to fetch all dependencies recursively:
```bash
flutter pub get
```

### Exploring Documentation
Every package within `packages/` is fully documented. Please review each package's individual `README.md` to see its full capabilities, configurations, and API examples:
- [gmana README](./packages/gmana/README.md)
- [gmana_flutter README](./packages/gmana_flutter/README.md)
- [gmana_value_objects README](./packages/gmana_value_objects/README.md)

---

## 📄 License
MIT
