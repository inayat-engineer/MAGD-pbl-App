import 'package:flutter_test/flutter_test.dart';
import 'package:magd_pbl/models/notice.dart';

void main() {
  final now = DateTime(2026, 10, 30, 12);

  test('deadline is critical under 24 hours', () {
    final result = deadlineInfo(DateTime(2026, 10, 30, 20), now);
    expect(result.status, DeadlineStatus.critical);
    expect(result.label, 'Due today');
  });

  test('deadline is warning within three days', () {
    final result = deadlineInfo(DateTime(2026, 11, 1, 17), now);
    expect(result.status, DeadlineStatus.warning);
    expect(result.label, '2 days left');
  });

  test('deadline is safe beyond three days', () {
    final result = deadlineInfo(DateTime(2026, 11, 10, 17), now);
    expect(result.status, DeadlineStatus.safe);
    expect(result.label, '11 days left');
  });

  test('deadline is expired in the past', () {
    final result = deadlineInfo(DateTime(2026, 10, 29, 17), now);
    expect(result.status, DeadlineStatus.expired);
    expect(result.label, 'Expired today');
  });

  test('critical deadline can show remaining hours', () {
    final result = deadlineInfo(DateTime(2026, 10, 31, 1), now);
    expect(result.status, DeadlineStatus.critical);
    expect(result.label, '13 hours left');
  });
}
