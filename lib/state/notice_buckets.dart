import 'package:magd_pbl/models/notice.dart';

enum NoticeBucket { today, nextSevenDays, later, expired }

class NoticeBuckets {
  const NoticeBuckets({
    required this.today,
    required this.nextSevenDays,
    required this.later,
    required this.expired,
  });

  final List<Notice> today;
  final List<Notice> nextSevenDays;
  final List<Notice> later;
  final List<Notice> expired;

  static NoticeBuckets group(List<Notice> notices, DateTime now) {
    final today = <Notice>[];
    final next = <Notice>[];
    final later = <Notice>[];
    final expired = <Notice>[];
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 7));
    for (final notice in notices) {
      if (notice.deadline.isBefore(now)) {
        expired.add(notice);
      } else if (notice.deadline.isBefore(start.add(const Duration(days: 1)))) {
        today.add(notice);
      } else if (notice.deadline.isBefore(end)) {
        next.add(notice);
      } else {
        later.add(notice);
      }
    }
    today.sort((a, b) => a.deadline.compareTo(b.deadline));
    next.sort((a, b) => a.deadline.compareTo(b.deadline));
    later.sort((a, b) => a.deadline.compareTo(b.deadline));
    expired.sort((a, b) => b.deadline.compareTo(a.deadline));
    return NoticeBuckets(
      today: today,
      nextSevenDays: next,
      later: later,
      expired: expired,
    );
  }
}
