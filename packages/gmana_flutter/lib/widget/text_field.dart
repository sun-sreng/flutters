import 'package:flutter/material.dart';

/// A theme-aware text field widget supporting clear button, obscure password toggle, and prefix/suffix icons.
class GTextField extends StatefulWidget {
  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Label text displayed above or inside the field.
  final String? label;

  /// Hint text displayed when empty.
  final String? hint;

  /// Error text displayed beneath the field.
  final String? errorText;

  /// Whether to obscure text input (e.g. for passwords).
  final bool obscureText;

  /// Whether to add an interactive password visibility toggle button.
  final bool enablePasswordToggle;

  /// Whether to add a clear button when text is non-empty.
  final bool enableClearButton;

  /// Leading prefix widget or icon.
  final Widget? prefixIcon;

  /// Trailing suffix widget or icon.
  final Widget? suffixIcon;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when submitted by user action.
  final ValueChanged<String>? onSubmitted;

  /// Input keyboard type.
  final TextInputType? keyboardType;

  /// Input action button type.
  final TextInputAction? textInputAction;

  /// Whether the field is enabled for user interaction.
  final bool enabled;

  /// Maximum visible lines (defaults to 1).
  final int? maxLines;

  /// Creates a styled [GTextField].
  const GTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.enablePasswordToggle = false,
    this.enableClearButton = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  State<GTextField> createState() => _GTextFieldState();
}

class _GTextFieldState extends State<GTextField> {
  late final TextEditingController _effectiveController;
  late bool _obscured;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _obscured = widget.obscureText || widget.enablePasswordToggle;
    _hasText = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_onTextChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    } else {
      _effectiveController.removeListener(_onTextChange);
    }
    super.dispose();
  }

  void _onTextChange() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  Widget? _buildSuffixIcon() {
    if (widget.enablePasswordToggle) {
      return IconButton(
        icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    if (widget.enableClearButton && _hasText && widget.enabled) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _effectiveController.clear();
          widget.onChanged?.call('');
        },
      );
    }

    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _effectiveController,
      obscureText: widget.enablePasswordToggle ? _obscured : widget.obscureText,
      enabled: widget.enabled,
      maxLines: (widget.obscureText || widget.enablePasswordToggle) ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
