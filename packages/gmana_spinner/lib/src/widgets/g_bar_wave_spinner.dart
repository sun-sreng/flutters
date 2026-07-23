import 'dart:async';

import 'package:flutter/material.dart';

import '../animation/delayed_animation_tween.dart';
import 'g_scale_y.dart';

/// A bar-style wave spinner.
///
/// When [itemBuilder] is provided, [color] is ignored.
class GBarWaveSpinner extends StatefulWidget {
  /// Bar color. Defaults to the active theme primary color.
  ///
  /// Ignored when [itemBuilder] is provided.
  final Color? color;

  /// Wave origin.
  final GBarWaveSpinnerType type;

  /// Number of bars.
  final int itemCount;

  /// Height of the spinner.
  final double size;

  /// Optional builder for custom bar widgets.
  final IndexedWidgetBuilder? itemBuilder;

  /// Duration for one full animation cycle.
  final Duration duration;

  /// Optional external controller.
  ///
  /// When provided, the caller owns disposal **and** playback. The widget will
  /// use it as-is and will not call `repeat()`, `stop()`, or `dispose()` on it.
  final AnimationController? controller;

  /// Creates a bar-wave spinner.
  const GBarWaveSpinner({
    super.key,
    this.color,
    this.type = GBarWaveSpinnerType.start,
    this.size = 50.0,
    this.itemBuilder,
    this.itemCount = 5,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  }) : assert(itemCount >= 2, 'itemCount cannot be less than 2.'),
       assert(size > 0, 'size must be greater than zero.');

  @override
  State<GBarWaveSpinner> createState() => _GBarWaveSpinnerState();
}

/// Wave animation origin for [GBarWaveSpinner].
enum GBarWaveSpinnerType {
  /// Wave starts from the leading edge.
  start,

  /// Wave starts from the trailing edge.
  end,

  /// Wave starts from the center.
  center,
}

class _GBarWaveSpinnerState extends State<GBarWaveSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = AnimationController(vsync: this, duration: widget.duration);
      _ownsController = true;
      unawaited(_controller.repeat());
    }
  }

  @override
  void didUpdateWidget(covariant GBarWaveSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      _initController();
    } else if (_ownsController && widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ownsController) return;
    if (!TickerMode.valuesOf(context).enabled) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<double> bars = getAnimationDelay(widget.itemCount);
    return Center(
      child: SizedBox.fromSize(
        size: Size(widget.size * 1.25, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(bars.length, (i) {
            return GScaleY(
              scaleY: DelayedAnimationTween(
                begin: .4,
                end: 1.0,
                delay: bars[i],
              ).animate(_controller),
              child: SizedBox.fromSize(
                size: Size(widget.size / widget.itemCount, widget.size),
                child: _itemBuilder(i),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<double> getAnimationDelay(int itemCount) {
    switch (widget.type) {
      case GBarWaveSpinnerType.start:
        return _startAnimationDelay(itemCount);
      case GBarWaveSpinnerType.end:
        return _endAnimationDelay(itemCount);
      case GBarWaveSpinnerType.center:
        return _centerAnimationDelay(itemCount);
    }
  }

  List<double> _centerAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 + (index * 0.2) + 0.2,
      ).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 + (index * 0.2) + 0.2,
      ),
    ];
  }

  List<double> _endAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 + (index * 0.1) + 0.1,
      ).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 - (index * 0.1) - (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  Widget _itemBuilder(int index) =>
      widget.itemBuilder != null
          ? widget.itemBuilder!(context, index)
          : DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color ?? Theme.of(context).colorScheme.primary,
            ),
          );

  List<double> _startAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 - (index * 0.1) - 0.1,
      ).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 + (index * 0.1) + (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }
}
