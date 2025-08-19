import 'package:flutter/material.dart';
import 'responsive_constants.dart';

/// Builder widget for responsive layouts
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveConfig config) builder;
  final ResponsiveConfig? overrideConfig;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.overrideConfig,
  });

  @override
  Widget build(BuildContext context) {
    final config = overrideConfig ?? _createResponsiveConfig(context);
    return builder(context, config);
  }

  /// Create responsive configuration from current context
  static ResponsiveConfig _createResponsiveConfig(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final width = size.width;
    final height = size.height;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final textScaleFactor = mediaQuery.textScaler.scale(1.0);

    // Determine device type
    final deviceType = _getDeviceType(width);
    
    // Determine layout size class
    final sizeClass = _getLayoutSizeClass(width);
    
    // Determine adaptive device type
    final adaptiveType = _getAdaptiveDeviceType(width, height);
    
    // Determine screen density
    final density = _getScreenDensity(devicePixelRatio);
    
    // Get appropriate padding and margin
    final padding = _getResponsivePadding(deviceType);
    final margin = _getResponsiveMargin(deviceType);
    
    // Get font and icon scale
    final fontScale = _getFontScale(deviceType) * textScaleFactor;
    final iconScale = _getIconScale(deviceType);
    
    // Get grid columns
    final gridColumns = _getGridColumns(adaptiveType);
    
    // Get animation duration
    final animationDuration = _getAnimationDuration(deviceType);

    return ResponsiveConfig(
      deviceType: deviceType,
      sizeClass: sizeClass,
      adaptiveType: adaptiveType,
      density: density,
      screenSize: size,
      padding: padding,
      margin: margin,
      fontScale: fontScale,
      iconScale: iconScale,
      gridColumns: gridColumns,
      animationDuration: animationDuration,
    );
  }

  /// Determine device type from screen width
  static ResponsiveDeviceType _getDeviceType(double width) {
    if (width < ResponsiveConstants.mobileBreakpoint) {
      return ResponsiveDeviceType.mobile;
    } else if (width < ResponsiveConstants.tabletBreakpoint) {
      return ResponsiveDeviceType.tablet;
    } else if (width < ResponsiveConstants.largeDesktopBreakpoint) {
      return ResponsiveDeviceType.desktop;
    } else {
      return ResponsiveDeviceType.largeDesktop;
    }
  }

  /// Determine layout size class from screen width
  static LayoutSizeClass _getLayoutSizeClass(double width) {
    if (width < ResponsiveConstants.compactWidth) {
      return LayoutSizeClass.compact;
    } else if (width < ResponsiveConstants.mediumWidth) {
      return LayoutSizeClass.medium;
    } else {
      return LayoutSizeClass.expanded;
    }
  }

  /// Determine adaptive device type considering orientation
  static AdaptiveDeviceType _getAdaptiveDeviceType(double width, double height) {
    final isLandscape = width > height;
    
    if (width < ResponsiveConstants.mobileBreakpoint) {
      return isLandscape 
        ? AdaptiveDeviceType.mobileLandscape 
        : AdaptiveDeviceType.mobilePortrait;
    } else if (width < ResponsiveConstants.tabletBreakpoint) {
      return isLandscape 
        ? AdaptiveDeviceType.tabletLandscape 
        : AdaptiveDeviceType.tabletPortrait;
    } else if (width < ResponsiveConstants.largeDesktopBreakpoint) {
      return AdaptiveDeviceType.desktop;
    } else {
      return AdaptiveDeviceType.largeDesktop;
    }
  }

  /// Determine screen density from device pixel ratio
  static ScreenDensity _getScreenDensity(double devicePixelRatio) {
    if (devicePixelRatio <= 1.0) {
      return ScreenDensity.low;
    } else if (devicePixelRatio <= 1.5) {
      return ScreenDensity.medium;
    } else if (devicePixelRatio <= 2.0) {
      return ScreenDensity.high;
    } else if (devicePixelRatio <= 3.0) {
      return ScreenDensity.xHigh;
    } else if (devicePixelRatio <= 4.0) {
      return ScreenDensity.xxHigh;
    } else {
      return ScreenDensity.xxxHigh;
    }
  }

  /// Get responsive padding based on device type
  static EdgeInsets _getResponsivePadding(ResponsiveDeviceType deviceType) {
    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return ResponsiveConstants.mobilePadding;
      case ResponsiveDeviceType.tablet:
        return ResponsiveConstants.tabletPadding;
      case ResponsiveDeviceType.desktop:
      case ResponsiveDeviceType.largeDesktop:
        return ResponsiveConstants.desktopPadding;
    }
  }

  /// Get responsive margin based on device type
  static EdgeInsets _getResponsiveMargin(ResponsiveDeviceType deviceType) {
    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return ResponsiveConstants.mobileMargin;
      case ResponsiveDeviceType.tablet:
        return ResponsiveConstants.tabletMargin;
      case ResponsiveDeviceType.desktop:
      case ResponsiveDeviceType.largeDesktop:
        return ResponsiveConstants.desktopMargin;
    }
  }

  /// Get font scale based on device type
  static double _getFontScale(ResponsiveDeviceType deviceType) {
    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return ResponsiveConstants.mobileTypographyScale;
      case ResponsiveDeviceType.tablet:
        return ResponsiveConstants.tabletTypographyScale;
      case ResponsiveDeviceType.desktop:
      case ResponsiveDeviceType.largeDesktop:
        return ResponsiveConstants.desktopTypographyScale;
    }
  }

  /// Get icon scale based on device type
  static double _getIconScale(ResponsiveDeviceType deviceType) {
    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return 1.0;
      case ResponsiveDeviceType.tablet:
        return 1.2;
      case ResponsiveDeviceType.desktop:
      case ResponsiveDeviceType.largeDesktop:
        return 1.4;
    }
  }

  /// Get grid columns based on adaptive device type
  static int _getGridColumns(AdaptiveDeviceType adaptiveType) {
    switch (adaptiveType) {
      case AdaptiveDeviceType.mobilePortrait:
        return ResponsiveConstants.mobileColumns;
      case AdaptiveDeviceType.mobileLandscape:
        return ResponsiveConstants.tabletPortraitColumns;
      case AdaptiveDeviceType.tabletPortrait:
        return ResponsiveConstants.tabletPortraitColumns;
      case AdaptiveDeviceType.tabletLandscape:
        return ResponsiveConstants.tabletLandscapeColumns;
      case AdaptiveDeviceType.desktop:
        return ResponsiveConstants.desktopColumns;
      case AdaptiveDeviceType.largeDesktop:
        return ResponsiveConstants.desktopColumns + 1;
    }
  }

  /// Get animation duration based on device type
  static Duration _getAnimationDuration(ResponsiveDeviceType deviceType) {
    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return ResponsiveConstants.mobileAnimationDuration;
      case ResponsiveDeviceType.tablet:
        return ResponsiveConstants.tabletAnimationDuration;
      case ResponsiveDeviceType.desktop:
      case ResponsiveDeviceType.largeDesktop:
        return ResponsiveConstants.desktopAnimationDuration;
    }
  }
}

