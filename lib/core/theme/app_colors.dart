import 'dart:ui';
import 'package:flutter/material.dart';

/// Centralized color palette for SmartRemind.
/// Dark-mode first, inspired by iOS Liquid Glass aesthetics.
class AppColors {
  AppColors._();

  // ── Base Surface Colors ──
  static const Color scaffoldDark = Color(0xFF0A0A0F);
  static const Color surfaceDark = Color(0xFF14141F);
  static const Color surfaceElevated = Color(0xFF1C1C2E);
  static const Color surfaceGlass = Color(0x1AFFFFFF); // 10% white
  static const Color surfaceGlassHover = Color(0x26FFFFFF); // 15% white
  static const Color borderGlass = Color(0x1AFFFFFF); // 10% white
  static const Color borderGlassActive = Color(0x33FFFFFF); // 20% white

  // ── Text Colors ──
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xB3F5F5F7); // 70% white
  static const Color textTertiary = Color(0x80F5F5F7); // 50% white
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ── Accent / Brand ──
  static const Color accentPrimary = Color(0xFF6E8EFB);
  static const Color accentSecondary = Color(0xFFA777E3);
  static const Color accentGradientStart = Color(0xFF6E8EFB);
  static const Color accentGradientEnd = Color(0xFFA777E3);

  // ── Semantic Colors ──
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // ── Category Preset Colors ──
  /// 8 curated colors for category assignment.
  static const List<Color> categoryPresets = [
    Color(0xFF6E8EFB), // Periwinkle Blue
    Color(0xFFA777E3), // Soft Purple
    Color(0xFF34D399), // Emerald Green
    Color(0xFFFBBF24), // Amber Gold
    Color(0xFFF87171), // Coral Red
    Color(0xFF60A5FA), // Sky Blue
    Color(0xFFF472B6), // Rose Pink
    Color(0xFFFB923C), // Tangerine Orange
  ];

  // ── Gradients ──
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentGradientStart, accentGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.08),
      Colors.white.withOpacity(0.03),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
