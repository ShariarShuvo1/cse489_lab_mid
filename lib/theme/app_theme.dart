import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color yellowForeground = Color(0xFFFFD700);
  static const Color cardBackground = Color(0xFF2A2A2A);
  static const Color accentBlue = Color(0xFF00BCD4);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE91E63);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFBBBBBB);

  // Took help from AI to learn custom theme structure
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: yellowForeground,
        unselectedItemColor: textSecondary,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: yellowForeground,
        foregroundColor: darkBackground,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBackground,
        contentTextStyle: const TextStyle(
          color: yellowForeground,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: yellowForeground, width: 1.5),
        ),
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: yellowForeground, width: 1.5),
        ),
        titleTextStyle: const TextStyle(
          color: yellowForeground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 14),
      ),
    );
  }
}
