import 'dart:async';

import 'package:flutter/widgets.dart';

/// Owns, or borrows, the [AnimationController] that drives a spinner.
///
/// A spinner either receives a controller from its widget or creates a
/// looping one of its own. Only a controller created here is started, paused
/// with [TickerMode], retimed, and disposed; a borrowed one is left entirely to
/// its owner.
mixin SpinnerControllerMixin<W extends StatefulWidget>
    on SingleTickerProviderStateMixin<W> {
  late AnimationController _controller;
  bool _ownsController = false;

  /// The controller driving the animation.
  AnimationController get controller => _controller;

  /// The controller supplied by [widget], or `null` to create one.
  AnimationController? controllerOf(W widget);

  /// How long one loop lasts when the controller is created here.
  Duration durationOf(W widget);

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final supplied = controllerOf(widget);
    if (supplied != null) {
      _controller = supplied;
      _ownsController = false;
    } else {
      _controller = AnimationController(
        vsync: this,
        duration: durationOf(widget),
      );
      _ownsController = true;
      unawaited(_controller.repeat());
    }
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controllerOf(widget) != controllerOf(oldWidget)) {
      if (_ownsController) _controller.dispose();
      _initController();
    } else if (_ownsController && durationOf(widget) != durationOf(oldWidget)) {
      _controller.duration = durationOf(widget);
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
}
