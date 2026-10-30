import 'package:flutter/material.dart';
import 'package:magd_pbl/theme/app_colors.dart';
import 'package:magd_pbl/theme/app_spacing.dart';

class SkeletonNotice extends StatefulWidget {
  const SkeletonNotice({super.key});

  @override
  State<SkeletonNotice> createState() => _SkeletonNoticeState();
}

class _SkeletonNoticeState extends State<SkeletonNotice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.crossFade + AppDurations.crossFade,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        height:
            AppSpacing.xl +
            AppSpacing.xl +
            AppSpacing.xl +
            AppSpacing.xl +
            AppSpacing.sm,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          gradient: LinearGradient(
            begin: Alignment(-1 + _controller.value * 2, 0),
            end: Alignment(-.2 + _controller.value * 2, 0),
            colors: [
              dark ? AppColors.surfaceAltDark : AppColors.surfaceAltLight,
              dark ? AppColors.surfaceDark : AppColors.surfaceLight,
              dark ? AppColors.surfaceAltDark : AppColors.surfaceAltLight,
            ],
          ),
        ),
      ),
    );
  }
}
