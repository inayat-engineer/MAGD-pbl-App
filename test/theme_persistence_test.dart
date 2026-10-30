import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magd_pbl/state/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists and restores the selected theme mode', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = ThemeController.initial();

    await controller.setMode(ThemeMode.dark);
    final restored = await ThemeController.load();

    expect(restored.mode, ThemeMode.dark);
    controller.dispose();
    restored.dispose();
  });
}
