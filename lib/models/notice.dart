import 'package:flutter/material.dart';

enum NoticeCategory {
  exams,
  fees,
  events,
  scholarships;

  String get label => switch (this) {
    exams => 'Exams',
    fees => 'Fees',
    events => 'Events',
    scholarships => 'Scholarships',
  };

  IconData get icon => switch (this) {
    exams => Icons.school_rounded,
    fees => Icons.payments_rounded,
    events => Icons.celebration_rounded,
    scholarships => Icons.workspace_premium_rounded,
  };
}

enum NoticeDateKind { deadline, event, examStart }

enum DeadlineStatus { expired, critical, warning, safe }

class DeadlineInfo {
  const DeadlineInfo({required this.status, required this.label});

  final DeadlineStatus status;
  final String label;
}

DeadlineInfo deadlineInfo(DateTime deadline, DateTime now) {
  final difference = deadline.difference(now);
  if (difference.isNegative) {
    final days = now.difference(deadline).inDays;
    return DeadlineInfo(
      status: DeadlineStatus.expired,
      label: days == 0 ? 'Expired today' : 'Expired $days days ago',
    );
  }
  if (deadline.year == now.year &&
      deadline.month == now.month &&
      deadline.day == now.day) {
    return const DeadlineInfo(
      status: DeadlineStatus.critical,
      label: 'Due today',
    );
  }
  if (difference.inMinutes < 60) {
    return DeadlineInfo(
      status: DeadlineStatus.critical,
      label: '${difference.inMinutes.clamp(1, 59)} min left',
    );
  }
  if (difference.inHours < 24) {
    return DeadlineInfo(
      status: DeadlineStatus.critical,
      label: '${difference.inHours} hours left',
    );
  }
  final days = difference.inDays;
  return DeadlineInfo(
    status: days < 3 ? DeadlineStatus.warning : DeadlineStatus.safe,
    label: '$days ${days == 1 ? 'day' : 'days'} left',
  );
}

class Notice {
  const Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.department,
    required this.semester,
    required this.postedBy,
    required this.postedAt,
    required this.deadline,
    required this.isUrgent,
    this.dateKind = NoticeDateKind.deadline,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final NoticeCategory category;
  final String department;
  final String semester;
  final String postedBy;
  final DateTime postedAt;
  final DateTime deadline;
  final bool isUrgent;
  final NoticeDateKind dateKind;
  final bool isRead;

  bool isExpired(DateTime now) => deadline.isBefore(now);
  bool isCurrentlyUrgent(DateTime now) => isUrgent && !isExpired(now);

  Notice copyWith({bool? isRead}) => Notice(
    id: id,
    title: title,
    description: description,
    category: category,
    department: department,
    semester: semester,
    postedBy: postedBy,
    postedAt: postedAt,
    deadline: deadline,
    isUrgent: isUrgent,
    dateKind: dateKind,
    isRead: isRead ?? this.isRead,
  );
}
