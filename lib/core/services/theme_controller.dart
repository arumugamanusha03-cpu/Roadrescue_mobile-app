import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The customer's theme choice (Settings → Theme), saved on the device.
class ThemeController extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  /// Loaded in main() before the first frame so the app never flashes the
  /// wrong theme.
  static ThemeMode initial = ThemeMode.dark;

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      initial =
          ThemeMode.values.asNameMap()[prefs.getString(_key)] ?? ThemeMode.dark;
    } catch (_) {
      // Storage unavailable (tests, private browsing): keep the default.
    }
  }

  @override
  ThemeMode build() => initial;

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {}
  }
}

final themeModeProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
