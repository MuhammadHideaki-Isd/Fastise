import 'package:flutter/material.dart';

/// Obsidian & Soft Sage Mint palette:
/// calm charcoal surfaces paired with two harmonious, non-neon accents
/// (Soft Sage Mint for fasting progress & Warm Sand for eating/target milestones).
abstract final class AppColors {
  static const fontDisplay = 'Sora';
  static const fontBody = 'DMSans';

  // Layered dark surfaces
  static const background = Color(0xFF121413);
  static const surface = Color(0xFF1B1F1D);
  static const surfaceElevated = Color(0xFF232825);
  static const surfaceSubtle = Color(0xFF161918);

  // Primary accent — Soft Sage Mint
  static const primary = Color(0xFF63B995);
  static const primaryBright = Color(0xFF82D4B2);
  static const primaryDark = Color(0xFF439674);
  static const onPrimary = Color(0xFF0C1A14);
  static const primarySoft = Color(0xFF1E3129);
  static const primaryMuted = Color(0xFF2A3D35);

  // Secondary companion accent — Warm Sand / Soft Amber
  static const accentWarm = Color(0xFFD9B382);
  static const accentWarmSoft = Color(0xFF2E271E);

  // Typography & borders (WCAG AA+ contrast on #121413 and #1B1F1D)
  static const textPrimary = Color(0xFFF2F5F3);
  static const textSecondary = Color(0xFF9AA69F);
  static const border = Color(0xFF29302C);
  static const borderHighlight = Color(0xFF35403A);

  // Status & destructive tokens
  static const warning = accentWarm;
  static const warningSoft = accentWarmSoft;
  static const error = Color(0xFFE07A74);
  static const errorSoft = Color(0xFF2F1D1C);

  /// Opaque surface-blended tint for smooth card gradients without
  /// letting the darker scaffold background bleed through mid-stops.
  static Color surfaceTint(
    Color accent,
    double alpha, [
    Color base = surface,
  ]) => Color.alphaBlend(accent.withValues(alpha: alpha), base);
}
