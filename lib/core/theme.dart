import 'package:flutter/material.dart';

/// SPEED Car Rental - Brand Colors & Theme
/// Red/Black branding matching Budget/Sixt style
class AppColors {
  AppColors._();

  // Brand core
  static const Color speedRed = Color(0xFFE30613);
  static const Color speedRedDark = Color(0xFFB10510);
  static const Color speedBlack = Color(0xFF0D0D0D);
  static const Color speedBlackSoft = Color(0xFF1A1A1A);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyMedium = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF4A4A4A);

  // Status
  static const Color success = Color(0xFF1FAA59);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFD32F2F);

  // For-sale vs for-rent badges
  static const Color rentBadge = speedRed;
  static const Color saleBadge = Color(0xFF1A1A1A);
}

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.white,
    primaryColor: AppColors.speedRed,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.speedRed,
      primary: AppColors.speedRed,
      secondary: AppColors.speedBlack,
      surface: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.speedBlack,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.speedRed,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.speedBlack,
        side: const BorderSide(color: AppColors.speedBlack, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.greyLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.speedRed,
      unselectedItemColor: AppColors.greyMedium,
      showUnselectedLabels: true,
    ),
  );
}
