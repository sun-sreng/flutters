import 'package:flutter/widgets.dart';

/// Extension methods for [FocusNode].
extension FocusNodeX on FocusNode {
  /// Toggles focus state: requests focus if unfocused, or unfocuses if focused.
  void toggleFocus() {
    if (hasFocus) {
      unfocus();
    } else {
      requestFocus();
    }
  }

  /// Requests focus on this node and selects all text in [controller].
  void selectAll(TextEditingController controller) {
    requestFocus();
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }
}
