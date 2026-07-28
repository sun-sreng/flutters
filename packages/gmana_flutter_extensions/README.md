# gmana_flutter_extensions

Focused Flutter extension methods and small services for the Gmana ecosystem.

```dart
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';
```

---

## Table of contents

- [Color](#color)
- [Responsive layout](#responsive-layout)
- [Build context](#build-context)
- [Widget composition](#widget-composition)
- [EdgeInsets & TextStyle](#edgeinsets--textstyle)
- [Theme mode](#theme-mode)
- [Icon serialization](#icon-serialization)
- [Time of day](#time-of-day)

---

## Color

Extensions on `Color` (`ColorExt`) and `String` (`StringColorExtension`), backed by `ColorService`.

### Parsing

```dart
// From hex string — supports #RGB, #RRGGBB, #AARRGGBB, with or without #
final color = '#FF5500'.toColor();
final transparent = '#80FF5500'.toColor();     // 50% alpha
final shorthand = '#F50'.toColor();            // expands to #FF5500

// With opacity applied after parsing
final faded = '#FF5500'.toColorWithOpacity(0.5);

// Nullable parse (returns null on invalid input)
final maybeColor = ColorService.tryParseHex('not-a-color'); // null
```

### Hex output

```dart
final color = Colors.deepOrange;

color.toHexRGB();                  // '#FF5722'
color.toHexRGB(withHashSign: false); // 'FF5722'
color.toHexARGB();                 // '#FFFF5722'
```

### Lightness & saturation

```dart
color.darken();          // 10% darker (default)
color.darken(0.3);       // 30% darker
color.lighten();         // 10% lighter
color.lighten(0.2);      // 20% lighter

color.saturate();        // 10% more saturated
color.desaturate(0.5);   // 50% less saturated
color.greyscale;         // fully desaturated
```

### Mixing

```dart
// Blend two colors — t=0 returns this, t=1 returns other
color.mix(Colors.white, 0.3);   // 30% toward white

// Shade: mix with black; tint: mix with white
color.shade(0.2);   // 20% darker via black mix
color.tint(0.4);    // 40% lighter via white mix

color.withAlphaOpacity(0.5);   // 50% transparent; throws on invalid value
```

### Harmony

```dart
color.complementary;            // hue + 180°
color.triadic;                  // (hue + 120°, hue + 240°)
color.splitComplementary;       // (hue + 150°, hue + 210°)

// Returns 2 * count colors: [left1, right1, left2, right2, …]
color.analogous();              // 4 colors, ±15° steps (count: 2, spread: 30°)
color.analogous(count: 3, spreadDegrees: 60); // 6 colors, ±20° steps
```

### Contrast & accessibility

```dart
color.isDark;    // luminance < 0.179
color.isLight;   // luminance >= 0.179

// Highest-contrast color for text on this background
color.contrastText;                                    // white or black
color.bestContrast([Colors.red, Colors.blue, Colors.white]); // custom candidates

color.contrastRatio(Colors.white);   // WCAG contrast ratio (e.g. 4.73)

color.meetsWcagAA(Colors.white);     // ratio >= 4.5
color.meetsWcagAAA(Colors.white);    // ratio >= 7.0
```

### Material swatch

```dart
// Shade 500 = the input color itself; 50–400 approach white, 600–900 approach black
final swatch = color.toMaterialColor();
swatch[300]; // lighter variant
swatch[700]; // darker variant
```

---

## Responsive layout

Breakpoint thresholds: mobile `< 730`, tablet `730–1199`, desktop `1200–1599`, widescreen `≥ 1600`.

### From `BuildContext` (`ResponsiveContext`)

```dart
// Current breakpoint
context.breakpoint;         // Breakpoint.mobile / .tablet / .desktop / .widescreen
context.isMobile;
context.isTablet;
context.isDesktop;
context.isWidescreen;
context.isAtLeastTablet;    // tablet, desktop, or widescreen
context.isAtLeastDesktop;   // desktop or widescreen

// Resolve a value for the current breakpoint; larger tiers fall back to smaller ones
final padding = context.responsive<double>(mobile: 16, tablet: 24, desktop: 32);
final columns = context.responsive<int>(mobile: 1, tablet: 2, desktop: 4);
```

### From `BoxConstraints` (`BreakpointUtils`)

Useful inside `LayoutBuilder` — reacts to the widget's available width, not the screen width.

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final cols = constraints.resolve<int>(mobile: 1, tablet: 2, desktop: 4);

    return GridView.count(crossAxisCount: cols, children: [...]);
  },
);

// Individual checks
constraints.isMobile;
constraints.isAtLeastTablet;
constraints.breakpoint;          // Breakpoint enum value

// Geometry helpers
constraints.largestSize;         // Size(maxWidth, maxHeight) — may be infinity
constraints.smallestSize;        // Size(minWidth, minHeight)
constraints.isTight;             // both axes tightly constrained
constraints.isUnboundedWidth;    // maxWidth == double.infinity
constraints.isUnboundedHeight;

// Shrink max dimensions by insets (clamps to minWidth / minHeight)
constraints.deflate(const EdgeInsets.all(16));

// Clamp max dimensions to a specific size
constraints.tightenMaxSize(const Size(400, 300));
```

### `Breakpoint` enum

```dart
// Pattern-match a value per breakpoint
final iconSize = context.breakpoint.when(
  mobile: () => 24.0,
  tablet: () => 28.0,
  desktop: () => 32.0,            // widescreen falls back to desktop when omitted
);

// Optional per-tier, with a required fallback
final badge = context.breakpoint.maybeWhen(
  desktop: () => const DesktopBadge(),
  orElse: () => const SmallBadge(),
);

// Predicate helpers
context.breakpoint.isAtLeastTablet;
context.breakpoint.isDesktop;    // true for desktop AND widescreen
```

---

## Build context

All helpers available via `ContextExt` on `BuildContext`.

### Theme & media

```dart
context.theme;              // ThemeData
context.colorScheme;        // ColorScheme
context.textTheme;          // TextTheme

context.screenSize;         // Size  — reacts only to size changes
context.screenWidth;        // double
context.screenHeight;       // double
context.devicePixelRatio;   // double
context.textScaleFactor;    // double

context.isLandscape;
context.isPortrait;

context.safeAreaPadding;    // EdgeInsets — notch + home indicator
context.topSafeArea;        // double
context.bottomSafeArea;     // double
context.viewInsets;         // keyboard insets
context.viewPadding;

// Full MediaQueryData when you need something not covered above
context.mediaQuery;
```

### Navigation

```dart
context.canPop;                           // bool
context.pop();                            // safe pop — no-op if nothing to pop
context.pop('result');                    // pop with a typed result

context.push(const ProfilePage());        // returns Future<T?>
context.pushReplacement(const HomePage());
context.pushAndRemoveUntil(const LoginPage()); // clears entire stack
context.popToRoot();                      // pops until route.isFirst
context.popUntil((route) => route.settings.name == '/home');
```

### Dialogs & sheets

```dart
// Generic dialog
context.showAppDialog<bool>(dialog: const MyDialog());

// Confirm dialog — returns true / false
final confirmed = await context.showConfirmDialog(
  title: 'Delete item',
  message: 'This cannot be undone.',
  confirmLabel: 'Delete',
  cancelLabel: 'Keep',
  destructive: true,          // styles confirm button with colorScheme.error
);

// Bottom sheet
context.showAppBottomSheet(
  child: const FilterSheet(),
  isScrollControlled: true,
  isDismissible: true,
  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
);
```

### Snack bars

```dart
context.showSnackBar(message: 'Saved');
context.showSnackBar(
  message: 'Custom',
  textColor: Colors.white,
  backgroundColor: Colors.indigo,
  duration: const Duration(seconds: 5),
  behavior: SnackBarBehavior.fixed,
  action: SnackBarAction(label: 'Undo', onPressed: () {}),
);

context.showSuccessSnackBar(message: 'Profile updated');   // colorScheme.primary
context.showErrorSnackBar(message: 'Upload failed');       // colorScheme.error
context.showWarningSnackBar(message: 'Low storage');       // colorScheme.tertiary

context.hideSnackBar();
```

### Focus

```dart
context.hasFocus;                  // bool
context.unfocus();                 // dismiss keyboard / clear focus
context.requestFocus(myFocusNode);
```

---

## Widget composition

Fluent widget modifier extensions (`WidgetX`):

```dart
Text('Click Me')
  .paddingAll(16)
  .centered
  .onTap(() => print('Tapped!'));

Image.asset('logo.png')
  .fitted(BoxFit.contain)
  .clipped(BorderRadius.circular(12))
  .expanded();
```

---

## EdgeInsets & TextStyle

Fluent modifier extensions on `EdgeInsets` and `TextStyle`:

```dart
final padding = const EdgeInsets.all(12).withTop(24);
print(padding.horizontalInsets); // 24.0
print(padding.verticalInsets);   // 36.0

final headerStyle = Theme.of(context).textTheme.headlineMedium
  ?.bold
  .underline
  .withColor(Colors.indigo);
```


---

## Theme mode

Extensions on `ThemeMode` (`ThemeModeExt`) and `String` (`ThemeModeStringExt`), backed by `ThemeModeService`.

```dart
// ThemeMode → display values
ThemeMode.dark.toIcon();    // Icons.dark_mode
ThemeMode.light.toLabel();  // 'Light Mode'
ThemeMode.system.toKey();   // 'system'

// String → ThemeMode (unknown keys fall back to ThemeMode.system)
'dark'.toThemeMode();       // ThemeMode.dark
'invalid'.toThemeMode();    // ThemeMode.system

// String → display values directly
'light'.toThemeIcon();      // Icons.light_mode
'system'.toThemeLabel();    // 'System Mode'

// All available keys — useful for building a picker
ThemeModeService.getThemeKeys(); // ['system', 'light', 'dark']
```

### Persistence example

```dart
// Save
prefs.setString('themeMode', currentMode.toKey());

// Restore
final saved = prefs.getString('themeMode') ?? 'system';
final mode = saved.toThemeMode();
```

---

## Icon serialization

`IconDataExt` (static parser) and `IconDataSerialization` (extension on `IconData`).

```dart
// Serialize
final json = Icons.star.toJsonString();
// '{"codePoint":57493,"fontFamily":"MaterialIcons"}'
// null fields and matchTextDirection:false are omitted for compact output

// Parse — returns null on failure
final icon = IconDataExt.tryParse(json);

// Parse — returns a fallback on failure
final safeIcon = IconDataExt.parse(json, fallback: Icons.question_mark);
IconDataExt.parse('bad input');   // Icons.question_mark (default fallback)
```

### Storage / database example

```dart
// Write
row['icon'] = selectedIcon.toJsonString();

// Read
final icon = IconDataExt.tryParse(row['icon'] as String? ?? '') ?? Icons.label;
```

---

## Time of day

Extension on `TimeOfDay` (`TimeOfDayExtensions`).

```dart
TimeOfDay.now().toCustomString();
// '02:30 PM'

const TimeOfDay(hour: 9, minute: 5).toCustomString();
// '09:05 AM'
```
