import 'package:flutter/material.dart';

/// Breakpoint constants for responsive design
class ResponsiveBreakpoints {
  // Breakpoint values
  static const double mobile = 600;
  static const double tablet = 1024;
  
  // Max content width for desktop
  static const double maxContentWidth = 1200;
  static const double maxFormWidth = 800;
  static const double maxCardWidth = 400;
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Extension on BuildContext for responsive helpers
extension ResponsiveContext on BuildContext {
  /// Get the current screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get the current screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Check if the current device is mobile
  bool get isMobile => screenWidth < ResponsiveBreakpoints.mobile;
  
  /// Check if the current device is tablet
  bool get isTablet => 
      screenWidth >= ResponsiveBreakpoints.mobile && 
      screenWidth < ResponsiveBreakpoints.tablet;
  
  /// Check if the current device is desktop
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.tablet;
  
  /// Get the current device type
  DeviceType get deviceType {
    if (isMobile) return DeviceType.mobile;
    if (isTablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  /// Get a responsive value based on device type
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}
