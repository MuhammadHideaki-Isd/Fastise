import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData dark() {
    final baseText = ThemeData.dark(useMaterial3: true).textTheme;
    final textTheme = baseText
        .apply(
          fontFamily: AppColors.fontBody,
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        )
        .copyWith(
          displayLarge: baseText.displayLarge?.copyWith(
            fontFamily: AppColors.fontDisplay,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: baseText.displayMedium?.copyWith(
            fontFamily: AppColors.fontDisplay,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          displaySmall: baseText.displaySmall?.copyWith(
            fontFamily: AppColors.fontDisplay,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
          headlineLarge: baseText.headlineLarge?.copyWith(
            fontFamily: AppColors.fontDisplay,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: baseText.headlineMedium?.copyWith(
            fontFamily: AppColors.fontDisplay,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: baseText.headlineSmall?.copyWith(
            fontFamily: AppColors.fontDisplay,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleLarge: baseText.titleLarge?.copyWith(
            fontFamily: AppColors.fontDisplay,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          titleMedium: baseText.titleMedium?.copyWith(
            fontFamily: AppColors.fontDisplay,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          titleSmall: baseText.titleSmall?.copyWith(
            fontFamily: AppColors.fontBody,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: baseText.bodyLarge?.copyWith(
            fontFamily: AppColors.fontBody,
            color: AppColors.textPrimary,
          ),
          bodyMedium: baseText.bodyMedium?.copyWith(
            fontFamily: AppColors.fontBody,
            color: AppColors.textPrimary,
          ),
          bodySmall: baseText.bodySmall?.copyWith(
            fontFamily: AppColors.fontBody,
            color: AppColors.textSecondary,
          ),
          labelLarge: baseText.labelLarge?.copyWith(
            fontFamily: AppColors.fontBody,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: baseText.labelMedium?.copyWith(
            fontFamily: AppColors.fontBody,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: baseText.labelSmall?.copyWith(
            fontFamily: AppColors.fontBody,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        );

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.accentWarm,
          onSecondary: AppColors.onPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          outline: AppColors.border,
        );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppColors.fontBody,
      textTheme: textTheme,
      useMaterial3: true,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: overlayStyle,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppColors.fontDisplay,
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: AppColors.fontBody,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: AppColors.fontDisplay,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.borderHighlight, width: 1.2),
          textStyle: const TextStyle(
            fontFamily: AppColors.fontDisplay,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: AppColors.fontBody,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primarySoft;
            }
            return AppColors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryBright;
            }
            return AppColors.textSecondary;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(
                color: AppColors.primary.withValues(alpha: 0.45),
              );
            }
            return const BorderSide(color: AppColors.border);
          }),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: AppColors.fontDisplay,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: AppColors.borderHighlight),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surfaceElevated,
        dragHandleColor: AppColors.borderHighlight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          side: BorderSide(color: AppColors.borderHighlight),
        ),
      ),
    );
  }

  /// Retained as an alias so any caller referencing `AppTheme.light()`
  /// receives the unified Obsidian & Soft Sage Mint theme.
  static ThemeData light() => dark();
}
