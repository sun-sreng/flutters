## 0.0.2

Additive release — no existing member changed behaviour or signature.

### New receiver types

- **`List<Widget>`** (`widget_list_ext.dart`): `WidgetListX` with
  `separatedBy`, `separatedByHeight`, `separatedByWidth`, `toColumn`, `toRow`,
  `toStack`, `toWrap`, and `toListView`.
- **`ScrollController`** (`scroll_controller_ext.dart`): `ScrollControllerX`
  with `isAtTop`, `isAtBottom`, `isScrollable`, `progress`, `offsetOrZero`,
  `maxScroll`, `minScroll`, `isScrollingUp`, `isScrollingDown`, `isNearTop`,
  `isNearBottom`, `animateToTop`, `animateToBottom`, `jumpToTop`,
  `jumpToBottom`, and `jumpToClamped`. Every member guards on `hasClients`,
  so a detached controller degrades to a safe default instead of throwing.
- **`TextEditingController`** (`text_editing_controller_ext.dart`):
  `TextEditingControllerX` with `isBlank`, `isNotBlank`, `trimmedText`,
  `trimmedTextOrNull`, `setTextAndCursorToEnd`, `moveCursorToEnd`,
  `selectAll`, `insertAtCursor`, and `clearAndReset`.
- **`Brightness` / `ThemeData`** (`brightness_ext.dart`): `BrightnessX`
  (`isDark`, `isLight`, `opposite`, `select`) and `ThemeDataX` (`isDark`,
  `isLight`, `select`).
- **`DateTime`**: `DateTimeTimeOfDayX.timeOfDay`.

### Extended receivers

- **`TimeOfDay`**: `TimeOfDayExtensions.fromMinutes`, `inMinutes`,
  `asFractionalHours`, `sinceMidnight`, `isMidnight`, `isNoon`,
  `to24HourString`, `compareTo`, `isBefore`, `isAfter`, `isAtSameTimeAs`,
  `isBetween` (handles ranges crossing midnight), `difference`,
  `durationUntil`, `addMinutes`, `subtractMinutes`, `addHours`, `add`,
  `roundToNearest`, `clampTo`, and `toDateTime`.
- **`Widget`**: `sized`, `squared`, `constrained`, `aspectRatio`, `aligned`,
  `positioned`, `safeArea`, `opacity`, `decorated`, `background`, `rotated`,
  `scaled`, `visible`, `ignorePointer`, `absorbPointer`, `inkWell`, `tooltip`,
  `hero`, and `sliverBox`.
- **`TextStyle`**: `light`, `regular`, `medium`, `semiBold`, `black`,
  `noDecoration`, `withDecoration`, `withHeight`, `withWordSpacing`,
  `withFamily`, `scaled`, `withAlphaOpacity`, `withShadow`, plus a new
  `TextStyleNullableX` (`orDefault`, `map`) for the nullable `TextTheme` slots.
- **`EdgeInsets`**: `isZero`, `largestSide`, `horizontalOnly`, `verticalOnly`,
  `scaled`, `grown`, `shrunk`, and `mergeMax`.
- **`BuildContext`**: `brightness`, `isDarkMode`, `isLightMode`,
  `byBrightness`, `keyboardHeight`, `isKeyboardVisible`, `orientation`,
  `shortestSide`, `longestSide`, `platform`, `isAndroid`, `isIOS`,
  `isApplePlatform`, `isDesktopPlatform`, and `showInfoSnackBar`.
- **`Color` / `ColorService`**: `tetradic`, `monochromatic`, `toCssRgba`,
  `hue`, `saturation`, `lightness`, `withHue`, `withSaturation`,
  `withLightness`, `isTransparent`, `isOpaque`, and `opaque`.
- **`ThemeMode` / `ThemeModeService`**: `next`, `nextKey`, `all`,
  `isKnownKey`, `resolveBrightness`, plus `isSystem`, `isLight`, `isDark`, and
  `isThemeKey` on the string extension.

### Tests

Coverage went from 10 tests to 177. The new suites also cover previously
untested existing behaviour: hex parsing edge cases, colour harmonies,
contrast and WCAG thresholds, material swatch generation, `EdgeInsets` and
`TextStyle` modifiers, `ThemeModeService` round-trips, and the `ContextExt`
snack-bar variants.

## 0.0.1

- Initial focused package for Flutter extension methods and helper services.
