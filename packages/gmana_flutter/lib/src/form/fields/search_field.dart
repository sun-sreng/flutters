import 'package:gmana/utilities.dart' show Debouncer;
import 'package:material_ui/material_ui.dart';

import '../models/field_config.dart';
import '../widgets/configured_text_form_field.dart';

/// Form field widget optimized for debounced search input.
class GSearchField extends StatefulWidget {
  /// Field name.
  final String? name;

  /// Optional controller.
  final TextEditingController? controller;

  /// Initial search text.
  final String? initialValue;

  /// Label text.
  final String label;

  /// Hint text.
  final String hint;

  /// Debounce delay before invoking [onSearchChanged]. Must be positive.
  final Duration debounceDelay;

  /// Callback fired when search query changes (debounced).
  final void Function(String query)? onSearchChanged;

  /// Callback fired when user submits search.
  final void Function(String query)? onFieldSubmitted;

  /// Custom clear callback.
  final VoidCallback? onCleared;

  /// Prefix search icon.
  final IconData prefixIcon;

  /// Focus node.
  final FocusNode? focusNode;

  /// Whether the field is enabled.
  final bool? enabled;

  /// Custom decoration.
  final InputDecoration? decoration;

  /// Creates a [GSearchField].
  const GSearchField({
    super.key,
    this.name,
    this.controller,
    this.initialValue,
    this.label = 'Search',
    this.hint = 'Type to search...',
    this.debounceDelay = const Duration(milliseconds: 300),
    this.onSearchChanged,
    this.onFieldSubmitted,
    this.onCleared,
    this.prefixIcon = Icons.search,
    this.focusNode,
    this.enabled,
    this.decoration,
  }) : assert(
         debounceDelay > Duration.zero,
         'debounceDelay must be greater than zero',
       );

  @override
  State<GSearchField> createState() => _GSearchFieldState();
}

class _GSearchFieldState extends State<GSearchField> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  late Debouncer _debouncer;
  bool _hasText = false;

  @override
  Widget build(BuildContext context) {
    final suffixIcon =
        _hasText
            ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clear,
              tooltip: 'Clear',
            )
            : null;

    final config = GTextFieldConfig(
      controller: _controller,
      name: widget.name,
      label: widget.label,
      hint: widget.hint,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onFieldSubmitted: widget.onFieldSubmitted,
      prefixIcon: widget.prefixIcon,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      decoration: widget.decoration,
    );

    return GConfiguredTextFormField(config: config, suffixIcon: suffixIcon);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.removeListener(_onTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _ownsController = true;
    }

    _debouncer = Debouncer(duration: widget.debounceDelay);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant GSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.debounceDelay != widget.debounceDelay) {
      _debouncer.dispose();
      _debouncer = Debouncer(duration: widget.debounceDelay);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onCleared?.call();
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (_hasText != text.isNotEmpty) {
      setState(() {
        _hasText = text.isNotEmpty;
      });
    }

    if (widget.onSearchChanged == null) {
      _debouncer.cancel();
    } else {
      _debouncer.run(() => widget.onSearchChanged?.call(text));
    }
  }
}
