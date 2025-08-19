import 'package:flutter/material.dart';

/// Comprehensive responsive design constants and breakpoints
class ResponsiveConstants {
  // Prevent instantiation
  ResponsiveConstants._();

  /// Screen breakpoints based on Material Design guidelines
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 905.0;
  static const double desktopBreakpoint = 1240.0;
  static const double largeDesktopBreakpoint = 1440.0;

  /// Compact breakpoints for fine-grained control
  static const double compactWidth = 600.0;
  static const double mediumWidth = 840.0;
  static const double expandedWidth = 1200.0;

  /// Responsive padding values
  static const EdgeInsets mobilePadding = EdgeInsets.all(16.0);
  static const EdgeInsets tabletPadding = EdgeInsets.all(24.0);
  static const EdgeInsets desktopPadding = EdgeInsets.all(32.0);

  /// Responsive margins
  static const EdgeInsets mobileMargin = EdgeInsets.all(8.0);
  static const EdgeInsets tabletMargin = EdgeInsets.all(16.0);
  static const EdgeInsets desktopMargin = EdgeInsets.all(24.0);

  /// Grid columns by device type
  static const int mobileColumns = 1;
  static const int tabletPortraitColumns = 2;
  static const int tabletLandscapeColumns = 3;
  static const int desktopColumns = 4;

  /// Content width constraints
  static const double maxContentWidth = 1200.0;
  static const double maxCardWidth = 400.0;
  static const double minCardWidth = 280.0;

  /// Touch target sizes (Material Design guidelines)
  static const double minTouchTarget = 48.0;
  static const double largeTouchTarget = 56.0;

  /// Typography scale multipliers
  static const double mobileTypographyScale = 0.9;
  static const double tabletTypographyScale = 1.0;
  static const double desktopTypographyScale = 1.1;

  /// Icon sizes by device type
  static const double mobileIconSize = 20.0;
  static const double tabletIconSize = 24.0;
  static const double desktopIconSize = 28.0;

  /// Navigation dimensions
  static const double bottomNavHeight = 80.0;
  static const double navRailWidth = 72.0;
  static const double navDrawerWidth = 256.0;

  /// App bar heights
  static const double mobileAppBarHeight = 56.0;
  static const double tabletAppBarHeight = 64.0;
  static const double desktopAppBarHeight = 72.0;

  /// Card dimensions
  static const double mobileCardRadius = 8.0;
  static const double tabletCardRadius = 12.0;
  static const double desktopCardRadius = 16.0;

  /// Animation durations by device
  static const Duration mobileAnimationDuration = Duration(milliseconds: 200);
  static const Duration tabletAnimationDuration = Duration(milliseconds: 250);
  static const Duration desktopAnimationDuration = Duration(milliseconds: 300);
}

/// Device type enumeration
enum ResponsiveDeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Layout size class for adaptive UI
enum LayoutSizeClass {
  compact,
  medium,
  expanded,
}

/// Orientation-aware device type
enum AdaptiveDeviceType {
  mobilePortrait,
  mobileLandscape,
  tabletPortrait,
  tabletLandscape,
  desktop,
  largeDesktop,
}

/// Screen density category
enum ScreenDensity {
  low,    // < 160 dpi
  medium, // 160-240 dpi
  high,   // 240-320 dpi
  xHigh,  // 320-480 dpi
  xxHigh, // 480-640 dpi
  xxxHigh,// > 640 dpi
}

/// Responsive configuration
class ResponsiveConfig {
  final ResponsiveDeviceType deviceType;
  final LayoutSizeClass sizeClass;
  final AdaptiveDeviceType adaptiveType;
  final ScreenDensity density;
  final Size screenSize;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double fontScale;
  final double iconScale;
  final int gridColumns;
  final Duration animationDuration;

  const ResponsiveConfig({
    required this.deviceType,
    required this.sizeClass,
    required this.adaptiveType,
    required this.density,
    required this.screenSize,
    required this.padding,
    required this.margin,
    required this.fontScale,
    required this.iconScale,
    required this.gridColumns,
    required this.animationDuration,
  });

  /// Check if device is mobile
  bool get isMobile => deviceType == ResponsiveDeviceType.mobile;

  /// Check if device is tablet
  bool get isTablet => deviceType == ResponsiveDeviceType.tablet;

  /// Check if device is desktop
  bool get isDesktop => 
      deviceType == ResponsiveDeviceType.desktop || 
      deviceType == ResponsiveDeviceType.largeDesktop;

  /// Check if device is in portrait orientation
  bool get isPortrait => screenSize.height > screenSize.width;

  /// Check if device is in landscape orientation
  bool get isLandscape => screenSize.width > screenSize.height;

  /// Check if device supports gestures
  bool get supportsGestures => isMobile || isTablet;

  /// Check if device should use dense layout
  bool get useDenseLayout => sizeClass == LayoutSizeClass.compact;

  /// Get appropriate icon size
  double get iconSize {
    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return ResponsiveConstants.mobileIconSize * iconScale;
      case ResponsiveDeviceType.tablet:
        return ResponsiveConstants.tabletIconSize * iconScale;
      case ResponsiveDeviceType.desktop:
      case ResponsiveDeviceType.largeDesktop:
        return ResponsiveConstants.desktopIconSize * iconScale;
    }
  }

  /// Get appropriate app bar height
  double get appBarHeight {
    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return ResponsiveConstants.mobileAppBarHeight;
      case ResponsiveDeviceType.tablet:
        return ResponsiveConstants.tabletAppBarHeight;
      case ResponsiveDeviceType.desktop:
      case ResponsiveDeviceType.largeDesktop:
        return ResponsiveConstants.desktopAppBarHeight;
    }
  }

  /// Get appropriate card border radius
  double get cardRadius {
    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return ResponsiveConstants.mobileCardRadius;
      case ResponsiveDeviceType.tablet:
        return ResponsiveConstants.tabletCardRadius;
      case ResponsiveDeviceType.desktop:
      case ResponsiveDeviceType.largeDesktop:
        return ResponsiveConstants.desktopCardRadius;
    }
  }
}