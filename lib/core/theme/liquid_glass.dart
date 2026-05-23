import 'dart:ui';
import 'package:flutter/material.dart';

/// Liquid Glass design utilities — frosted glass panels, blur effects,
/// translucent surfaces inspired by iOS 26 design language.
class LiquidGlass {
  LiquidGlass._();

  /// Standard blur sigma for glass panels.
  static const double blurSigma = 24.0;

  /// Light blur for subtler effects.
  static const double blurSigmaLight = 12.0;

  /// Standard border radius for glass cards.
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(20));

  /// Pill-shaped radius for buttons and chips.
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(50));

  /// Input field radius.
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(16));

  /// Standard glass panel decoration with frosted effect.
  static BoxDecoration glassDecoration({
    Color? color,
    double opacity = 0.10,
    double borderOpacity = 0.10,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: borderRadius ?? cardRadius,
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 0.5,
      ),
    );
  }

  /// Elevated glass decoration with stronger presence.
  static BoxDecoration elevatedGlassDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.white.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadius ?? cardRadius,
      border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Accent-tinted glass decoration.
  static BoxDecoration accentGlassDecoration({
    required Color accentColor,
    double opacity = 0.15,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          accentColor.withOpacity(opacity),
          accentColor.withOpacity(opacity * 0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadius ?? cardRadius,
      border: Border.all(color: accentColor.withOpacity(0.25), width: 0.5),
    );
  }
}

/// A widget that wraps its child in a frosted glass panel with blur.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final double opacity;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.blurSigma = LiquidGlass.blurSigma,
    this.tintColor,
    this.opacity = 0.10,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? LiquidGlass.cardRadius;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: LiquidGlass.glassDecoration(
            color: tintColor,
            opacity: opacity,
            borderRadius: radius,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
