import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magd_pbl/models/notice.dart';
import 'package:magd_pbl/theme/app_gradients.dart';

void main() {
  test('destination and category gradients contain dark readable stops', () {
    for (final brightness in Brightness.values) {
      final gradients = [
        AppGradients.forContext('notices', null, brightness),
        AppGradients.forContext('summary', null, brightness),
        for (final category in NoticeCategory.values)
          AppGradients.forContext('notices', category, brightness),
      ];

      for (final gradient in gradients) {
        for (final color in gradient.colors) {
          expect(
            ThemeData.estimateBrightnessForColor(color),
            Brightness.dark,
          );
        }
      }
    }
  });
}
