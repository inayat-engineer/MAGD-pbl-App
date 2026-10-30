import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magd_pbl/theme/app_colors.dart';

double _contrast(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + .05) / (darker + .05);
}

void main() {
  test('light and dark token pairs meet WCAG contrast', () {
    final pairs = [
      (AppColors.textPrimaryLight, AppColors.backgroundLight),
      (AppColors.textSecondaryLight, AppColors.backgroundLight),
      (AppColors.textTertiaryLight, AppColors.surfaceLight),
      (AppColors.surfaceLight, AppColors.primaryLight),
      (AppColors.textPrimaryDark, AppColors.backgroundDark),
      (AppColors.textSecondaryDark, AppColors.surfaceDark),
      (AppColors.textTertiaryDark, AppColors.surfaceDark),
      (AppColors.surfaceLight, AppColors.headerEndLight),
      (AppColors.textPrimaryLight, AppColors.criticalTintLight),
      (AppColors.textPrimaryLight, AppColors.warningTintLight),
      (AppColors.safeLight, AppColors.safeTintLight),
      (AppColors.expiredLight, AppColors.expiredTintLight),
    ];
    for (final pair in pairs) {
      expect(_contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
    }
  });
}
