import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/state/notice_controller.dart';
import 'package:magd_pbl/theme/app_colors.dart';
import 'package:magd_pbl/theme/app_gradients.dart';
import 'package:magd_pbl/theme/app_spacing.dart';
import 'package:magd_pbl/utils/strings.dart';
import 'package:magd_pbl/widgets/countdown_text.dart';

class NoticeDetailScreen extends StatefulWidget {
  const NoticeDetailScreen({
    super.key,
    required this.notice,
    required this.controller,
  });

  final Notice notice;
  final NoticeController controller;

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  Timer? _timer;
  bool _reminderSet = false;

  @override
  void initState() {
    super.initState();
    widget.controller.markAsRead(widget.notice.id);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _reminderSet = prefs.getBool(_reminderKey) ?? false);
    }
  }

  String get _reminderKey => 'reminder_${widget.notice.id}';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final status = deadlineInfo(widget.notice.deadline, DateTime.now());
    final statusColor = AppColors.statusColor(status.status, brightness);
    final isWide = MediaQuery.sizeOf(context).width >= 840;
    final date = DateFormat(
      'EEE, d MMM yyyy, h:mm a',
    ).format(widget.notice.deadline);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            foregroundColor: AppColors.surfaceLight,
            backgroundColor: AppColors.categoryColor(
              widget.notice.category,
              brightness,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.forContext(
                    'notices',
                    widget.notice.category,
                    brightness,
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: widget.notice.id,
                    child: Icon(
                      widget.notice.category.icon,
                      size: 64,
                      color: AppColors.surfaceLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xl + AppSpacing.lg,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  widget.notice.title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.statusTint(status.status, brightness),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, color: statusColor),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          '${_statusPrefix(widget.notice.dateKind)} ${status.label} · $date',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: brightness == Brightness.dark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                        ),
                      ),
                      CountdownText(deadline: widget.notice.deadline),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoGrid(notice: widget.notice),
                const SizedBox(height: AppSpacing.lg),
                SelectionArea(
                  child: Text(
                    widget.notice.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                if (isWide) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _ActionBar(
                    notice: widget.notice,
                    reminderSet: _reminderSet,
                    onReminder: _toggleReminder,
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomSheet: isWide
          ? null
          : _ActionBar(
              notice: widget.notice,
              reminderSet: _reminderSet,
              onReminder: _toggleReminder,
            ),
    );
  }

  String _statusPrefix(NoticeDateKind kind) => switch (kind) {
    NoticeDateKind.deadline => 'Due',
    NoticeDateKind.event => 'Event',
    NoticeDateKind.examStart => 'Exams start',
  };

  Future<void> _toggleReminder() async {
    final next = !_reminderSet;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, next);
    if (!mounted) return;
    setState(() => _reminderSet = next);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(next ? 'In-app reminder set' : 'Reminder removed'),
        action: next
            ? SnackBarAction(label: 'Undo', onPressed: _toggleReminder)
            : null,
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Department', notice.department),
      ('Semester', notice.semester),
      ('Posted by', notice.postedBy),
      ('Posted on', DateFormat('d MMM yyyy').format(notice.postedAt)),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 72,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.$1, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: AppSpacing.xxs),
                Expanded(
                  child: Text(
                    item.$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.notice,
    required this.reminderSet,
    required this.onReminder,
  });

  final Notice notice;
  final bool reminderSet;
  final VoidCallback onReminder;

  @override
  Widget build(BuildContext context) {
    final details = [
      notice.title,
      notice.description,
      'Deadline: ${DateFormat('EEE, d MMM yyyy, h:mm a').format(notice.deadline)}',
    ].join('\n');
    return Material(
      elevation: 3,
      color: Theme.of(context).cardColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onReminder,
                  icon: Icon(
                    reminderSet
                        ? Icons.check_rounded
                        : Icons.notifications_active_outlined,
                  ),
                  label: Text(
                    reminderSet
                        ? AppStrings.reminderSet
                        : AppStrings.setReminder,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: details));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Details copied')),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text(AppStrings.copyDetails),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
