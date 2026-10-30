import 'package:flutter_test/flutter_test.dart';
import 'package:magd_pbl/utils/percentages.dart';

void main() {
  test('largest remainder percentages always sum to 100', () {
    final values = largestRemainderPercentages([1, 1, 1, 1, 1, 1, 1]);
    expect(values.reduce((a, b) => a + b), 100);
  });
}
