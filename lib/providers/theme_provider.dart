import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _colorKey = 'app_color';

  String _themeMode = 'system'; // 'light', 'dark', 'system'
  String _colorTheme = 'purple'; // 'purple', 'blue', 'pink', 'green'

  ThemeProvider() {
    _load();
  }

  String get themeMode => _themeMode;
  String get colorTheme => _colorTheme;

  // ===== رنگ‌های تم (بدون نیاز به MediaQuery) =====
  static const Map<String, Map<String, Color>> colorThemes = {
    'purple': {
      'primary': Color(0xFF6C5CE7),
      'primaryDark': Color(0xFF4834D4),
      'primaryLight': Color(0xFFA29BFE),
      'surface': Color(0xFFFFFFFF),
      'background': Color(0xFFF5F7FA),
      'text': Color(0xFF1A1A2E),
      'textSecondary': Color(0xFF4A4A6A),
    },
    'blue': {
      'primary': Color(0xFF0984E3),
      'primaryDark': Color(0xFF0652DD),
      'primaryLight': Color(0xFF74B9FF),
      'surface': Color(0xFFFFFFFF),
      'background': Color(0xFFF0F4F8),
      'text': Color(0xFF1A1A2E),
      'textSecondary': Color(0xFF4A4A6A),
    },
    'pink': {
      'primary': Color(0xFFE84393),
      'primaryDark': Color(0xFFC2185B),
      'primaryLight': Color(0xFFFD79A8),
      'surface': Color(0xFFFFFFFF),
      'background': Color(0xFFFDF2F8),
      'text': Color(0xFF1A1A2E),
      'textSecondary': Color(0xFF4A4A6A),
    },
    'green': {
      'primary': Color(0xFF00B894),
      'primaryDark': Color(0xFF00695C),
      'primaryLight': Color(0xFF55EFC4),
      'surface': Color(0xFFFFFFFF),
      'background': Color(0xFFF0F8F5),
      'text': Color(0xFF1A1A2E),
      'textSecondary': Color(0xFF4A4A6A),
    },
  };

  static const Map<String, Map<String, Color>> darkColorThemes = {
    'purple': {
      'primary': Color(0xFFA29BFE),
      'primaryDark': Color(0xFF6C5CE7),
      'primaryLight': Color(0xFFD5CCFF),
      'surface': Color(0xFF1A1A2E),
      'background': Color(0xFF0F0F1A),
      'text': Color(0xFFF0F0F5),
      'textSecondary': Color(0xFFC0C0D0),
    },
    'blue': {
      'primary': Color(0xFF74B9FF),
      'primaryDark': Color(0xFF0984E3),
      'primaryLight': Color(0xFFA8D8FF),
      'surface': Color(0xFF1A1A2E),
      'background': Color(0xFF0F0F1A),
      'text': Color(0xFFF0F0F5),
      'textSecondary': Color(0xFFC0C0D0),
    },
    'pink': {
      'primary': Color(0xFFFD79A8),
      'primaryDark': Color(0xFFE84393),
      'primaryLight': Color(0xFFFFB3C6),
      'surface': Color(0xFF1A1A2E),
      'background': Color(0xFF0F0F1A),
      'text': Color(0xFFF0F0F5),
      'textSecondary': Color(0xFFC0C0D0),
    },
    'green': {
      'primary': Color(0xFF55EFC4),
      'primaryDark': Color(0xFF00B894),
      'primaryLight': Color(0xFF88F0D4),
      'surface': Color(0xFF1A1A2E),
      'background': Color(0xFF0F0F1A),
      'text': Color(0xFFF0F0F5),
      'textSecondary': Color(0xFFC0C0D0),
    },
  };

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
    notifyListeners();
  }

  Future<void> setColorTheme(String color) async {
    _colorTheme = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorKey, color);
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getString(_themeKey) ?? 'system';
    _colorTheme = prefs.getString(_colorKey) ?? 'purple';
    notifyListeners();
  }

  // ===== متدهای جدید بدون نیاز به MediaQuery =====
  bool isDarkMode(BuildContext context) {
    if (_themeMode == 'dark') return true;
    if (_themeMode == 'light') return false;
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  // ===== دریافت رنگ‌ها با توجه به context (برای استفاده در ThemeData) =====
  Color getPrimaryColor() {
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final themes = isDark ? darkColorThemes : colorThemes;
    return themes[_colorTheme]?['primary'] ?? Color(0xFF6C5CE7);
  }

  Color getPrimaryDark() {
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final themes = isDark ? darkColorThemes : colorThemes;
    return themes[_colorTheme]?['primaryDark'] ?? Color(0xFF4834D4);
  }

  Color getBackgroundColor() {
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final themes = isDark ? darkColorThemes : colorThemes;
    return themes[_colorTheme]?['background'] ?? Color(0xFFF5F7FA);
  }

  Color getSurfaceColor() {
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final themes = isDark ? darkColorThemes : colorThemes;
    return themes[_colorTheme]?['surface'] ?? Color(0xFFFFFFFF);
  }

  Color getTextColor() {
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final themes = isDark ? darkColorThemes : colorThemes;
    return themes[_colorTheme]?['text'] ?? Color(0xFF1A1A2E);
  }

  Color getTextSecondaryColor() {
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final themes = isDark ? darkColorThemes : colorThemes;
    return themes[_colorTheme]?['textSecondary'] ?? Color(0xFF4A4A6A);
  }
}