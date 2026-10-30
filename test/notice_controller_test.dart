import 'package:flutter_test/flutter_test.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/state/notice_controller.dart';

void main() {
  final now = DateTime(2026, 10, 30, 12);
  final notices = [
    Notice(
      id: 'later',
      title: 'Later',
      description: 'Scholarship',
      category: NoticeCategory.scholarships,
      department: 'CS',
      semester: 'Semester 4',
      postedBy: 'Office',
      postedAt: now,
      deadline: DateTime(2026, 11, 10),
      isUrgent: false,
    ),
    Notice(
      id: 'urgent',
      title: 'Urgent exam',
      description: 'Exam schedule',
      category: NoticeCategory.exams,
      department: 'CS',
      semester: 'Semester 4',
      postedBy: 'Exam Office',
      postedAt: now,
      deadline: DateTime(2026, 11, 1),
      isUrgent: true,
    ),
    Notice(
      id: 'expired',
      title: 'Old fee',
      description: 'Fee',
      category: NoticeCategory.fees,
      department: 'EE',
      semester: 'Semester 2',
      postedBy: 'Finance',
      postedAt: now,
      deadline: DateTime(2026, 10, 1),
      isUrgent: true,
    ),
  ];

  test('filters by category, department, semester, and search', () {
    final controller = NoticeController(notices)
      ..setCategory(NoticeCategory.exams)
      ..setDepartment('CS')
      ..setSemester('Semester 4')
      ..setSearchQuery('schedule');
    expect(controller.filteredNotices(now).map((notice) => notice.id), [
      'urgent',
    ]);
  });

  test('sorts urgent nearest first and expired last', () {
    final controller = NoticeController(notices);
    final result = controller.filteredNotices(now);
    expect(result.map((notice) => notice.id), ['urgent', 'later', 'expired']);
  });

  test('marks notices as read', () {
    final controller = NoticeController(notices);
    controller.markAsRead('urgent');
    expect(
      controller.notices.firstWhere((notice) => notice.id == 'urgent').isRead,
      isTrue,
    );
  });
}
