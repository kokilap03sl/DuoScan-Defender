import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  fontFamily: 'Itim',
  primaryColor: const Color(0xFF3C4E67),
  scaffoldBackgroundColor: const Color(0xFF6A99DA),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF3C4E67),
    secondary: Color(0xFF6A99DA),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF3C4E67),
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
);
