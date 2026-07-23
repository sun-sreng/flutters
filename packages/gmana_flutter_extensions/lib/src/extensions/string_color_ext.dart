// String -> Color extension.
// ignore_for_file: public_member_api_docs

import 'dart:ui';

import '../services/color_service.dart';
import 'color_ext.dart';

extension StringColorExtension on String {
  /// Converts a hex string like `#F50`, `#FF5500`, or `CCFF5500` to a [Color].
  Color toColor() {
    final color = ColorService.tryParseHex(this);
    if (color == null) {
      throw FormatException(
        'Expected #RGB, #RRGGBB, or #AARRGGBB color text.',
        this,
      );
    }

    return color;
  }

  /// Converts a hex string to a [Color] with the specified opacity.
  Color toColorWithOpacity(double opacity) =>
      toColor().withAlphaOpacity(opacity);
}
