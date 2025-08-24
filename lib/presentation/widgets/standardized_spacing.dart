import 'package:flutter/material.dart';

import '../../core/design_system/design_tokens.dart';

/// Standardized spacing components that eliminate spacing chaos
/// 
/// Eliminates Spacing Inconsistency by:
/// - Enforcing SpacingTokens instead of hardcoded EdgeInsets values
/// - Providing consistent spacing widgets for all layouts
/// - Following the 8px grid system throughout the app
/// - Maintaining visual rhythm through standardized spacing scales
class StandardizedSpacing {
  /// Standard padding that replaces hardcoded EdgeInsets.all()
  static EdgeInsets padding(SpacingSize size) {
    return EdgeInsets.all(_getSpacing(size));
  }

  /// Standard symmetric padding that replaces hardcoded EdgeInsets.symmetric()
  static EdgeInsets paddingSymmetric({
    SpacingSize? horizontal,
    SpacingSize? vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal != null ? _getSpacing(horizontal) : 0,
      vertical: vertical != null ? _getSpacing(vertical) : 0,
    );
  }

  /// Standard custom padding that replaces hardcoded EdgeInsets.only()
  static EdgeInsets paddingOnly({
    SpacingSize? left,
    SpacingSize? top,
    SpacingSize? right,
    SpacingSize? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null ? _getSpacing(left) : 0,
      top: top != null ? _getSpacing(top) : 0,
      right: right != null ? _getSpacing(right) : 0,
      bottom: bottom != null ? _getSpacing(bottom) : 0,
    );
  }

  /// Standard margin that replaces hardcoded EdgeInsets values
  static EdgeInsets margin(SpacingSize size) {
    return EdgeInsets.all(_getSpacing(size));
  }

  /// Standard symmetric margin
  static EdgeInsets marginSymmetric({
    SpacingSize? horizontal,
    SpacingSize? vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal != null ? _getSpacing(horizontal) : 0,
      vertical: vertical != null ? _getSpacing(vertical) : 0,
    );
  }

  /// Standard custom margin
  static EdgeInsets marginOnly({
    SpacingSize? left,
    SpacingSize? top,
    SpacingSize? right,
    SpacingSize? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null ? _getSpacing(left) : 0,
      top: top != null ? _getSpacing(top) : 0,
      right: right != null ? _getSpacing(right) : 0,
      bottom: bottom != null ? _getSpacing(bottom) : 0,
    );
  }

  /// Get spacing value for a given size
  static double _getSpacing(SpacingSize size) {
    switch (size) {
      case SpacingSize.xs:
        return SpacingTokens.xs; // 4px
      case SpacingSize.sm:
        return SpacingTokens.sm; // 8px  
      case SpacingSize.md:
        return SpacingTokens.md; // 16px
      case SpacingSize.lg:
        return SpacingTokens.lg; // 24px
      case SpacingSize.xl:
        return SpacingTokens.xl; // 32px
      case SpacingSize.xxl:
        return SpacingTokens.xxl; // 48px
      case SpacingSize.xxxl:
        return SpacingTokens.xxxl; // 64px
      case SpacingSize.phi1:
        return SpacingTokens.phi1; // 13px - Natural rhythm
      case SpacingSize.phi2:
        return SpacingTokens.phi2; // 17px - Comfortable reading
      case SpacingSize.phi3:
        return SpacingTokens.phi3; // 21px - Spacious layout
    }
  }
}

/// Standardized spacing widgets that replace hardcoded SizedBox
class StandardizedGaps {
  /// Vertical gaps that replace SizedBox(height:)
  static Widget vertical(SpacingSize size) {
    return SizedBox(height: StandardizedSpacing._getSpacing(size));
  }

  /// Horizontal gaps that replace SizedBox(width:)
  static Widget horizontal(SpacingSize size) {
    return SizedBox(width: StandardizedSpacing._getSpacing(size));
  }

  /// Common vertical gaps for quick access
  static Widget get xs => const SizedBox(height: SpacingTokens.xs); // 4px
  static Widget get sm => const SizedBox(height: SpacingTokens.sm); // 8px
  static Widget get md => const SizedBox(height: SpacingTokens.md); // 16px
  static Widget get lg => const SizedBox(height: SpacingTokens.lg); // 24px
  static Widget get xl => const SizedBox(height: SpacingTokens.xl); // 32px

  /// Common horizontal gaps for quick access
  static Widget get hXs => const SizedBox(width: SpacingTokens.xs); // 4px
  static Widget get hSm => const SizedBox(width: SpacingTokens.sm); // 8px
  static Widget get hMd => const SizedBox(width: SpacingTokens.md); // 16px
  static Widget get hLg => const SizedBox(width: SpacingTokens.lg); // 24px
  static Widget get hXl => const SizedBox(width: SpacingTokens.xl); // 32px
}

