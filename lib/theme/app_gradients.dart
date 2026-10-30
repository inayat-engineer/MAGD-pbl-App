import 'package:flutter/material.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/theme/app_colors.dart';

abstract final class AppGradients {
  static LinearGradient forContext(
    String destination,
    NoticeCategory? category,
    Brightness brightness,
  ) {
    final dark = brightness == Brightness.dark;
    if (category != null) {
      final categoryColor = AppColors.categoryColor(category, brightness);
      final base = dark ? AppColors.headerStartDark : AppColors.primaryLight;
      return LinearGradient(
        colors: [base, Color.lerp(base, categoryColor, .42)!],
      );
    }
    return switch (destination) {
      'summary' => LinearGradient(
        colors: dark
            ? [AppColors.headerStartDark, const Color(0xFF12565C)]
            : [AppColors.primaryLight, const Color(0xFF087F8C)],
      ),
      _ => LinearGradient(
        colors: dark
            ? [AppColors.headerStartDark, AppColors.headerEndDark]
            : [AppColors.primaryLight, AppColors.headerEndLight],
      ),
    };
  }
}
