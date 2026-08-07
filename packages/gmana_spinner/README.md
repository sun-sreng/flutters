# gmana_spinner

Flutter loading spinner widgets for the Gmana ecosystem.

```dart
import 'package:gmana_spinner/gmana_spinner.dart';
```

`gmana_flutter` re-exports all widgets for compatibility — existing code needs no changes.

---

## Widgets at a glance

| Widget                | Style                           | `color` required |
| --------------------- | ------------------------------- | ---------------- |
| `GCircularSpinner`    | Material circular indicator     | no               |
| `GLinearSpinner`      | Material linear indicator       | no               |
| `GDotSpinner`         | Pulsing scale dots              | no               |
| `GWaveDotSpinner`     | Wave-ripple dots                | no               |
| `GBarWaveSpinner`     | Vertical bar wave               | no               |
| `GPulseSpinner`       | Expanding pulse rings           | no               |
| `GRingSpinner`        | Spinning dual arc ring          | no               |
| `GDualRingSpinner`    | Counter-rotating dual ring arcs | no               |
| `GChasingDotsSpinner` | Orbiting & scaling dual dots    | no               |
| `GFadingCubeSpinner`  | 2x2 grid of fading cubes        | no               |
| `GRippleSpinner`      | Expanding concentric ripples    | no               |
| `GOrbitSpinner`       | Satellite dots around a core    | no               |
| `GWaveSpinner`        | Circular arc + wave fill        | **yes**          |


---

## GCircularSpinner

Centered `CircularProgressIndicator` with padding.

```dart
// Defaults — purple, 4px stroke, 10px top padding
const GCircularSpinner()
```

```dart
// Themed to primary color
GCircularSpinner(
  color: Theme.of(context).colorScheme.primary,
  strokeWidth: 3.0,
  padding: EdgeInsets.zero,
)
```

| Parameter     | Type                 | Default                    |
| ------------- | -------------------- | -------------------------- |
| `color`       | `Color`              | `Colors.purple`            |
| `strokeWidth` | `double`             | `4.0`                      |
| `padding`     | `EdgeInsetsGeometry` | `EdgeInsets.only(top: 10)` |

---

## GLinearSpinner

Full-width `LinearProgressIndicator` with padding.

```dart
const GLinearSpinner()
```

```dart
GLinearSpinner(
  color: Colors.teal,
  minHeight: 6.0,
  padding: const EdgeInsets.symmetric(vertical: 8),
)
```

| Parameter   | Type                 | Default                       |
| ----------- | -------------------- | ----------------------------- |
| `color`     | `Color`              | `Colors.purple`               |
| `minHeight` | `double`             | `4.0`                         |
| `padding`   | `EdgeInsetsGeometry` | `EdgeInsets.only(bottom: 10)` |

---

## GDotSpinner

A row of dots that pulse in sequence using a scale animation. The widget is `2× size` wide and `size` tall; each dot occupies `0.5× size`.

```dart
// Defaults — 3 dots, 50×100 px, theme primary color, 1200 ms
const GDotSpinner()
```

```dart
// Custom color and count
const GDotSpinner(
  color: Colors.indigo,
  size: 40,
  dotCount: 5,
  duration: Duration(milliseconds: 800),
)
```

```dart
// Custom dot shape via itemBuilder (mutually exclusive with color)
GDotSpinner(
  size: 40,
  dotCount: 3,
  itemBuilder: (context, index) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.pink, Colors.purple]),
      shape: BoxShape.circle,
    ),
  ),
)
```

```dart
// External AnimationController — caller owns disposal
GDotSpinner(
  color: Colors.blue,
  size: 30,
  controller: _myController,
)
```

| Parameter     | Type                    | Default       |
| ------------- | ----------------------- | ------------- |
| `color`       | `Color?`                | theme primary |
| `size`        | `double`                | `50.0`        |
| `dotCount`    | `int`                   | `3`           |
| `duration`    | `Duration`              | `1200 ms`     |
| `itemBuilder` | `IndexedWidgetBuilder?` | `null`        |
| `controller`  | `AnimationController?`  | `null`        |

> `itemBuilder` and `color` are mutually exclusive — providing both throws an assertion error.

---

## GWaveDotSpinner

Dots that rise and fall in a traveling wave pattern. `size` controls both width and height.

```dart
// size is required
const GWaveDotSpinner(size: 40)
```

```dart
GWaveDotSpinner(
  size: 48,
  color: Colors.deepOrange,
  dotCount: 7,
  duration: Duration(milliseconds: 1200),
)
```

```dart
// External controller
GWaveDotSpinner(
  size: 32,
  color: Colors.blue,
  controller: _myController,
)
```

| Parameter    | Type                   | Default       |
| ------------ | ---------------------- | ------------- |
| `size`       | `double`               | **required**  |
| `color`      | `Color?`               | theme primary |
| `dotCount`   | `int`                  | `5`           |
| `duration`   | `Duration`             | `1600 ms`     |
| `controller` | `AnimationController?` | `null`        |

---

## GBarWaveSpinner

