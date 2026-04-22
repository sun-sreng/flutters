import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  double get bottomSafeArea => safeAreaPadding.bottom;
  bool get canPop => navigator.canPop();
  ColorScheme get colorScheme => theme.colorScheme;

  double get devicePixelRatio => mediaQuery.devicePixelRatio;
  bool get hasFocus => FocusScope.of(this).hasFocus;
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  bool get isPortrait => !isLandscape;
  // ── MediaQuery ─────────────────────────────────────────────────────────

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  // ── Navigation ─────────────────────────────────────────────────────────

  NavigatorState get navigator => Navigator.of(this);

  /// Safe area padding (notch, home indicator, etc.).
  EdgeInsets get safeAreaPadding => mediaQuery.padding;
  // ── Scaffold / Snackbar / Dialog ───────────────────────────────────────

  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
  double get screenHeight => screenSize.height;

  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get textScaleFactor => mediaQuery.textScaler.scale(1.0);
  TextTheme get textTheme => theme.textTheme;

  // ── Theme ──────────────────────────────────────────────────────────────

  ThemeData get theme => Theme.of(this);

  double get topSafeArea => safeAreaPadding.top;

  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  void hideSnackBar() => scaffoldMessenger.hideCurrentSnackBar();

  void pop<T>([T? result]) {
    if (navigator.canPop()) navigator.pop(result);
  }

  /// Pops all routes down to the root.
  void popToRoot() => navigator.popUntil((route) => route.isFirst);

  /// Pops until [predicate] returns true, or to first route if none match.
  void popUntil(RoutePredicate predicate) => navigator.popUntil(predicate);

  Future<T?> push<T>(Widget widget) =>
      navigator.push<T>(MaterialPageRoute<T>(builder: (_) => widget));

  /// Clears the entire stack and pushes [widget] as the new root.
  Future<T?> pushAndRemoveUntil<T>(
    Widget widget, {
    RoutePredicate? predicate,
  }) => navigator.pushAndRemoveUntil<T>(
    MaterialPageRoute<T>(builder: (_) => widget),
    predicate ?? (_) => false,
  );

  Future<T?> pushReplacement<T>(Widget widget) =>
      navigator.pushReplacement(MaterialPageRoute<T>(builder: (_) => widget));

  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);

  Future<T?> showAppBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) => showModalBottomSheet<T>(
    context: this,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    shape:
        shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
    builder: (_) => child,
  );

  // ── Dialog shortcuts ───────────────────────────────────────────────────

  Future<T?> showAppDialog<T>({required Widget dialog}) =>
      showDialog<T>(context: this, builder: (_) => dialog);

  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await showAppDialog<bool>(
      dialog: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => pop(false), child: Text(cancelLabel)),
          TextButton(
            onPressed: () => pop(true),
            style:
                destructive
                    ? TextButton.styleFrom(foregroundColor: colorScheme.error)
                    : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void showErrorSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) => showSnackBar(
    message: message,
    textColor: colorScheme.onError,
    backgroundColor: colorScheme.error,
    duration: duration,
    action: action,
  );

  void showSnackBar({
    required String message,
    Color? textColor,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    final cs = colorScheme;
    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: textColor ?? cs.onInverseSurface),
          ),
          backgroundColor: backgroundColor ?? cs.inverseSurface,
          duration: duration,
          action: action,
          behavior: behavior,
        ),
      );
  }

  void showSuccessSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) => showSnackBar(
    message: message,
    textColor: colorScheme.onPrimary,
    backgroundColor: colorScheme.primary,
    duration: duration,
    action: action,
  );
  void showWarningSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) => showSnackBar(
    message: message,
    textColor: colorScheme.onTertiary,
    backgroundColor: colorScheme.tertiary,
    duration: duration,
    action: action,
  );
  // ── Focus ──────────────────────────────────────────────────────────────

  void unfocus() => FocusScope.of(this).unfocus();
}
