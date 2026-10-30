import 'package:flutter/material.dart';
import 'package:magd_pbl/theme/app_colors.dart';
import 'package:magd_pbl/theme/app_radii.dart';
import 'package:magd_pbl/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final colors = ColorScheme.fromSeed(
      seedColor: dark ? AppColors.primaryDark : AppColors.primaryLight,
      brightness: brightness,
      surface: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
    );
    final text = AppTextStyles.textTheme(brightness);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transparent,
        foregroundColor: dark
            ? AppColors.textPrimaryDark
            : AppColors.surfaceLight,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
        surfaceTintColor: AppColors.transparent,
        elevation: dark ? 0 : 1,
        shadowColor: const Color(0x0F0B1B3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(
            color: dark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 0,
        backgroundColor: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: dark
            ? AppColors.primaryContainerDark
            : AppColors.primarySoftLight,
        labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: dark
            ? AppColors.primaryContainerDark
            : AppColors.primarySoftLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.surfaceAltDark : AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(
            color: dark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(
            color: dark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
        ),
      ),
    );
  }
}
