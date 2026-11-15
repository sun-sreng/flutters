---
name: gmana-extensions-guide
description: Comprehensive reference and rules for using and extending the pure Dart extensions in package:gmana (lib/extensions.dart).
---

# `gmana` Extensions Guide

`packages/gmana/lib/src/extensions` provides pure Dart extension methods for core Dart types (`Duration`, `num`, `String`, `Iterable`, `List`, `Stream`, and nullable types).

Always import `package:gmana/extensions.dart` (or `package:gmana/gmana.dart`) when performing common Dart operations across the monorepo instead of duplicating helper functions.

---

## 1. Quick Reference

### Duration Utilities (`num_duration_extension.dart`, `duration_ext.dart`)
- **Fluent Construction**: `5.seconds`, `30.minutes`, `2.hours`, `500.ms`, `1.days`, `3.weeks`, `120.framesAt(24)`
- **Arithmetic & Clamping**: `d.clamp(1.hours, 2.hours)`, `d.coerceAtLeast(2.hours)`, `d.isWithin(15.minutes, 1.hours)`
- **Rounding**: `d.roundToMinutes()`, `d.ceilTo(5.minutes)`, `d.floorToSeconds()`
- **Parts & Doubles**: `d.hoursPart`, `d.minutesPart`, `d.inHoursDouble`

### Nullable Type Utilities (`*_nullable_x.dart`)
- **`String?`**: `s.isNullOrEmpty`, `s.isBlank` (predicate), `s.orEmpty`, `s.orNull`
- **`bool?`**: `b.orFalse`, `b.orTrue`, `b.isTrue`, `b.isFalse`, `b.isNullOrFalse`, `b.isNullOrTrue`
- **`num?` / `int?` / `double?`**: `n.orZero`, `n.isNullOrZero`, `n.orDefault(10)`

### String & Validation Utilities (`string_ext.dart`, predicates, `StringValidation`)
- **String Transformations**: `str.capitalize()`, `str.titleCase()`, `str.slugify()`, `str.truncate(20)`
- **Validations**: `str.isValidEmail`, `str.isValidBase64`, `str.isValidE164Phone` (`StringValidation`); `str.isUrl()`, `str.isCreditCard`, `str.isIpv4`, `str.isHexColor` (predicates)

### Iterables & Collections (`iterable_ext.dart`, `list_ext.dart`)
- **Iterable**: `list.firstWhereOrNull((e) => ...)`, `list.distinctBy((e) => e.id)`, `list.chunked(10)`, `list.sumBy((e) => e.price)`
- **List**: `list.swap(i, j)`, `list.replaceWhere((e) => e.id == id, newItem)`, `list.toggle(item)`

### Streams (`stream_ext.dart`)
- `stream.whereNotNull()`, `stream.debounce(300.ms)`, `stream.throttle(1.seconds)`

---

## 2. Monorepo Extension Conventions

1. **File Location**: All extension implementations live in `packages/gmana/lib/src/extensions/`.
2. **Naming Scheme**: Use `<type>_ext.dart` or `<type>_x.dart` / `<type>_nullable_x.dart`.
3. **Exports**: Export all extension files from `packages/gmana/lib/extensions.dart`.
4. **No duplicates**: Use the predicates (`lib/src/predicates/`) and validators (`lib/src/validation/`) for underlying logic rather than embedding raw logic in extensions, and never declare a member name that another extension already declares on the same type.
