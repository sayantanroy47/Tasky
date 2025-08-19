import 'package:flutter/material.dart';

/// UI constants to replace magic numbers throughout the app
class UIConstants {
  // Prevent instantiation
  UIConstants._();

  /// Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration standardAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration extraSlowAnimation = Duration(milliseconds: 1000);

  /// Border radius values
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 50.0;

  /// Spacing values
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  static const double spaceXXXL = 64.0;

  /// Icon sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  /// Button heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;
  static const double buttonHeightXL = 64.0;

  /// Touch target sizes
  static const double touchTargetMin = 44.0;
  static const double touchTargetRecommended = 48.0;
  static const double touchTargetLarge = 56.0;

  /// Card dimensions
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 8.0;
  static const double cardMaxWidth = 400.0;
  static const double cardMinHeight = 120.0;

  /// List item heights
  static const double listItemHeightS = 48.0;
  static const double listItemHeightM = 56.0;
  static const double listItemHeightL = 72.0;
  static const double listItemHeightXL = 88.0;

  /// Navigation bar heights
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 64.0;
  static const double bottomNavHeight = 80.0;
  static const double navRailWidth = 72.0;
  static const double navDrawerWidth = 256.0;

  /// Layout constraints
  static const double maxContentWidth = 1200.0;
  static const double maxDialogWidth = 560.0;
  static const double minDialogWidth = 280.0;

  /// Typography scales
  static const double fontScaleXS = 0.75;
  static const double fontScaleS = 0.875;
  static const double fontScaleM = 1.0;
  static const double fontScaleL = 1.125;
  static const double fontScaleXL = 1.25;
  static const double fontScaleXXL = 1.5;

  /// Opacity values
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.87;
  static const double opacityTransparent = 0.0;
  static const double opacityOpaque = 1.0;

  /// Z-index values (elevation)
  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationHighest = 16.0;

  /// Gesture thresholds
  static const double swipeThreshold = 50.0;
  static const double longPressThreshold = 500.0; // milliseconds
  static const double doubleTapTimeout = 300.0; // milliseconds
  static const double pinchSensitivity = 0.1;

  /// Performance thresholds
  static const int maxListItems = 1000;
  static const int virtualScrollThreshold = 100;
  static const int cacheSize = 50;
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration throttleDelay = Duration(milliseconds: 100);

  /// Network timeouts
  static const Duration networkTimeoutShort = Duration(seconds: 10);
  static const Duration networkTimeoutMedium = Duration(seconds: 30);
  static const Duration networkTimeoutLong = Duration(seconds: 60);

  /// Image dimensions
  static const double avatarSizeS = 32.0;
  static const double avatarSizeM = 48.0;
  static const double avatarSizeL = 64.0;
  static const double avatarSizeXL = 96.0;

  /// Task card specific
  static const double taskCardMinHeight = 80.0;
  static const double taskCardMaxHeight = 200.0;
  static const double taskCardPadding = 16.0;
  static const double priorityIndicatorWidth = 4.0;
  static const double completionIndicatorSize = 24.0;

  /// Form field dimensions
  static const double textFieldHeight = 56.0;
  static const double textFieldMinLines = 1;
  static const double textFieldMaxLines = 5;
  static const double searchFieldHeight = 48.0;

  /// Glassmorphism effects
  static const double glassBlurRadius = 10.0;
  static const double glassBorderWidth = 1.0;
  static const double glassOpacity = 0.1;

  /// Responsive breakpoints (from responsive_constants.dart)
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 905.0;
  static const double desktopBreakpoint = 1240.0;
  static const double largeDesktopBreakpoint = 1440.0;

  /// Component-specific constants
  static const int maxRecentItems = 10;
  static const int maxSearchResults = 50;
  static const int defaultPageSize = 20;
  static const int maxNotificationHistory = 100;

