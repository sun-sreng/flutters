// Internal IconButton wrapper.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Reusable widget for toggling password visibility.
class VisibilityToggle extends StatefulWidget {
  final ValueChanged<bool>? onVisibilityChanged;
  final bool obscureText;

  const VisibilityToggle({
    super.key,
    this.onVisibilityChanged,
    this.obscureText = true,
  });

  @override
  State<VisibilityToggle> createState() => _VisibilityToggleState();
}

class _VisibilityToggleState extends State<VisibilityToggle> {
  late bool _obscureText = widget.obscureText;

  @override
  void didUpdateWidget(covariant VisibilityToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _obscureText ? 'Show password' : 'Hide password',
      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
          widget.onVisibilityChanged?.call(_obscureText);
        });
      },
    );
  }
}
