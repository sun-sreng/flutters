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
- [Widget lists](#widget-lists)
- [EdgeInsets & TextStyle](#edgeinsets--textstyle)
- [Brightness](#brightness)
- [Theme mode](#theme-mode)
- [Icon serialization](#icon-serialization)
- [Time of day](#time-of-day)
- [Scroll controllers](#scroll-controllers)
- [Text editing controllers](#text-editing-controllers)
- [Animation & Controllers](#animation--controllers)
- [FocusNode](#focusnode)
- [Alignment](#alignment)
- [Listenable & ValueNotifier](#listenable--valuenotifier)


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

color.toCssRgba();  // 'rgba(255, 85, 0, 1.00)'
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

color.tetradic;                 // (hue + 90°, hue + 180°, hue + 270°)

// Returns 2 * count colors: [left1, right1, left2, right2, …]
color.analogous();              // 4 colors, ±15° steps (count: 2, spread: 30°)
color.analogous(count: 3, spreadDegrees: 60); // 6 colors, ±20° steps

// Same-hue ramp, evenly spaced in lightness from near-black to near-white
color.monochromatic();          // 5 colors
color.monochromatic(count: 9);
```

### HSL components

```dart
color.hue;          // 0–360
color.saturation;   // 0–1
color.lightness;    // 0–1

color.withHue(120);         // wraps values beyond 360
color.withSaturation(0.4);  // clamped to 0–1
color.withLightness(0.8);
```

### Alpha

```dart
color.isTransparent;              // a == 0
color.isOpaque;                   // a == 1
color.opaque;                     // same color at full alpha
color.withAlphaOpacity(0.5);
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
context.orientation;        // Orientation
context.shortestSide;       // survives rotation — the usual "is this a tablet" basis
context.longestSide;

context.safeAreaPadding;    // EdgeInsets — notch + home indicator
context.topSafeArea;        // double
context.bottomSafeArea;     // double
context.viewInsets;         // keyboard insets
context.viewPadding;

context.brightness;         // Brightness
context.isDarkMode;
context.isLightMode;
context.byBrightness(light: Colors.grey, dark: Colors.white30);

context.keyboardHeight;     // double — how much the keyboard is covering
context.isKeyboardVisible;

context.platform;           // TargetPlatform
context.isAndroid;
context.isIOS;
context.isApplePlatform;    // iOS or macOS
context.isDesktopPlatform;  // linux, macOS, or windows

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

Sizing and constraints:

```dart
avatar.squared(48);
avatar.sized(width: 120, height: 40);
chart.constrained(maxWidth: 600);
video.aspectRatio(16 / 9);
```

Positioning:

```dart
badge.positioned(top: 0, right: 0);   // inside a Stack
label.aligned(Alignment.centerLeft);
body.safeArea;
```

Painting:

```dart
card.decorated(BoxDecoration(borderRadius: BorderRadius.circular(8)));
panel.background(Colors.black12);
icon.rotated(1);      // one quarter turn
icon.scaled(1.2);
overlay.opacity(0.4);
```

Visibility and input:

```dart
// Takes no space when hidden, unlike Opacity(opacity: 0)
errorText.visible(hasError);
errorText.visible(hasError, replacement: const Text('All good'));

form.ignorePointer(ignoring: isSubmitting);
row.absorbPointer();
tile.inkWell(onTap: open, borderRadius: BorderRadius.circular(8));
button.tooltip('Save the draft');
image.hero('product-42');
```

Slivers:

```dart
CustomScrollView(
  slivers: [
    header.sliverBox,
    const SliverToBoxAdapter(child: Divider()),
  ],
);
```

---

## Widget lists

`WidgetListX` turns a `List<Widget>` into a laid-out widget and inserts
separators — no `Column(children: ...)` ceremony.

```dart
[nameField, emailField, submitButton]
    .separatedByHeight(12)
    .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);

[avatar, title, trailing].toRow(spacing: 8);

tags.toWrap(spacing: 6, runSpacing: 6);

rows.separatedBy(const Divider()).toListView(padding: const EdgeInsets.all(16));

layers.toStack(alignment: Alignment.bottomRight);
```

`separatedBy` is a plain list transform, so unlike `ListView.separated` it
works anywhere `children:` is accepted:

```dart
[a, b, c].separatedBy(const Divider()); // [a, div, b, div, c]
[a].separatedBy(const Divider());       // [a] — nothing to separate
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

More `EdgeInsets` arithmetic:

```dart
const EdgeInsets.all(8).scaled(1.5);   // EdgeInsets.all(12)
const EdgeInsets.all(4).grown(4);      // EdgeInsets.all(8)
const EdgeInsets.all(4).shrunk(10);    // EdgeInsets.zero — clamps at 0

const EdgeInsets.fromLTRB(1, 2, 3, 4).horizontalOnly; // only(left: 1, right: 3)
const EdgeInsets.fromLTRB(1, 9, 3, 4).largestSide;    // 9
EdgeInsets.zero.isZero;                               // true

// Combine a design padding with a safe-area inset without double-counting
const EdgeInsets.all(16).mergeMax(mediaQuery.padding);
```

More `TextStyle` modifiers:

```dart
style.light;      // w300
style.regular;    // w400
style.medium;     // w500
style.semiBold;   // w600
style.black;      // w900

style.withHeight(1.4);
style.withWordSpacing(2);
style.withFamily('Roboto');
style.noDecoration;
style.withDecoration(TextDecoration.underline, style: TextDecorationStyle.dashed);
style.withShadow(blurRadius: 4);
style.withAlphaOpacity(0.6);
style.scaled(1.25);   // multiplies an explicit fontSize; inherited sizes pass through
```

Because every `TextTheme` slot is nullable, `TextStyleNullableX` keeps the
chain going without a `?.` at every step:

```dart
context.textTheme.titleMedium.orDefault.semiBold.withHeight(1.2);
context.textTheme.bodySmall.map((s) => s.bold); // null stays null
```

---

## Brightness

`BrightnessX` on `Brightness` and `ThemeDataX` on `ThemeData`:

```dart
theme.brightness.isDark;
theme.brightness.opposite;

theme.isDark;
theme.isLight;

// Pick a value by brightness without an if/else
final divider = theme.select(light: Colors.black12, dark: Colors.white24);
final border = context.byBrightness(light: Colors.grey, dark: Colors.white30);
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
ThemeModeService.all;            // [system, light, dark]
```

Cycling and predicates. `ThemeMode` has three values, so a single "toggle
theme" button cannot be a boolean flip:

```dart
ThemeMode.system.next();   // ThemeMode.light
ThemeMode.dark.next();     // ThemeMode.system — wraps
'light'.nextThemeKey();    // 'dark'

ThemeMode.dark.isDark;     // true
'dark'.isThemeKey;         // true
'nonsense'.isThemeKey;     // false — distinguishes a real key from the fallback

// Resolve to a concrete brightness; the platform is consulted only for system
ThemeMode.system.resolveBrightness(MediaQuery.platformBrightnessOf(context));
ThemeMode.light.resolveBrightness(Brightness.dark); // Brightness.light
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

`TimeOfDay` is a bare hour/minute pair with no `compareTo`, no arithmetic, and
no way to express a span. These fill that in, treating the value as an offset
within a single 24-hour day.

### Formatting

```dart
TimeOfDay.now().toCustomString();                     // '02:30 PM'
const TimeOfDay(hour: 9, minute: 5).toCustomString(); // '09:05 AM'
const TimeOfDay(hour: 9, minute: 5).to24HourString(); // '09:05'
```

### Conversion

```dart
const TimeOfDay(hour: 13, minute: 30).inMinutes;           // 810
const TimeOfDay(hour: 13, minute: 30).asFractionalHours;   // 13.5
const TimeOfDay(hour: 13, minute: 30).sinceMidnight;       // 13h 30m

TimeOfDayExtensions.fromMinutes(90);    // 01:30
TimeOfDayExtensions.fromMinutes(1500);  // 01:00 — wraps past a day

const TimeOfDay(hour: 14, minute: 30).toDateTime(DateTime(2024, 3, 5));
DateTime.now().timeOfDay;
```

### Comparison

```dart
opening.compareTo(closing);          // works with List.sort
opening.isBefore(closing);
opening.isAtSameTimeAs(other);

// A range that crosses midnight is handled correctly
const TimeOfDay(hour: 23, minute: 30).isBetween(
  const TimeOfDay(hour: 22, minute: 0),
  const TimeOfDay(hour: 2, minute: 0),
); // true
```

### Arithmetic

```dart
const TimeOfDay(hour: 23, minute: 0).addMinutes(90);  // 00:30 — wraps
const TimeOfDay(hour: 0, minute: 15).subtractMinutes(30); // 23:45
const TimeOfDay(hour: 23, minute: 0).addHours(3);     // 02:00
const TimeOfDay(hour: 10, minute: 0).add(const Duration(hours: 2, minutes: 30));

// Signed, no wrapping
closing.difference(opening);      // Duration

// Forward-only, wraps past midnight
const TimeOfDay(hour: 23, minute: 0)
    .durationUntil(const TimeOfDay(hour: 1, minute: 0)); // 2 hours
```

### Snapping

```dart
const TimeOfDay(hour: 9, minute: 22).roundToNearest(15); // 09:15
slot.clampTo(businessOpen, businessClose);
```

---

## Scroll controllers

`ScrollControllerX`. Every member checks `hasClients` first — reading
`controller.position` before attachment throws, and build order plus disposal
both leave you briefly detached.

```dart
controller.isAtTop;
controller.isAtBottom;
controller.isScrollable;
controller.progress;        // 0..1
controller.offsetOrZero;    // 0 rather than a crash when detached

controller.isScrollingDown; // user is revealing later items
controller.isScrollingUp;
```

Infinite scroll wants to start loading *before* the true end:

```dart
if (controller.isNearBottom(tolerance: 300)) loadNextPage();
```

Movement, all no-ops when detached:

```dart
await controller.animateToTop();
await controller.animateToBottom(duration: 200.milliseconds);
controller.jumpToTop();
controller.jumpToClamped(savedOffset); // clamped into the valid range
```

---

## Text editing controllers

`TextEditingControllerX`.

```dart
controller.isBlank;             // '' and '   ' both count
controller.isNotBlank;
controller.trimmedText;
controller.trimmedTextOrNull;   // null when blank — good for optional fields
```

Cursor management. Plain `controller.text = value` resets the selection to
offset 0, which makes the caret jump to the start mid-typing:

```dart
controller.setTextAndCursorToEnd(formatted);
controller.moveCursorToEnd();
controller.selectAll();
controller.insertAtCursor('@example.com'); // replaces an active selection
controller.clearAndReset();
```
