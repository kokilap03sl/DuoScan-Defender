import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = lightTheme;

  ThemeData get currentTheme => _currentTheme;

  void switchTheme(bool isDarkMode) {
    _currentTheme = isDarkMode ? darkTheme : lightTheme;
    notifyListeners();
  }
}
