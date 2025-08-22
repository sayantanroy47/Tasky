import 'package:flutter/material.dart';
import '../../presentation/widgets/glassmorphism_container.dart';
import 'design_tokens.dart';

/// Standardized component library ensuring design system consistency
class ComponentLibrary {
  ComponentLibrary._();

  /// Create a standardized glassmorphism card
  static Widget card({
    required Widget child,
    GlassLevel level = GlassLevel.content,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? glassTint,
    VoidCallback? onTap,
    String? semanticLabel,
    Key? key,
  }) {
    return Container(
      key: key,
      margin: margin ?? CardTokens.margin,
      child: Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: GestureDetector(
          onTap: onTap,
          child: GlassmorphismContainer(
            level: level,
            padding: padding ?? CardTokens.padding,
            borderRadius: BorderRadius.circular(
              borderRadius ?? CardTokens.borderRadius
            ),
            glassTint: glassTint,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Create a standardized glass button
  static Widget button({
    required Widget child,
    required VoidCallback? onPressed,
    ButtonStyle? style,
    bool autofocus = false,
    Key? key,
  }) {
    return GlassmorphismContainer(
      key: key,
      level: GlassLevel.interactive,
      padding: ButtonTokens.padding,
      borderRadius: BorderRadius.circular(ButtonTokens.borderRadius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(ButtonTokens.borderRadius),
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(
              minHeight: ButtonTokens.height,
              minWidth: ButtonTokens.minWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Create a standardized glass input field
  static Widget input({
    String? labelText,
    String? hintText,
    TextEditingController? controller,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    Key? key,
  }) {
    return GlassmorphismContainer(
      key: key,
      level: InputTokens.glassLevel,
      padding: InputTokens.padding,
      borderRadius: BorderRadius.circular(InputTokens.borderRadius),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// Create a standardized dialog
  static Widget dialog({
    required Widget child,
    String? title,
    List<Widget>? actions,
    Key? key,
  }) {
    return Dialog(
      key: key,
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(20.0),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
            child,
            if (actions != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Utility class for creating accessible components
class AccessibleComponentLibrary {
  AccessibleComponentLibrary._();

  /// Create an accessible card with proper semantics
  static Widget accessibleCard({
    required Widget child,
    required String semanticLabel,
    GlassLevel level = GlassLevel.content,
    VoidCallback? onTap,
    Key? key,
  }) {
    return ComponentLibrary.card(
      key: key,
      child: child,
      level: level,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  /// Create an accessible button with proper contrast
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    Key? key,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: ComponentLibrary.button(
        key: key,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}