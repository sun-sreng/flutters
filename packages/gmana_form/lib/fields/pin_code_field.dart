import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Discrete digit box PIN / OTP code entry field widget.
class GPinCodeField extends StatefulWidget {
  /// Total length of the PIN / OTP code (default is 4).
  final int length;

  /// Callback invoked when all digits are completed.
  final void Function(String pin)? onCompleted;

  /// Callback invoked when PIN changes.
  final void Function(String pin)? onChanged;

  /// Size of each digit box.
  final double boxSize;

  /// Spacing between digit boxes.
  final double boxSpacing;

  /// Border radius of digit boxes.
  final double borderRadius;

  /// Obscure PIN entry (like password).
  final bool obscureText;

  /// Obscuring character.
  final String obscuringCharacter;

  /// Initial value.
  final String? initialValue;

  /// Whether entry is enabled.
  final bool enabled;

  /// Creates a [GPinCodeField].
  const GPinCodeField({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.boxSize = 50.0,
    this.boxSpacing = 10.0,
    this.borderRadius = 8.0,
    this.obscureText = false,
    this.obscuringCharacter = '●',
    this.initialValue,
    this.enabled = true,
  })  : assert(length > 0, 'PIN length must be > 0');

  @override
  State<GPinCodeField> createState() => _GPinCodeFieldState();
}

class _GPinCodeFieldState extends State<GPinCodeField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    final init = widget.initialValue ?? '';
    _controllers = List.generate(widget.length, (i) {
      final char = i < init.length ? init[i] : '';
      return TextEditingController(text: char);
    });
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentPin => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Paste handling
      final clean = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < clean.length ? clean[i] : '';
      }
      if (clean.length >= widget.length) {
        _focusNodes[widget.length - 1].unfocus();
      } else {
        _focusNodes[clean.length].requestFocus();
      }
    } else if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final pin = _currentPin;
    widget.onChanged?.call(pin);

    if (pin.length == widget.length) {
      widget.onCompleted?.call(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.length, (index) {
        return Container(
          width: widget.boxSize,
          height: widget.boxSize,
          margin: EdgeInsets.symmetric(horizontal: widget.boxSpacing / 2),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            obscuringCharacter: widget.obscuringCharacter,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            onChanged: (val) => _onDigitChanged(index, val),
          ),
        );
      }),
    );
  }
}
