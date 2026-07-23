---
name: gmana-extensions-guide
description: Comprehensive reference and rules for using and extending Dart utility extensions in package:gmana_extensions.
---

# `gmana_extensions` Guide

`packages/gmana_extensions` provides pure Dart extension methods for core Dart types (`Duration`, `num`, `String`, `Iterable`, `List`, `Stream`, and nullable types).

Always import `package:gmana_extensions/gmana_extensions.dart` when performing common Dart operations across the monorepo instead of duplicating helper functions.

---

## 1. Quick Reference

### Duration Utilities (`num_duration_extension.dart`, `duration_ext.dart`)
- **Fluent Construction**: `5.seconds`, `30.minutes`, `2.hours`, `500.ms`, `1.days`, `3.weeks`, `120.framesAt(24)`
- **Arithmetic & Clamping**: `d.clamp(1.hours, 2.hours)`, `d.coerceAtLeast(2.hours)`, `d.isWithin(15.minutes, 1.hours)`
- **Rounding**: `d.roundToMinutes()`, `d.ceilTo(5.minutes)`, `d.floorToSeconds()`
- **Parts & Doubles**: `d.hoursPart`, `d.minutesPart`, `d.inHoursDouble`

### Nullable Type Utilities (`*_nullable_x.dart`)
- **`String?`**: `s.isNullOrEmpty`, `s.isNullOrBlank`, `s.orEmpty`
- **`bool?`**: `b.orFalse`, `b.orTrue`, `b.isTrue`, `b.isFalse`, `b.isNullOrFalse`, `b.isNullOrTrue`
- **`num?` / `int?` / `double?`**: `n.orZero`, `n.isNullOrZero`, `n.orDefault(10)`

### String & Validation Utilities (`string_ext.dart`, `is_ext.dart`)
- **String Transformations**: `str.capitalize()`, `str.titleCase()`, `str.slugify()`, `str.truncate(20)`
- **Validations**: `str.isValidEmail`, `str.isValidUrl`, `str.isValidBase64`, `str.isValidCreditCard`, `str.isValidE164Phone`, `str.isValidIpv4`, `str.isValidHexColor`

### Iterables & Collections (`iterable_ext.dart`, `list_ext.dart`)
- **Iterable**: `list.firstWhereOrNull((e) => ...)`, `list.distinctBy((e) => e.id)`, `list.chunked(10)`, `list.sumBy((e) => e.price)`
- **List**: `list.swap(i, j)`, `list.replaceWhere((e) => e.id == id, newItem)`, `list.toggle(item)`

### Streams (`stream_ext.dart`)
- `stream.whereNotNull()`, `stream.debounce(300.ms)`, `stream.throttle(1.seconds)`

---

## 2. Monorepo Extension Conventions

1. **File Location**: All extension implementations live in `packages/gmana_extensions/lib/`.
2. **Naming Scheme**: Use `<type>_ext.dart` or `<type>_x.dart` / `<type>_nullable_x.dart`.
3. **Exports**: Export all extension files from `lib/gmana_extensions.dart`.
4. **Dependencies**: Use `gmana_predicates` and `gmana_validation` for underlying predicate logic rather than embedding raw logic in extensions.
