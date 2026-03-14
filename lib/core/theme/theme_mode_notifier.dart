import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModeKey = 'theme_mode';

/// Notifier that holds the app [ThemeMode] and persists it via [SharedPreferences].
class ThemeModeNotifier extends ChangeNotifier {
  ThemeModeNotifier(this._themeMode);

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  static const int _systemIndex = -1;
  static const int _lightIndex = 0;
  static const int _darkIndex = 1;

  /// Loads saved theme mode from [SharedPreferences]. Call before [runApp].
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeModeKey) ?? _systemIndex;
    return _themeModeFromIndex(index);
  }

  static ThemeMode _themeModeFromIndex(int index) {
    switch (index) {
      case _lightIndex:
        return ThemeMode.light;
      case _darkIndex:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static int _indexFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return _lightIndex;
      case ThemeMode.dark:
        return _darkIndex;
      case ThemeMode.system:
        return _systemIndex;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, _indexFromThemeMode(mode));
    notifyListeners();
  }
}
