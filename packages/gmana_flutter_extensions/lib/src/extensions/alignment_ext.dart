import 'package:flutter/widgets.dart';

/// Extension methods for [Alignment].
extension AlignmentX on Alignment {
  /// Returns the opposite alignment (e.g., [Alignment.topLeft] becomes [Alignment.bottomRight]).
  Alignment get opposite => Alignment(-x, -y);

  /// Returns a copy of this alignment with modified [x] coordinate.
  Alignment withX(double newX) => Alignment(newX, y);

  /// Returns a copy of this alignment with modified [y] coordinate.
  Alignment withY(double newY) => Alignment(x, newY);
}
