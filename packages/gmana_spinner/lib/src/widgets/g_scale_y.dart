import 'package:flutter/material.dart';

/// Scales a child vertically using an animation.
class GScaleY extends AnimatedWidget {
  /// The widget to scale.
  final Widget child;

  /// Transform alignment.
  final Alignment alignment;

  /// Creates a widget that vertically scales [child] by [scaleY].
  const GScaleY({
    super.key,
    required Animation<double> scaleY,
    required this.child,
    this.alignment = Alignment.center,
  }) : super(listenable: scaleY);

  /// The underlying scale animation driving the vertical transform.
  Animation<double> get scale => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.diagonal3Values(1.0, scale.value, 1.0),
      alignment: alignment,
      child: child,
    );
  }
}
