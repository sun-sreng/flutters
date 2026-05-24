// BuildContext / BoxConstraints extension getters — method names ARE the doc.
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Breakpoint {
  mobile,
  tablet,
  desktop,
  widescreen;

  /// True for desktop and above.
  bool get isAtLeastDesktop => index >= Breakpoint.desktop.index;

  /// True for tablet and above.
  bool get isAtLeastTablet => index >= Breakpoint.tablet.index;

  bool get isDesktop => this == Breakpoint.desktop || this == Breakpoint.widescreen;

  bool get isMobile => this == Breakpoint.mobile;

  bool get isTablet => this == Breakpoint.tablet;

  bool get isWidescreen => this == Breakpoint.widescreen;

  T maybeWhen<T>({
    T Function()? mobile,
    T Function()? tablet,
    T Function()? desktop,
    T Function()? widescreen,
    required T Function() orElse,
  }) => switch (this) {
    Breakpoint.mobile => (mobile ?? orElse)(),
    Breakpoint.tablet => (tablet ?? orElse)(),
    Breakpoint.desktop => (desktop ?? orElse)(),
    Breakpoint.widescreen => (widescreen ?? orElse)(),
  };

  T when<T>({
    required T Function() mobile,
    required T Function() tablet,
    required T Function() desktop,
    T Function()? widescreen,
  }) => switch (this) {
    Breakpoint.mobile => mobile(),
    Breakpoint.tablet => tablet(),
    Breakpoint.desktop => desktop(),
    Breakpoint.widescreen => widescreen != null ? widescreen() : desktop(),
  };
}

abstract final class Breakpoints {
  static const double mobile = 0;
  static const double tablet = 730;
  static const double desktop = 1200;
  static const double widescreen = 1600;
}

extension BreakpointUtils on BoxConstraints {
  Breakpoint get breakpoint => switch (maxWidth) {
    < Breakpoints.tablet => Breakpoint.mobile,
    < Breakpoints.desktop => Breakpoint.tablet,
    < Breakpoints.widescreen => Breakpoint.desktop,
    _ => Breakpoint.widescreen,
  };

  bool get isAtLeastDesktop => maxWidth >= Breakpoints.desktop;

  bool get isAtLeastTablet => maxWidth >= Breakpoints.tablet;

  bool get isDesktop => maxWidth >= Breakpoints.desktop && maxWidth < Breakpoints.widescreen;

  bool get isMobile => maxWidth < Breakpoints.tablet;

  bool get isTablet => maxWidth >= Breakpoints.tablet && maxWidth < Breakpoints.desktop;

  /// True when both axes are tightly constrained.
  bool get isTight => minWidth == maxWidth && minHeight == maxHeight;

  /// True when height is unbounded.
  bool get isUnboundedHeight => maxHeight == double.infinity;

  /// True when width is unbounded.
  bool get isUnboundedWidth => maxWidth == double.infinity;

  bool get isWidescreen => maxWidth >= Breakpoints.widescreen;

  /// Returns the largest tight [Size] that fits within these constraints.
  /// May contain [double.infinity] when an axis is unbounded.
  Size get largestSize => Size(maxWidth, maxHeight);

  /// Returns the smallest tight [Size] that satisfies these constraints.
  Size get smallestSize => Size(minWidth, minHeight);

  /// Subtracts [insets] from the max dimensions, clamping to stay within [minWidth]/[minHeight].
  BoxConstraints deflate(EdgeInsets insets) => copyWith(
    maxWidth: (maxWidth - insets.horizontal).clamp(minWidth, double.infinity),
    maxHeight: (maxHeight - insets.vertical).clamp(minHeight, double.infinity),
  );

  /// Resolves a value per breakpoint, falling back from larger tiers to mobile.
  T resolve<T>({required T mobile, T? tablet, T? desktop, T? widescreen}) {
    return switch (breakpoint) {
      Breakpoint.widescreen => widescreen ?? desktop ?? tablet ?? mobile,
      Breakpoint.desktop => desktop ?? tablet ?? mobile,
      Breakpoint.tablet => tablet ?? mobile,
      Breakpoint.mobile => mobile,
    };
  }

  /// Clamps constraints to [size], respecting existing min/max bounds.
  BoxConstraints tightenMaxSize(Size? size) {
    if (size == null) return this;

    return copyWith(
      maxWidth: clampDouble(size.width, minWidth, maxWidth),
      maxHeight: clampDouble(size.height, minHeight, maxHeight),
    );
  }
}

extension ResponsiveContext on BuildContext {
  Breakpoint get breakpoint => switch (MediaQuery.sizeOf(this).width) {
    < Breakpoints.tablet => Breakpoint.mobile,
    < Breakpoints.desktop => Breakpoint.tablet,
    < Breakpoints.widescreen => Breakpoint.desktop,
    _ => Breakpoint.widescreen,
  };

  bool get isAtLeastDesktop => breakpoint.isAtLeastDesktop;

  bool get isAtLeastTablet => breakpoint.isAtLeastTablet;

  bool get isDesktop => breakpoint.isDesktop;

  bool get isMobile => breakpoint.isMobile;

  bool get isTablet => breakpoint.isTablet;

  bool get isWidescreen => breakpoint.isWidescreen;

  /// Shorthand for breakpoint-driven value resolution.
  T responsive<T>({required T mobile, T? tablet, T? desktop, T? widescreen}) => switch (breakpoint) {
    Breakpoint.widescreen => widescreen ?? desktop ?? tablet ?? mobile,
    Breakpoint.desktop => desktop ?? tablet ?? mobile,
    Breakpoint.tablet => tablet ?? mobile,
    Breakpoint.mobile => mobile,
  };
}