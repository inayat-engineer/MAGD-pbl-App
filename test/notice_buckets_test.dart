import 'package:flutter_test/flutter_test.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/state/notice_buckets.dart';

void main() {
  test('buckets use a rolling seven-day window and strict ordering', () {
    final now = DateTime(2026, 10, 30, 12);
    Notice make(String id, DateTime deadline) => Notice(
      id: id,
      title: id,
      description: id,
      category: NoticeCategory.exams,
      department: 'All departments',
      semester: 'All',
      postedBy: 'Office',
      postedAt: now,
      deadline: deadline,
      isUrgent: false,
    );
    final buckets = NoticeBuckets.group([
      make('later', DateTime(2026, 11, 10)),
      make('next-late', DateTime(2026, 11, 5)),
      make('next-early', DateTime(2026, 10, 31)),
      make('today-late', DateTime(2026, 10, 30, 18)),
      make('today-early', DateTime(2026, 10, 30, 13)),
      make('expired-old', DateTime(2026, 10, 1)),
      make('expired-new', DateTime(2026, 10, 29)),
    ], now);
    expect(buckets.today.map((item) => item.id), ['today-early', 'today-late']);
    expect(buckets.nextSevenDays.map((item) => item.id), [
      'next-early',
      'next-late',
    ]);
    expect(buckets.later.map((item) => item.id), ['later']);
    expect(buckets.expired.map((item) => item.id), [
      'expired-new',
      'expired-old',
    ]);
  });
}
