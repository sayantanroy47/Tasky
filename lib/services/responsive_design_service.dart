import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for managing responsive design and UX enhancements
class ResponsiveDesignService {
  /// Get device type based on screen width
  DeviceType getDeviceType(double width) {
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get screen size category
  ScreenSize getScreenSize(Size screenSize) {
    final width = screenSize.width;
    final height = screenSize.height;

    if (width < 360 || height < 640) {
      return ScreenSize.small;
    } else if (width < 768 || height < 1024) {
      return ScreenSize.medium;
    } else if (width < 1440 || height < 900) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }

  /// Get responsive padding based on screen size
  EdgeInsets getResponsivePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.small:
        return const EdgeInsets.all(12);
      case ScreenSize.medium:
        return const EdgeInsets.all(16);
      case ScreenSize.large:
        return const EdgeInsets.all(20);
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(24);
    }
  }

  /// Get responsive margin based on screen size
  EdgeInsets getResponsiveMargin(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.small:
        return const EdgeInsets.all(8);
      case ScreenSize.medium:
        return const EdgeInsets.all(12);
      case ScreenSize.large:
        return const EdgeInsets.all(16);
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(20);
    }
  }

  /// Get responsive font size multiplier
  double getFontSizeMultiplier(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.small:
        return 0.9;
      case ScreenSize.medium:
        return 1.0;
      case ScreenSize.large:
        return 1.1;
      case ScreenSize.extraLarge:
        return 1.2;
    }
  }

  /// Get responsive icon size
  double getResponsiveIconSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.small:
        return 20;
      case ScreenSize.medium:
        return 24;
      case ScreenSize.large:
        return 28;
      case ScreenSize.extraLarge:
        return 32;
    }
  }

  /// Get responsive button height
  double getResponsiveButtonHeight(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.small:
        return 44;
      case ScreenSize.medium:
        return 48;
      case ScreenSize.large:
        return 52;
      case ScreenSize.extraLarge:
        return 56;
    }
  }

  /// Get responsive grid columns
  int getResponsiveGridColumns(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  /// Get responsive card width
  double getResponsiveCardWidth(DeviceType deviceType, double screenWidth) {
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth - 32; // Full width with padding
      case DeviceType.tablet:
        return (screenWidth - 48) / 2; // Two columns
      case DeviceType.desktop:
        return (screenWidth - 64) / 3; // Three columns
    }
  }

  /// Get responsive navigation type
  NavigationType getNavigationType(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return NavigationType.bottomNavigation;
      case DeviceType.tablet:
        return NavigationType.navigationRail;
      case DeviceType.desktop:
        return NavigationType.navigationDrawer;
    }
  }

  /// Get responsive layout configuration
  ResponsiveLayoutConfig getLayoutConfig(Size screenSize) {
    final deviceType = getDeviceType(screenSize.width);
    final screenSizeCategory = getScreenSize(screenSize);

    return ResponsiveLayoutConfig(
      deviceType: deviceType,
      screenSize: screenSizeCategory,
      padding: getResponsivePadding(screenSizeCategory),
      margin: getResponsiveMargin(screenSizeCategory),
      fontSizeMultiplier: getFontSizeMultiplier(screenSizeCategory),
      iconSize: getResponsiveIconSize(screenSizeCategory),
      buttonHeight: getResponsiveButtonHeight(screenSizeCategory),
      gridColumns: getResponsiveGridColumns(deviceType),
      navigationType: getNavigationType(deviceType),
    );
  }

  /// Check if device supports advanced gestures
  bool supportsAdvancedGestures(DeviceType deviceType) {
    return deviceType == DeviceType.mobile || deviceType == DeviceType.tablet;
  }

  /// Get optimal touch target size
  Size getOptimalTouchTargetSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.small:
        return const Size(44, 44);
      case ScreenSize.medium:
        return const Size(48, 48);
      case ScreenSize.large:
        return const Size(52, 52);
      case ScreenSize.extraLarge:
        return const Size(56, 56);
    }
  }

  /// Get responsive breakpoints
  ResponsiveBreakpoints get breakpoints => const ResponsiveBreakpoints(
    mobile: 600,
    tablet: 1024,
    desktop: 1440,
  );
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Screen size categories
enum ScreenSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Navigation type based on device
enum NavigationType {
  bottomNavigation,
  navigationRail,
  navigationDrawer,
}

/// Responsive layout configuration
class ResponsiveLayoutConfig {
  final DeviceType deviceType;
  final ScreenSize screenSize;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double fontSizeMultiplier;
  final double iconSize;
  final double buttonHeight;
  final int gridColumns;
  final NavigationType navigationType;

  const ResponsiveLayoutConfig({
    required this.deviceType,
    required this.screenSize,
    required this.padding,
    required this.margin,
    required this.fontSizeMultiplier,
    required this.iconSize,
    required this.buttonHeight,
    required this.gridColumns,
    required this.navigationType,
  });
}

/// Responsive breakpoints
class ResponsiveBreakpoints {
  final double mobile;
  final double tablet;
  final double desktop;

  const ResponsiveBreakpoints({
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });
}

/// Provider for responsive design service
final responsiveDesignServiceProvider = Provider<ResponsiveDesignService>((ref) {
  return ResponsiveDesignService();
});

/// Provider for current layout configuration
final layoutConfigProvider = Provider<ResponsiveLayoutConfig>((ref) {
  final service = ref.read(responsiveDesignServiceProvider);
  // This would typically get the screen size from MediaQuery
  // For now, we'll return a default configuration
  return service.getLayoutConfig(const Size(375, 812)); // iPhone size
});