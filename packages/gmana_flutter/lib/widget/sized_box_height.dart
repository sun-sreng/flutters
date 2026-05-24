import 'package:flutter/material.dart';
import '../design_system/spacing.dart';

/// A widget that adds vertical spacing using a SizedBox with a specified height.
class SizedBoxHeight extends StatelessWidget {
  /// The height of the SizedBox, defined by [GSpacing].
  final double spacing;

  /// Creates a SizedBox with the specified [spacing] height.
  const SizedBoxHeight({super.key, this.spacing = GSpacing.md});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: spacing);
  }
}