Vertical bars that scale in a wave pattern. The wave can originate from the start, end, or center.

```dart
const GBarWaveSpinner()
```

```dart
// Center-origin wave
GBarWaveSpinner(
  color: Colors.teal,
  type: GBarWaveSpinnerType.center,
  size: 48,
  itemCount: 7,
  duration: Duration(milliseconds: 1000),
)
```

```dart
// Custom bar widget (mutually exclusive with color)
GBarWaveSpinner(
  size: 48,
  itemCount: 5,
  itemBuilder: (context, index) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 1),
    decoration: BoxDecoration(
      color: Colors.primaries[index % Colors.primaries.length],
      borderRadius: BorderRadius.circular(2),
    ),
  ),
)
```

| Parameter     | Type                    | Default       |
| ------------- | ----------------------- | ------------- |
| `color`       | `Color?`                | theme primary |
| `type`        | `GBarWaveSpinnerType`   | `.start`      |
| `size`        | `double`                | `50.0`        |
| `itemCount`   | `int`                   | `5` (min 2)   |
| `duration`    | `Duration`              | `1200 ms`     |
| `itemBuilder` | `IndexedWidgetBuilder?` | `null`        |
| `controller`  | `AnimationController?`  | `null`        |

### `GBarWaveSpinnerType`

| Value     | Effect                                |
| --------- | ------------------------------------- |
| `.start`  | Wave travels left → right             |
| `.end`    | Wave travels right → left             |
| `.center` | Wave radiates from the center outward |

---

## GWaveSpinner

A circular arc spinner with an animated wave fill. Fills available space up to `size`; use a `SizedBox` to constrain it. Optionally centers a child widget inside the arc.

```dart
// Must be given bounded constraints
SizedBox(
  width: 64,
  height: 64,
  child: GWaveSpinner(color: Colors.blue),
)
```

```dart
// Custom colors and curve
SizedBox(
  width: 80,
  height: 80,
  child: GWaveSpinner(
    color: Colors.deepPurple,
    trackColor: Colors.deepPurple.withOpacity(0.2),
    waveColor: Colors.deepPurple.withOpacity(0.3),
    duration: Duration(milliseconds: 2000),
    curve: Curves.easeInOut,
  ),
)
```

```dart
// With a centered child (constrained to 70% of size)
SizedBox(
  width: 80,
  height: 80,
  child: GWaveSpinner(
    color: Colors.teal,
    child: Icon(Icons.cloud_upload, color: Colors.white),
  ),
)
```

```dart
// External controller
GWaveSpinner(
  color: Colors.orange,
  controller: _myController,
)
```

| Parameter    | Type                   | Default             |
| ------------ | ---------------------- | ------------------- |
| `color`      | `Color`                | **required**        |
| `trackColor` | `Color`                | `Color(0x68757575)` |
| `waveColor`  | `Color`                | `Color(0x68757575)` |
| `size`       | `double`               | `50.0`              |
| `duration`   | `Duration`             | `3000 ms`           |
| `curve`      | `Curve`                | `Curves.decelerate` |
| `child`      | `Widget?`              | `null`              |
| `controller` | `AnimationController?` | `null`              |

---

## GPulseSpinner

Concentric expanding and fading pulse rings loading indicator.

```dart
const GPulseSpinner(
  color: Colors.blue,
  size: 50.0,
  pulseCount: 3,
)
```

---

## GRingSpinner

Dual-ring spinning arc loading indicator.

```dart
const GRingSpinner(
  color: Colors.indigo,
  size: 40.0,
  strokeWidth: 4.0,
)
```

---

## GDualRingSpinner

Dual-ring spinner with counter-rotating arcs.

```dart
const GDualRingSpinner(
  color: Colors.blue,
  secondaryColor: Colors.orange,
  size: 40.0,
  strokeWidth: 3.5,
)
```

---

## GChasingDotsSpinner

Two orbiting dots scaling sequentially around a center.

```dart
const GChasingDotsSpinner(
  color: Colors.purple,
  size: 40.0,
)
```

---

## GFadingCubeSpinner

A 2x2 grid of fading and scaling cubes.

```dart
const GFadingCubeSpinner(
  color: Colors.teal,
  size: 40.0,
)
```

---

## GRippleSpinner

Expanding concentric ripple rings fading outward.

```dart
const GRippleSpinner(
  color: Colors.indigo,
  size: 50.0,
  rippleCount: 2,
)
```

---

## GOrbitSpinner

Revolving satellite dots orbiting around a central core.

```dart
const GOrbitSpinner(
  color: Colors.blue,
  secondaryColor: Colors.cyan,
  size: 44.0,
  satelliteCount: 3,
)
```

---

## External AnimationController


All animated widgets accept an optional `controller`. When you supply one, **you own its lifecycle** — the widget will not call `dispose()` on it.

```dart
class _MyState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose(); // your responsibility
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GDotSpinner(color: Colors.blue, controller: _ctrl),
        GBarWaveSpinner(color: Colors.blue, controller: _ctrl),
      ],
    );
  }
}
```