/// Responsive layout widget for specific breakpoints
class ResponsiveLayout extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Widget Function(BuildContext context, ResponsiveConfig config)? builder;

  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.builder,
  }) : assert(
          mobile != null || tablet != null || desktop != null || largeDesktop != null || builder != null,
          'At least one layout widget or builder must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, config) {
        if (builder != null) {
          return builder!(context, config);
        }

        switch (config.deviceType) {
          case ResponsiveDeviceType.mobile:
            return mobile ?? tablet ?? desktop ?? largeDesktop!;
          case ResponsiveDeviceType.tablet:
            return tablet ?? mobile ?? desktop ?? largeDesktop!;
          case ResponsiveDeviceType.desktop:
            return desktop ?? largeDesktop ?? tablet ?? mobile!;
          case ResponsiveDeviceType.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile!;
        }
      },
    );
  }
}

/// Responsive value selector
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  /// Get value for current device type
  T getValue(ResponsiveDeviceType deviceType) {
    switch (deviceType) {
      case ResponsiveDeviceType.mobile:
        return mobile;
      case ResponsiveDeviceType.tablet:
        return tablet ?? mobile;
      case ResponsiveDeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case ResponsiveDeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Extension for easier access to responsive config
extension ResponsiveContext on BuildContext {
  ResponsiveConfig get responsive => ResponsiveBuilder._createResponsiveConfig(this);
  ResponsiveDeviceType get deviceType => responsive.deviceType;
  LayoutSizeClass get sizeClass => responsive.sizeClass;
  bool get isMobile => responsive.isMobile;
  bool get isTablet => responsive.isTablet;
  bool get isDesktop => responsive.isDesktop;
}