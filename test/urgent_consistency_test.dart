import 'package:flutter_test/flutter_test.dart';
import 'package:magd_pbl/models/notice.dart';

void main() {
  test('urgent selector excludes expired notices everywhere', () {
    final now = DateTime(2026, 10, 30);
    final notices = [
      Notice(
        id: 'active',
        title: 'Active',
        description: '',
        category: NoticeCategory.exams,
        department: 'All departments',
        semester: 'All',
        postedBy: 'Office',
        postedAt: now,
        deadline: now.add(const Duration(days: 1)),
        isUrgent: true,
      ),
      Notice(
        id: 'expired',
        title: 'Expired',
        description: '',
        category: NoticeCategory.fees,
        department: 'All departments',
        semester: 'All',
        postedBy: 'Office',
        postedAt: now,
        deadline: now.subtract(const Duration(days: 1)),
        isUrgent: true,
      ),
    ];
    final urgent = notices.where((notice) => notice.isCurrentlyUrgent(now));
    expect(urgent.length, 1);
    expect(urgent.first.id, 'active');
  });
}
