import 'package:flutter/widgets.dart';

/// Extension methods for [ValueNotifier].
extension ValueNotifierX<T> on ValueNotifier<T> {
  /// Updates the value by applying [updater] transformation function.
  void update(T Function(T current) updater) {
    value = updater(value);
  }
}

/// Extension methods for [Listenable].
extension ListenableX on Listenable {
  /// Builds a reactive [ListenableBuilder] widget for this listenable.
  Widget build(Widget Function(BuildContext context) builder) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) => builder(context),
    );
  }
}
