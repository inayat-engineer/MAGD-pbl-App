import 'package:flutter/material.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/theme/app_colors.dart';
import 'package:magd_pbl/theme/app_spacing.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final NoticeCategory? category;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = category == null
        ? (brightness == Brightness.dark
              ? AppColors.primaryDark
              : AppColors.primaryLight)
        : AppColors.categoryColor(category!, brightness);
    final background = selected ? color : Theme.of(context).cardColor;
    final foreground = selected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: '${category?.label ?? 'All'} category filter',
      child: AnimatedContainer(
        duration: AppDurations.normal,
        height: 40,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: selected ? color : AppColors.outlineLight),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category?.icon ?? Icons.apps_rounded,
                  size: 18,
                  color: foreground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  category?.label ?? 'All',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: foreground),
                ),
                if (count != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.surfaceLight.withAlpha(35)
                          : AppColors.surfaceAltLight,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(
                      '$count',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: foreground),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
