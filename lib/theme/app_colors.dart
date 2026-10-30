import 'package:flutter/material.dart';
import 'package:magd_pbl/models/notice.dart';

abstract final class AppColors {
  static const navy = primaryLight;
  static const deeperNavy = headerStartDark;
  static const border = outlineLight;
  static const neutral = textTertiaryLight;
  static const gold = goldLight;
  static const critical = criticalLight;
  static const transparent = Color(0x00000000);
  static const backgroundLight = Color(0xFFF4F6FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceAltLight = Color(0xFFEEF2F8);
  static const outlineLight = Color(0xFFDDE3EE);
  static const textPrimaryLight = Color(0xFF0B1B3A);
  static const textSecondaryLight = Color(0xFF44546F);
  static const textTertiaryLight = Color(0xFF5E6B85);
  static const primaryLight = Color(0xFF0D2B5E);
  static const primarySoftLight = Color(0xFFE6ECF7);

  static const backgroundDark = Color(0xFF0A1120);
  static const surfaceDark = Color(0xFF121B2F);
  static const surfaceAltDark = Color(0xFF1B2742);
  static const outlineDark = Color(0xFF2A3756);
  static const textPrimaryDark = Color(0xFFEDF2FC);
  static const textSecondaryDark = Color(0xFFB4C0D8);
  static const textTertiaryDark = Color(0xFF93A1BE);
  static const primaryDark = Color(0xFF8DB0FF);
  static const primaryContainerDark = Color(0xFF1E3A78);

  static const goldLight = Color(0xFFC9A227);
  static const goldDark = Color(0xFFE3BE4A);
  static const headerEndLight = Color(0xFF1A4BA0);
  static const headerStartDark = Color(0xFF091D45);
  static const headerEndDark = Color(0xFF12347A);

  static const criticalLight = Color(0xFFB42318);
  static const criticalTintLight = Color(0xFFFEE4E2);
  static const warningLight = Color(0xFF8A5300);
  static const warningTintLight = Color(0xFFFFF1CC);
  static const safeLight = Color(0xFF05603A);
  static const safeTintLight = Color(0xFFD1FADF);
  static const expiredLight = Color(0xFF475467);
  static const expiredTintLight = Color(0xFFEAECF0);

  static const criticalDark = Color(0xFFFF8A80);
  static const warningDark = Color(0xFFFFC857);
  static const safeDark = Color(0xFF5BE3A2);
  static const expiredDark = Color(0xFFA0AEC8);

  static Color categoryColor(NoticeCategory category, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (category) {
      NoticeCategory.exams =>
        dark ? const Color(0xFF8DB0FF) : const Color(0xFF2F5FD0),
      NoticeCategory.fees =>
        dark ? const Color(0xFF4FD1C5) : const Color(0xFF0B7A75),
      NoticeCategory.events =>
        dark ? const Color(0xFFB79CFF) : const Color(0xFF7A3FD1),
      NoticeCategory.scholarships =>
        dark ? const Color(0xFFF08CC3) : const Color(0xFFA8206F),
    };
  }

  static Color categoryTint(NoticeCategory category, Brightness brightness) =>
      categoryColor(
        category,
        brightness,
      ).withAlpha(brightness == Brightness.dark ? 51 : 31);

  static Color statusColor(DeadlineStatus status, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (status) {
      DeadlineStatus.critical => dark ? criticalDark : criticalLight,
      DeadlineStatus.warning => dark ? warningDark : warningLight,
      DeadlineStatus.safe => dark ? safeDark : safeLight,
      DeadlineStatus.expired => dark ? expiredDark : expiredLight,
    };
  }

  static Color statusTint(DeadlineStatus status, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    if (dark) return statusColor(status, brightness).withAlpha(41);
    return switch (status) {
      DeadlineStatus.critical => criticalTintLight,
      DeadlineStatus.warning => warningTintLight,
      DeadlineStatus.safe => safeTintLight,
      DeadlineStatus.expired => expiredTintLight,
    };
  }

  static Color deadlineColor(DeadlineStatus status) =>
      statusColor(status, Brightness.light);

  static Color deadlineSoftColor(DeadlineStatus status) =>
      statusTint(status, Brightness.light);
}