  /// Color opacity presets
  static const double surfaceOpacity = 0.05;
  static const double overlayOpacity = 0.12;
  static const double focusOpacity = 0.24;
  static const double hoverOpacity = 0.08;
  static const double selectedOpacity = 0.16;
  static const double dragOpacity = 0.24;

  /// Border widths
  static const double borderThin = 1.0;
  static const double borderMedium = 2.0;
  static const double borderThick = 3.0;
  static const double borderExtraThick = 4.0;

  /// Loading states
  static const int shimmerAnimationDuration = 1500; // milliseconds
  static const int progressIndicatorStrokeWidth = 4;
  static const double loadingIndicatorSize = 48.0;

  /// Notification dimensions
  static const double notificationHeight = 64.0;
  static const double notificationMaxWidth = 400.0;
  static const Duration notificationDuration = Duration(seconds: 4);

  /// Fab positioning
  static const double fabMargin = 16.0;
  static const double fabSize = 56.0;
  static const double fabMiniSize = 40.0;
  static const double fabExtendedHeight = 48.0;

  /// Dialog constraints
  static const double dialogMargin = 24.0;
  static const double dialogPadding = 24.0;
  static const double dialogTitleBottomPadding = 20.0;
  static const double dialogActionsPadding = 8.0;

  /// Tab dimensions
  static const double tabHeight = 48.0;
  static const double tabMinWidth = 72.0;
  static const double tabIndicatorHeight = 2.0;

  /// Slider dimensions
  static const double sliderHeight = 48.0;
  static const double sliderThumbRadius = 12.0;
  static const double sliderTrackHeight = 4.0;

  /// Switch dimensions
  static const double switchWidth = 52.0;
  static const double switchHeight = 32.0;
  static const double switchThumbRadius = 14.0;

  /// Chip dimensions
  static const double chipHeight = 32.0;
  static const double chipPadding = 12.0;
  static const double chipIconSize = 18.0;
  static const double chipDeleteIconSize = 16.0;

  /// Progress bar dimensions
  static const double progressBarHeight = 4.0;
  static const double progressBarBorderRadius = 2.0;

  /// Divider dimensions
  static const double dividerHeight = 1.0;
  static const double dividerIndent = 16.0;

  /// Scroll physics
  static const double scrollSpeedMultiplier = 1.0;
  static const double overscrollDistance = 16.0;

  /// Animation curves (commonly used)
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;

  /// Grid layout
  static const int gridColumnsPortrait = 2;
  static const int gridColumnsLandscape = 3;
  static const int gridColumnsTablet = 3;
  static const int gridColumnsDesktop = 4;
  static const double gridSpacing = 16.0;
  static const double gridChildAspectRatio = 1.2;

  /// Carousel dimensions
  static const double carouselHeight = 200.0;
  static const double carouselViewportFraction = 0.8;
  static const double carouselPageSpacing = 8.0;

  /// Badge dimensions
  static const double badgeSize = 20.0;
  static const double badgeOffset = 4.0;
  static const double badgeFontSize = 12.0;

  /// Tooltip constraints
  static const Duration tooltipShowDelay = Duration(milliseconds: 500);
  static const Duration tooltipHideDelay = Duration(milliseconds: 1500);
  static const double tooltipMaxWidth = 320.0;

  /// Search constraints
  static const int searchMinCharacters = 2;
  static const Duration searchDebounceTime = Duration(milliseconds: 500);
  static const int maxSearchHistory = 20;

  /// Calendar dimensions
  static const double calendarCellHeight = 48.0;
  static const double calendarHeaderHeight = 56.0;
  static const double calendarMonthPickerHeight = 400.0;

  /// Time picker dimensions
  static const double timePickerDialSize = 280.0;
  static const double timePickerHourMinuteHeight = 80.0;

  /// Expansion panel
  static const double expansionTileHeight = 56.0;
  static const double expansionTileCollapsedHeight = 56.0;
  static const double expansionTileExpandedHeight = 200.0;

  /// Stepper dimensions
  static const double stepperCircleRadius = 12.0;
  static const double stepperLineWidth = 1.0;
  static const double stepperContentPadding = 16.0;

