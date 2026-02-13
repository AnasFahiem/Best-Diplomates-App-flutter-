import 'package:flutter/material.dart';
import '../constants/responsive_constants.dart';

/// Utility class for responsive sizing and layout helpers
class ResponsiveUtils {
  /// Get responsive width value
  static double width(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return context.responsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive height value
  static double height(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return context.responsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    if (context.isDesktop) {
      return baseSize * 1.1; // 10% larger on desktop
    } else if (context.isTablet) {
      return baseSize * 1.05; // 5% larger on tablet
    }
    return baseSize;
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final value = context.responsiveValue(
      mobile: mobile ?? 16,
      tablet: tablet ?? 24,
      desktop: desktop ?? 32,
    );
    return EdgeInsets.all(value);
  }

  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final value = context.responsiveValue(
      mobile: mobile ?? 16,
      tablet: tablet ?? 24,
      desktop: desktop ?? 32,
    );
    return EdgeInsets.symmetric(horizontal: value);
  }

  /// Get responsive vertical padding
  static EdgeInsets verticalPadding(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final value = context.responsiveValue(
      mobile: mobile ?? 16,
      tablet: tablet ?? 24,
      desktop: desktop ?? 32,
    );
    return EdgeInsets.symmetric(vertical: value);
  }

  /// Get optimal number of columns for grid layouts
  static int getGridColumns(BuildContext context) {
    if (context.isDesktop) return 3;
    if (context.isTablet) return 2;
    return 1;
  }

  /// Get responsive spacing value
  static double spacing(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return context.responsiveValue(
      mobile: mobile ?? 16,
      tablet: tablet ?? 20,
      desktop: desktop ?? 24,
    );
  }

  /// Get responsive border radius
  static double borderRadius(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return context.responsiveValue(
      mobile: mobile ?? 12,
      tablet: tablet ?? 14,
      desktop: desktop ?? 16,
    );
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return context.responsiveValue(
      mobile: mobile ?? 24,
      tablet: tablet ?? 28,
      desktop: desktop ?? 32,
    );
  }
}