/// Spacing sizes that map to design tokens
enum SpacingSize {
  xs,    // 4px - Tight spacing
  sm,    // 8px - Component spacing  
  md,    // 16px - Section spacing
  lg,    // 24px - Large spacing
  xl,    // 32px - Page margins
  xxl,   // 48px - Major sections
  xxxl,  // 64px - Hero spacing
  phi1,  // 13px - Natural rhythm
  phi2,  // 17px - Comfortable reading  
  phi3,  // 21px - Spacious layout
}

/// Pre-configured spacing patterns for common layouts
class StandardizedSpacingPatterns {
  /// Card padding pattern - consistent across all cards
  static EdgeInsets get cardPadding => 
    const EdgeInsets.all(SpacingTokens.md); // 16px

  /// Card margin pattern - consistent spacing between cards
  static EdgeInsets get cardMargin => 
    const EdgeInsets.all(SpacingTokens.sm); // 8px

  /// Page padding pattern - consistent page margins
  static EdgeInsets get pagePadding => 
    const EdgeInsets.all(SpacingTokens.pagePadding); // 32px

  /// Section padding pattern - consistent section spacing
  static EdgeInsets get sectionPadding => 
    const EdgeInsets.all(SpacingTokens.sectionPadding); // 34px (phi5)

  /// Element padding pattern - consistent element internal spacing
  static EdgeInsets get elementPadding => 
    const EdgeInsets.all(SpacingTokens.elementPadding); // 21px (phi3)

  /// Button padding pattern - consistent button internal spacing
  static EdgeInsets get buttonPadding =>
    const EdgeInsets.symmetric(horizontal: 24, vertical: 12);

  /// Input padding pattern - consistent input field spacing
  static EdgeInsets get inputPadding =>
    const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// Dialog padding pattern - consistent dialog spacing
  static EdgeInsets get dialogPadding =>
    const EdgeInsets.all(SpacingTokens.lg); // 24px

  /// List item padding pattern - consistent list spacing
  static EdgeInsets get listItemPadding =>
    const EdgeInsets.symmetric(
      horizontal: SpacingTokens.md, // 16px
      vertical: SpacingTokens.sm,   // 8px
    );

  /// Form field spacing pattern - consistent form layout
  static Widget get formFieldGap => StandardizedGaps.md; // 16px

  /// Section gap pattern - consistent section separation
  static Widget get sectionGap => StandardizedGaps.lg; // 24px

  /// Component gap pattern - consistent component separation  
  static Widget get componentGap => StandardizedGaps.sm; // 8px
}

/// Layout helpers for consistent responsive spacing
class StandardizedSpacingHelpers {
  /// Get responsive horizontal padding based on screen width
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > 1200) {
      return const EdgeInsets.symmetric(horizontal: SpacingTokens.xxxl); // 64px
    } else if (screenWidth > 800) {
      return const EdgeInsets.symmetric(horizontal: SpacingTokens.xl); // 32px
    } else if (screenWidth > 600) {
      return const EdgeInsets.symmetric(horizontal: SpacingTokens.lg); // 24px
    } else {
      return const EdgeInsets.symmetric(horizontal: SpacingTokens.md); // 16px
    }
  }

  /// Get responsive content max width with proper margins
  static Widget responsiveContentWrapper({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 1200,
        ),
        child: Padding(
          padding: responsiveHorizontalPadding(context),
          child: child,
        ),
      ),
    );
  }

  /// Apply consistent vertical rhythm to a list of widgets
  static List<Widget> applyVerticalRhythm(
    List<Widget> children, {
    SpacingSize gap = SpacingSize.md,
  }) {
    if (children.length <= 1) return children;
    
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(StandardizedGaps.vertical(gap));
      }
    }
    return result;
  }

  /// Apply consistent horizontal rhythm to a list of widgets
  static List<Widget> applyHorizontalRhythm(
    List<Widget> children, {
    SpacingSize gap = SpacingSize.sm,
  }) {
    if (children.length <= 1) return children;
    
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(StandardizedGaps.horizontal(gap));
      }
    }
    return result;
  }

  /// Create consistent spacing around a widget
  static Widget withSpacing(
    Widget child, {
    SpacingSize? all,
    SpacingSize? horizontal,
    SpacingSize? vertical,
    SpacingSize? left,
    SpacingSize? top,
    SpacingSize? right,
    SpacingSize? bottom,
  }) {
    EdgeInsets padding;
    
    if (all != null) {
      padding = StandardizedSpacing.padding(all);
    } else if (horizontal != null || vertical != null) {
      padding = StandardizedSpacing.paddingSymmetric(
        horizontal: horizontal,
        vertical: vertical,
      );
    } else {
      padding = StandardizedSpacing.paddingOnly(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
    }
    
    return Padding(
      padding: padding,
      child: child,
    );
  }
}