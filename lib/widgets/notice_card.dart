import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/theme/app_colors.dart';
import 'package:magd_pbl/theme/app_spacing.dart';
import 'package:magd_pbl/widgets/countdown_text.dart';

class NoticeCard extends StatefulWidget {
  const NoticeCard({
    super.key,
    required this.notice,
    required this.onTap,
    this.selected = false,
  });

  final Notice notice;
  final VoidCallback onTap;
  final bool selected;

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  bool _pressed = false;
  bool _hovered = false;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final info = deadlineInfo(widget.notice.deadline, DateTime.now());
    final expired = info.status == DeadlineStatus.expired;
    final categoryColor = AppColors.categoryColor(
      widget.notice.category,
      brightness,
    );
    final iconColor = expired
        ? (brightness == Brightness.dark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight)
        : categoryColor;
    final borderColor = widget.selected
        ? (brightness == Brightness.dark
              ? AppColors.primaryDark
              : AppColors.primaryLight)
        : _focusNode.hasFocus
        ? (brightness == Brightness.dark
              ? AppColors.goldDark
              : AppColors.goldLight)
        : _hovered
        ? (brightness == Brightness.dark
              ? AppColors.primaryDark
              : AppColors.primaryLight)
        : (brightness == Brightness.dark
              ? AppColors.outlineDark
              : AppColors.outlineLight);
    return FocusableActionDetector(
      focusNode: _focusNode,
      onShowFocusHighlight: (_) => setState(() {}),
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      child: AnimatedScale(
        scale: _pressed ? .985 : 1,
        duration: AppDurations.fast,
        child: Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: BorderSide(
              color: borderColor,
              width: widget.selected || _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IconTile(
                        notice: widget.notice,
                        color: iconColor,
                        expired: expired,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _CardHeader(
                          notice: widget.notice,
                          expired: expired,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.notice.description,
                    maxLines: MediaQuery.sizeOf(context).width >= 600 ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Divider(
                    height: 1,
                    color: brightness == Brightness.dark
                        ? AppColors.outlineDark
                        : AppColors.outlineLight,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _dateLabel(widget.notice),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: brightness == Brightness.dark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      CountdownText(deadline: widget.notice.deadline),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _dateLabel(Notice notice) {
    final format = DateFormat('EEE, d MMM · h:mm a');
    final prefix = switch (notice.dateKind) {
      NoticeDateKind.deadline => 'Due',
      NoticeDateKind.event => 'Event',
      NoticeDateKind.examStart => 'Exams start',
    };
    return '$prefix ${format.format(notice.deadline)}';
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.notice,
    required this.color,
    required this.expired,
  });

  final Notice notice;
  final Color color;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: expired
                ? (brightness == Brightness.dark
                      ? AppColors.surfaceAltDark
                      : AppColors.expiredTintLight)
                : AppColors.categoryTint(notice.category, brightness),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(notice.category.icon, color: color),
        ),
        if (!notice.isRead && !expired)
          Positioned(
            top: -AppSpacing.xxs,
            right: -AppSpacing.xxs,
            child: Container(
              width: AppSpacing.xs,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: brightness == Brightness.dark
                    ? AppColors.goldDark
                    : AppColors.goldLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.notice, required this.expired});

  final Notice notice;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final posted = DateFormat('d MMM, h:mm a').format(notice.postedAt);
    final textColor = brightness == Brightness.dark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiaryLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xxs,
          children: [
            Text(
              notice.category.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!expired && notice.isCurrentlyUrgent(DateTime.now()))
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.statusTint(
                    DeadlineStatus.critical,
                    brightness,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.priority_high_rounded,
                        size: 14,
                        color: AppColors.statusColor(
                          DeadlineStatus.critical,
                          brightness,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        'URGENT',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.statusColor(
                            DeadlineStatus.critical,
                            brightness,
                          ),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          notice.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: expired
                ? (brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)
                : null,
            fontWeight: notice.isRead ? FontWeight.w600 : FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '${notice.postedBy} · Posted $posted',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: textColor),
        ),
      ],
    );
  }
}
