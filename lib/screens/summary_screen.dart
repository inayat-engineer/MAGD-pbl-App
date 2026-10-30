import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/state/notice_buckets.dart';
import 'package:magd_pbl/state/notice_controller.dart';
import 'package:magd_pbl/theme/app_colors.dart';
import 'package:magd_pbl/theme/app_spacing.dart';
import 'package:magd_pbl/utils/percentages.dart';
import 'package:magd_pbl/utils/strings.dart';
import 'package:magd_pbl/widgets/countdown_text.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.controller});

  final NoticeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final now = DateTime.now();
        final buckets = NoticeBuckets.group(controller.filteredNotices(), now);
        final upcoming = [...buckets.today, ...buckets.nextSevenDays];
        final next = upcoming.isEmpty ? null : upcoming.first;
        final dueCount = buckets.today.length + buckets.nextSevenDays.length;
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                pinned: true,
                title: Text(AppStrings.summary),
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.surfaceLight,
                scrolledUnderElevation: 0,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _KpiRow(
                      total: controller.notices.length,
                      urgent: controller.visibleUrgentCount,
                      due: dueCount,
                    ),
                    if (next != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Next deadline',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _NextDeadlineCard(
                        notice: next,
                        onTap: () => context.push('/notices/${next.id}'),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _DistributionCard(
                      notices: controller.notices,
                      onCategoryTap: controller.setCategory,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _WeekStrip(
                      notices: controller.notices,
                      selectedDay: controller.selectedDay,
                      onDayTap: (day) => controller.setSelectedDay(
                        _sameDay(controller.selectedDay, day)
                            ? null
                            : day,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Due this week',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...upcoming
                        .take(4)
                        .map(
                          (notice) => _DueTile(
                            notice: notice,
                            onTap: () => context.push('/notices/${notice.id}'),
                          ),
                        ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _sameDay(DateTime? first, DateTime second) =>
      first != null &&
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.total, required this.urgent, required this.due});

  final int total;
  final int urgent;
  final int due;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _Kpi(
        label: 'Total notices',
        value: total,
        icon: Icons.notifications_rounded,
      ),
      _Kpi(
        label: 'Urgent',
        value: urgent,
        icon: Icons.priority_high_rounded,
      ),
      _Kpi(
        label: 'Due in 7 days',
        value: due,
        icon: Icons.event_available_rounded,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 1;
        final width = columns == 3
            ? (constraints.maxWidth - AppSpacing.sm * 2) / 3
            : constraints.maxWidth;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: cards
              .map((card) => SizedBox(width: width, child: card))
              .toList(),
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.icon});

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isUrgent = label == 'Urgent';
    final iconColor = isUrgent
        ? AppColors.statusColor(DeadlineStatus.critical, brightness)
        : (brightness == Brightness.dark
              ? AppColors.primaryDark
              : AppColors.primaryLight);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppSpacing.xl + AppSpacing.sm,
              height: AppSpacing.xl + AppSpacing.sm,
              decoration: BoxDecoration(
                color: AppColors.statusTint(
                  isUrgent ? DeadlineStatus.critical : DeadlineStatus.safe,
                  brightness,
                ),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.xs),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.toDouble()),
              duration: AppDurations.crossFade,
              builder: (context, current, _) => Text(
                '${current.round()}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _NextDeadlineCard extends StatelessWidget {
  const _NextDeadlineCard({required this.notice, required this.onTap});

  final Notice notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.categoryTint(
                    notice.category,
                    Theme.of(context).brightness,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  notice.category.icon,
                  color: AppColors.categoryColor(
                    notice.category,
                    Theme.of(context).brightness,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notice.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Due ${DateFormat('EEE, d MMM · h:mm a').format(notice.deadline)}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              CountdownText(deadline: notice.deadline),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.notices, required this.onCategoryTap});

  final List<Notice> notices;
  final ValueChanged<NoticeCategory?> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final counts = NoticeCategory.values
        .map(
          (category) =>
              notices.where((notice) => notice.category == category).length,
        )
        .toList();
    final percentages = largestRemainderPercentages(counts);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By category', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 560;
                final chart = SizedBox(
                  width: compact ? 180 : 220,
                  height: compact ? 180 : 220,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : AppDurations.donut,
                    curve: Curves.easeOutCubic,
                    builder: (context, progress, _) => CustomPaint(
                      painter: _DonutPainter(
                        notices: notices,
                        progress: progress,
                        brightness: Theme.of(context).brightness,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${notices.length}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'notices',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                final legend = Column(
                  children: List.generate(NoticeCategory.values.length, (
                    index,
                  ) {
                    final category = NoticeCategory.values[index];
                    return InkWell(
                      onTap: () => onCategoryTap(category),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Icon(category.icon, size: AppSpacing.md),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(child: Text(category.label)),
                            Text('${counts[index]} · ${percentages[index]}%'),
                          ],
                        ),
                      ),
                    );
                  }),
                );
                return compact
                    ? Column(
                        children: [
                          chart,
                          const SizedBox(height: AppSpacing.md),
                          legend,
                        ],
                      )
                    : Row(
                        children: [
                          chart,
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: legend),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.notices,
    required this.progress,
    required this.brightness,
  });

  final List<Notice> notices;
  final double progress;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final total = notices.length;
    if (total == 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.sm + AppSpacing.xs;
    var start = -math.pi / 2;
    for (final category in NoticeCategory.values) {
      final count = notices
          .where((notice) => notice.category == category)
          .length;
      final sweep = count / total * math.pi * 2 * progress;
      paint.color = AppColors.categoryColor(category, brightness);
      canvas.drawArc(Offset.zero & size, start, sweep, false, paint);
      start += sweep + .03;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.notices != notices;
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.notices,
    required this.selectedDay,
    required this.onDayTap,
  });

  final List<Notice> notices;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Next 7 days', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = start.add(Duration(days: index));
                final matching = notices.where(
                  (notice) =>
                      notice.deadline.year == day.year &&
                      notice.deadline.month == day.month &&
                      notice.deadline.day == day.day,
                );
                final hasDeadline = matching.isNotEmpty;
                final isToday = index == 0;
                final isSelected =
                    selectedDay != null &&
                    selectedDay!.year == day.year &&
                    selectedDay!.month == day.month &&
                    selectedDay!.day == day.day;
                return InkWell(
                  onTap: () => onDayTap(day),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxs),
                    child: Column(
                      children: [
                        Text(
                          isToday
                              ? 'Today'
                              : DateFormat('E').format(day).substring(0, 1),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Container(
                          width: AppSpacing.xl,
                          height: AppSpacing.xl,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isToday
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer
                                : null,
                          ),
                          child: Text('${day.day}'),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Icon(
                          hasDeadline ? Icons.circle : Icons.circle_outlined,
                          size: AppSpacing.xxs,
                          color: hasDeadline
                              ? AppColors.goldLight
                              : AppColors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap a day to filter notices by deadline.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DueTile extends StatelessWidget {
  const _DueTile({required this.notice, required this.onTap});

  final Notice notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          notice.category.icon,
          color: AppColors.categoryColor(
            notice.category,
            Theme.of(context).brightness,
          ),
        ),
        title: Text(notice.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(DateFormat('EEE, d MMM').format(notice.deadline)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