  /// Data table dimensions
  static const double dataTableRowHeight = 48.0;
  static const double dataTableHeaderHeight = 56.0;
  static const double dataTableColumnSpacing = 56.0;
  static const double dataTableCheckboxWidth = 48.0;

  /// Bottom sheet constraints
  static const double bottomSheetMaxHeight = 0.9; // 90% of screen height
  static const double bottomSheetMinHeight = 200.0;
  static const double bottomSheetBorderRadius = 16.0;
  static const double bottomSheetDragHandleHeight = 4.0;
  static const double bottomSheetDragHandleWidth = 32.0;

  /// Snackbar dimensions
  static const double snackbarHeight = 48.0;
  static const double snackbarMaxWidth = 600.0;
  static const double snackbarMargin = 16.0;
  static const Duration snackbarDuration = Duration(seconds: 4);

  /// Loading skeleton
  static const double skeletonBaseOpacity = 0.1;
  static const double skeletonHighlightOpacity = 0.2;
  static const Duration skeletonAnimationDuration = Duration(milliseconds: 1500);

  /// Refresh indicator
  static const double refreshIndicatorStrokeWidth = 3.0;
  static const double refreshIndicatorDisplacement = 40.0;

  /// Page transition
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  /// Blur effects
  static const double backgroundBlurRadius = 8.0;
  static const double modalBlurRadius = 12.0;
  static const double dialogBlurRadius = 16.0;
}

/// Theme-specific constants
class ThemeConstants {
  ThemeConstants._();

  /// Color alpha values
  static const int alphaTransparent = 0;
  static const int alphaLow = 38; // 15%
  static const int alphaMedium = 102; // 40%
  static const int alphaHigh = 153; // 60%
  static const int alphaVeryHigh = 204; // 80%
  static const int alphaOpaque = 255; // 100%

  /// Shadow configurations
  static const List<BoxShadow> lowShadow = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color.fromRGBO(0, 0, 0, 0.12),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color.fromRGBO(0, 0, 0, 0.24),
    ),
  ];

  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      offset: Offset(0, 3),
      blurRadius: 6,
      color: Color.fromRGBO(0, 0, 0, 0.16),
    ),
    BoxShadow(
      offset: Offset(0, 3),
      blurRadius: 6,
      color: Color.fromRGBO(0, 0, 0, 0.23),
    ),
  ];

  static const List<BoxShadow> highShadow = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 20,
      color: Color.fromRGBO(0, 0, 0, 0.19),
    ),
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 6,
      color: Color.fromRGBO(0, 0, 0, 0.23),
    ),
  ];

  /// Gradient configurations
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981), // Emerald
    Color(0xFF059669), // Emerald dark
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF59E0B), // Amber
    Color(0xFFD97706), // Amber dark
  ];

  static const List<Color> errorGradient = [
    Color(0xFFEF4444), // Red
    Color(0xFFDC2626), // Red dark
  ];
}

/// Performance constants
class PerformanceConstants {
  PerformanceConstants._();

  /// Frame rate targets
  static const int targetFrameRate = 60;
  static const int minimumFrameRate = 30;
  static const int warningFrameRate = 45;

  /// Memory thresholds (in MB)
  static const int memoryWarningThreshold = 100;
  static const int memoryCriticalThreshold = 200;

  /// List virtualization
  static const int virtualListItemHeight = 72;
  static const int virtualListCacheExtent = 500;
  static const int virtualListSemanticCacheExtent = 1000;

  /// Image optimization
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const double imageCompressionQuality = 0.85;

  /// Network optimization
  static const int maxConcurrentRequests = 3;
  static const int requestTimeoutSeconds = 30;
  static const int retryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Caching
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheEntries = 1000;

  /// Database
  static const int batchSize = 100;
  static const int maxDatabaseSize = 500 * 1024 * 1024; // 500MB
  static const Duration vacuumInterval = Duration(days: 7);
}