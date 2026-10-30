import 'package:flutter/foundation.dart';
import 'package:magd_pbl/models/notice.dart';

class NoticeController extends ChangeNotifier {
  NoticeController(List<Notice> notices) : _notices = List.of(notices);

  final List<Notice> _notices;
  NoticeCategory? selectedCategory;
  String? selectedDepartment;
  String? selectedSemester;
  String searchQuery = '';
  bool urgentOnly = false;
  DateTime? selectedDay;
  String? selectedNoticeId;
  final Set<String> _reminders = {};

  List<Notice> get notices => List.unmodifiable(_notices);
  bool hasReminder(String id) => _reminders.contains(id);
  int get urgentCount => _notices.where((notice) => notice.isUrgent).length;
  int get visibleUrgentCount => filteredNotices().where((notice) {
    return notice.isCurrentlyUrgent(DateTime.now());
  }).length;
  List<String> get departments =>
      _notices.map((notice) => notice.department).toSet().toList();
  List<String> get semesters =>
      _notices.map((notice) => notice.semester).toSet().toList();

  List<Notice> filteredNotices([DateTime? now]) {
    return _filterNotices(
      now: now,
      departmentOverride: selectedDepartment,
      semesterOverride: selectedSemester,
    );
  }

  List<Notice> filteredNoticesForFilters({
    String? department,
    String? semester,
    DateTime? now,
  }) {
    return _filterNotices(
      now: now,
      departmentOverride: department,
      semesterOverride: semester,
    );
  }

  List<Notice> _filterNotices({
    DateTime? now,
    String? departmentOverride,
    String? semesterOverride,
  }) {
    final current = now ?? DateTime.now();
    final query = searchQuery.trim().toLowerCase();
    final filtered = _notices.where((notice) {
      final categoryMatch =
          selectedCategory == null || notice.category == selectedCategory;
      final departmentMatch =
          departmentOverride == null ||
          notice.department == departmentOverride;
      final semesterMatch =
          semesterOverride == null || notice.semester == semesterOverride;
      final queryMatch =
          query.isEmpty ||
          notice.title.toLowerCase().contains(query) ||
          notice.description.toLowerCase().contains(query);
      final urgentMatch = !urgentOnly || notice.isCurrentlyUrgent(current);
      final dayMatch =
          selectedDay == null ||
          (notice.deadline.year == selectedDay!.year &&
              notice.deadline.month == selectedDay!.month &&
              notice.deadline.day == selectedDay!.day);
      return categoryMatch &&
          departmentMatch &&
          semesterMatch &&
          queryMatch &&
          urgentMatch &&
          dayMatch;
    }).toList();
    filtered.sort((a, b) {
      final aExpired = a.deadline.isBefore(current);
      final bExpired = b.deadline.isBefore(current);
      if (aExpired != bExpired) return aExpired ? 1 : -1;
      return a.deadline.compareTo(b.deadline);
    });
    return filtered;
  }

  void setCategory(NoticeCategory? value) {
    selectedCategory = value;
    notifyListeners();
  }

  void setDepartment(String? value) {
    selectedDepartment = value;
    notifyListeners();
  }

  void setSemester(String? value) {
    selectedSemester = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void toggleUrgentOnly() {
    urgentOnly = !urgentOnly;
    notifyListeners();
  }

  void setSelectedDay(DateTime? value) {
    selectedDay = value;
    notifyListeners();
  }

  void clearFilters() {
    selectedCategory = null;
    selectedDepartment = null;
    selectedSemester = null;
    searchQuery = '';
    urgentOnly = false;
    selectedDay = null;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notices.indexWhere((notice) => notice.id == id);
    if (index == -1 || _notices[index].isRead) return;
    _notices[index] = _notices[index].copyWith(isRead: true);
    notifyListeners();
  }

  void selectNotice(String? id) {
    if (selectedNoticeId == id) return;
    selectedNoticeId = id;
    notifyListeners();
  }

  void toggleReminder(String id) {
    if (!_reminders.add(id)) _reminders.remove(id);
    notifyListeners();
  }
}
