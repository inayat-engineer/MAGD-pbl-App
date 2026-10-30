import 'package:magd_pbl/models/notice.dart';

final _now = DateTime.now();

final List<Notice> dummyNotices = [
  Notice(
    id: 'fee-challan',
    title: 'Semester Fee Challan Submission',
    description:
        'Submit your semester fee challan through the designated bank or online portal before the deadline. Keep the paid receipt for your records.',
    category: NoticeCategory.fees,
    department: 'All Departments',
    semester: 'All Semesters',
    postedBy: 'Finance Office',
    postedAt: _now.subtract(const Duration(hours: 4)),
    deadline: DateTime(_now.year, _now.month, _now.day + 2, 17),
    isUrgent: true,
  ),
  Notice(
    id: 'mid-term-schedule',
    title: 'Mid-Term Examination Schedule',
    description:
        'The provisional mid-term examination schedule is available. Report any clash to the examination section immediately.',
    category: NoticeCategory.exams,
    department: 'Computer Systems',
    semester: 'Semester 4',
    postedBy: 'Examination Office',
    postedAt: _now.subtract(const Duration(days: 1, hours: 2)),
    deadline: DateTime(_now.year, _now.month, _now.day + 7, 17),
    isUrgent: true,
  ),
  Notice(
    id: 'library-dues',
    title: 'Clearance of Library Dues',
    description:
        'Clear outstanding library books or fines to avoid a hold on examination forms and semester registration.',
    category: NoticeCategory.fees,
    department: 'All Departments',
    semester: 'All Semesters',
    postedBy: 'Central Library',
    postedAt: _now.subtract(const Duration(days: 2)),
    deadline: DateTime(_now.year, _now.month, _now.day + 1, 17),
    isUrgent: false,
  ),
  Notice(
    id: 'sports-gala',
    title: 'MUET Annual Sports Gala 2026',
    description:
        'Registrations are open for cricket, badminton, athletics, and indoor games. Submit your team registration to the Sports Office.',
    category: NoticeCategory.events,
    department: 'All Departments',
    semester: 'All Semesters',
    postedBy: 'Directorate of Sports',
    postedAt: _now.subtract(const Duration(days: 3)),
    deadline: DateTime(_now.year, _now.month, _now.day + 14, 17),
    isUrgent: false,
  ),
  Notice(
    id: 'scholarship',
    title: 'HEC Undergraduate Scholarship Applications',
    description:
        'Eligible students may apply for the HEC undergraduate scholarship. Submit a complete application to Student Financial Aid.',
    category: NoticeCategory.scholarships,
    department: 'Electrical Engineering',
    semester: 'Semester 2',
    postedBy: 'Student Financial Aid',
    postedAt: _now.subtract(const Duration(days: 2, hours: 6)),
    deadline: DateTime(_now.year, _now.month, _now.day + 10, 17),
    isUrgent: true,
  ),
  Notice(
    id: 'project-review',
    title: 'Final Year Project Review Meeting',
    description:
        'The first project review meeting will be held in the department seminar room. Bring your updated proposal and progress report.',
    category: NoticeCategory.exams,
    department: 'Mechanical Engineering',
    semester: 'Semester 8',
    postedBy: 'FYP Committee',
    postedAt: _now.subtract(const Duration(days: 4)),
    deadline: DateTime(_now.year, _now.month, _now.day + 3, 17),
    isUrgent: true,
  ),
  Notice(
    id: 'career-fair',
    title: 'Industry Career Fair Registration',
    description:
        'Register for the campus career fair to meet visiting companies and submit your CV for on-campus interviews.',
    category: NoticeCategory.events,
    department: 'All Departments',
    semester: 'Semester 8',
    postedBy: 'Career Development Centre',
    postedAt: _now.subtract(const Duration(days: 8)),
    deadline: DateTime(_now.year, _now.month, _now.day - 2, 17),
    isUrgent: false,
  ),
  Notice(
    id: 'hostel-renewal',
    title: 'Hostel Room Renewal Notice',
    description:
        'Residents who wish to continue in university hostels must submit the room renewal form and updated documents.',
    category: NoticeCategory.fees,
    department: 'Civil Engineering',
    semester: 'Semester 6',
    postedBy: 'Hostel Office',
    postedAt: _now.subtract(const Duration(days: 10)),
    deadline: DateTime(_now.year, _now.month, _now.day - 1, 17),
    isUrgent: false,
  ),
];
