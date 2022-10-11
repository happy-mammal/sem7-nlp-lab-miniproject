import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
      scaffoldBackgroundColor: const Color(0xFFfefefe),
      backgroundColor: const Color(0xFFf8f7fb),
      hintColor: const Color(0xFF827c9f),
      dividerColor: const Color(0xFFd6d2e2),
      indicatorColor: const Color(0xFF290964),
      primaryColor: Colors.blueAccent);

  static ThemeData get dark => ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0f0f0f),
        backgroundColor: const Color(0xFF222222),
        hintColor: const Color(0xFF6a6b73),
        dividerColor: const Color(0xFF696a74),
        indicatorColor: const Color(0xFFa2a4aa),
        primaryColor: Colors.blueAccent,
      );
}
