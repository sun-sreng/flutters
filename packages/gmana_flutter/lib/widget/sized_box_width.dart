import 'package:flutter/material.dart';
import '../design_system/spacing.dart';

/// A widget that adds horizontal spacing using a SizedBox with a specified width.
class SizedBoxWidth extends StatelessWidget {
  /// The width of the SizedBox, defined by [GSpacing].
  final double spacing;

  /// Creates a SizedBox with the specified [spacing] width.
  const SizedBoxWidth({super.key, this.spacing = GSpacing.md});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: spacing);
  }
}
