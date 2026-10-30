import 'dart:async';
import 'package:flutter/material.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/theme/app_colors.dart';
import 'package:magd_pbl/theme/app_spacing.dart';

class CountdownText extends StatefulWidget {
  const CountdownText({super.key, required this.deadline});

  final DateTime deadline;

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final info = deadlineInfo(widget.deadline, DateTime.now());
    final color = AppColors.statusColor(info.status, brightness);
    final icon = switch (info.status) {
      DeadlineStatus.critical => Icons.priority_high_rounded,
      DeadlineStatus.warning => Icons.schedule_rounded,
      DeadlineStatus.safe => Icons.event_available_rounded,
      DeadlineStatus.expired => Icons.event_busy_rounded,
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.statusTint(info.status, brightness),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            info.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onSurface
                  : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
