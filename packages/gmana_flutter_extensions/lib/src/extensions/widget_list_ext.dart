import 'package:flutter/material.dart';

/// Turns a `List<Widget>` into a laid-out widget without the usual
/// `Column(children: ...)` ceremony, and inserts separators between items.
extension WidgetListX on List<Widget> {
  /// Inserts [separator] between every pair of children.
  ///
  /// Unlike `ListView.separated` this is a plain list transform, so it works
  /// anywhere children are accepted.
  ///
  /// ```dart
  /// [a, b, c].separatedBy(const Divider()); // [a, div, b, div, c]
  /// ```
  List<Widget> separatedBy(Widget separator) {
    if (length < 2) return List<Widget>.of(this);

    return [
      for (var i = 0; i < length; i++) ...[if (i > 0) separator, this[i]],
    ];
  }

  /// Inserts a fixed vertical gap between every pair of children.
  List<Widget> separatedByHeight(double height) =>
      separatedBy(SizedBox(height: height));

  /// Inserts a fixed horizontal gap between every pair of children.
  List<Widget> separatedByWidth(double width) =>
      separatedBy(SizedBox(width: width));

  /// Wraps these widgets in a [Column].
  Widget toColumn({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double spacing = 0.0,
    Key? key,
  }) => Column(
    key: key,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    mainAxisSize: mainAxisSize,
    spacing: spacing,
    children: this,
  );

  /// Wraps these widgets in a [Row].
  Widget toRow({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double spacing = 0.0,
    Key? key,
  }) => Row(
    key: key,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    mainAxisSize: mainAxisSize,
    spacing: spacing,
    children: this,
  );

  /// Wraps these widgets in a [Stack].
  Widget toStack({
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
    Key? key,
  }) => Stack(
    key: key,
    alignment: alignment,
    fit: fit,
    clipBehavior: clipBehavior,
    children: this,
  );

  /// Wraps these widgets in a [Wrap].
  Widget toWrap({
    double spacing = 0.0,
    double runSpacing = 0.0,
    WrapAlignment alignment = WrapAlignment.start,
    Axis direction = Axis.horizontal,
    Key? key,
  }) => Wrap(
    key: key,
    spacing: spacing,
    runSpacing: runSpacing,
    alignment: alignment,
    direction: direction,
    children: this,
  );

  /// Wraps these widgets in a scrollable [ListView].
  Widget toListView({
    Axis scrollDirection = Axis.vertical,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    ScrollController? controller,
    Key? key,
  }) => ListView(
    key: key,
    scrollDirection: scrollDirection,
    padding: padding,
    shrinkWrap: shrinkWrap,
    physics: physics,
    controller: controller,
    children: this,
  );
}
