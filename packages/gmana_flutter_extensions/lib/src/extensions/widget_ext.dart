import 'package:flutter/material.dart';

/// Ergonomic layout and composition extension methods on [Widget].
extension WidgetX on Widget {
  /// Wraps this widget in a [Padding] widget with uniform padding.
  Widget paddingAll(double value) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  /// Wraps this widget in a [Padding] widget with symmetric padding.
  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Wraps this widget in a [Padding] widget with specific edge padding.
  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Wraps this widget in a [Center] widget.
  Widget get centered => Center(child: this);

  /// Wraps this widget in an [Expanded] widget with [flex].
  Widget expanded([int flex = 1]) => Expanded(flex: flex, child: this);

  /// Wraps this widget in a [Flexible] widget with [flex] and [fit].
  Widget flexible([int flex = 1, FlexFit fit = FlexFit.loose]) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Wraps this widget in a [FittedBox] widget with [fit].
  Widget fitted([BoxFit fit = BoxFit.contain]) {
    return FittedBox(fit: fit, child: this);
  }

  /// Wraps this widget in a [ClipRRect] widget with rounded corners.
  Widget clipped([BorderRadius? radius]) {
    return ClipRRect(borderRadius: radius ?? BorderRadius.zero, child: this);
  }

  /// Wraps this widget in a [GestureDetector] with [onTap] callback.
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  // --- Sizing and constraints ---

  /// Wraps this widget in a [SizedBox] with the given dimensions.
  Widget sized({double? width, double? height}) =>
      SizedBox(width: width, height: height, child: this);

  /// Wraps this widget in a square [SizedBox] of [side].
  Widget squared(double side) =>
      SizedBox(width: side, height: side, child: this);

  /// Wraps this widget in a [ConstrainedBox].
  Widget constrained({
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
  }) => ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    ),
    child: this,
  );

  /// Wraps this widget in an [AspectRatio].
  Widget aspectRatio(double ratio) =>
      AspectRatio(aspectRatio: ratio, child: this);

  // --- Positioning ---

  /// Wraps this widget in an [Align].
  Widget aligned([AlignmentGeometry alignment = Alignment.center]) =>
      Align(alignment: alignment, child: this);

  /// Wraps this widget in a [Positioned], for use inside a [Stack].
  Widget positioned({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) => Positioned(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    width: width,
    height: height,
    child: this,
  );

  /// Wraps this widget in a [SafeArea].
  Widget get safeArea => SafeArea(child: this);

  // --- Painting ---

  /// Wraps this widget in an [Opacity].
  Widget opacity(double value) {
    if (value.isNaN || value < 0 || value > 1) {
      throw ArgumentError.value(value, 'value', 'must be between 0 and 1');
    }
    return Opacity(opacity: value, child: this);
  }

  /// Wraps this widget in a [DecoratedBox].
  Widget decorated(Decoration decoration) =>
      DecoratedBox(decoration: decoration, child: this);

  /// Paints [color] behind this widget.
  Widget background(Color color) => ColoredBox(color: color, child: this);

  /// Wraps this widget in a [RotatedBox] of [quarterTurns].
  Widget rotated(int quarterTurns) =>
      RotatedBox(quarterTurns: quarterTurns, child: this);

  /// Wraps this widget in a [Transform.scale].
  Widget scaled(double scale) => Transform.scale(scale: scale, child: this);

  // --- Visibility and input ---

  /// Shows this widget when [isVisible], otherwise [replacement].
  ///
  /// The default replacement takes no space, unlike `Opacity(opacity: 0)`
  /// which still lays out and still absorbs hit tests.
  Widget visible(
    // ignore: avoid_positional_boolean_parameters
    bool isVisible, {
    Widget replacement = const SizedBox.shrink(),
  }) => isVisible ? this : replacement;

  /// Wraps this widget in an [IgnorePointer].
  Widget ignorePointer({bool ignoring = true}) =>
      IgnorePointer(ignoring: ignoring, child: this);

  /// Wraps this widget in an [AbsorbPointer].
  Widget absorbPointer({bool absorbing = true}) =>
      AbsorbPointer(absorbing: absorbing, child: this);

  /// Wraps this widget in an [InkWell], which paints a ripple. Prefer this
  /// over [onTap] inside a [Material] surface.
  Widget inkWell({
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
  }) => InkWell(
    onTap: onTap,
    onLongPress: onLongPress,
    borderRadius: borderRadius,
    child: this,
  );

  /// Wraps this widget in a [Tooltip].
  Widget tooltip(String message) => Tooltip(message: message, child: this);

  /// Wraps this widget in a [Hero].
  Widget hero(Object tag) => Hero(tag: tag, child: this);

  // --- Slivers ---

  /// Adapts this box widget for use inside a [CustomScrollView].
  Widget get sliverBox => SliverToBoxAdapter(child: this);
}
