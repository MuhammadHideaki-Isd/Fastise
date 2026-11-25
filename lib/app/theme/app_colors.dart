import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF7F8F5);
  static const surface = Colors.white;
  static const primary = Color(0xFF426B5A);
  static const primaryDark = Color(0xFF294A3D);
  static const primarySoft = Color(0xFFE8F0EB);
  static const textPrimary = Color(0xFF202722);
  // Darker than the blueprint's #737D76 (~3.9:1) to reach ~5.4:1 on background.
  static const textSecondary = Color(0xFF5E6861);
  static const border = Color(0xFFE5E9E5);
  static const warning = Color(0xFFD99A45);
  static const error = Color(0xFFC65B54);
}
