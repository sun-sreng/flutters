import 'package:flutter/material.dart';
import 'package:gmana_flutter/spinner/spinner_wave_dot.dart';

/// A customizable elevated button with loading state support.
///
/// Example:
/// ```dart
/// GElevatedButton(
///   isLoading: true,
///   onPressed: () {},
///   text: 'Submit',
///   loadingColor: Colors.white,
///   loadingSize: 24.0,
/// )
/// ```
class GElevatedButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;
  final TextStyle? textStyle;
  final Color loadingColor;
  final double loadingSize;

  const GElevatedButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.textStyle,
    this.loadingColor = Colors.white,
    this.loadingSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child:
          isLoading
              ? SpinnerWaveDot(size: loadingSize, color: loadingColor)
              : Text(text, style: textStyle),
    );
  }
}
