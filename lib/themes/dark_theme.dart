import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  fontFamily: 'Itim',
  primaryColor: const Color(0xFF1E1E2C),
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF1E1E2C),
    secondary: Color(0xFF3C4E67),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E2C),
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);
