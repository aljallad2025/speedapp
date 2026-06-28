import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SPEED Car Rental — Design System (v2)
/// Red / Black premium branding (Sixt / Budget inspired)
class AppColors {
  AppColors._();

  // Brand core
  static const Color speedRed = Color(0xFFE30613);
  static const Color speedRedDark = Color(0xFFB10510);
  static const Color speedRedLight = Color(0xFFFF4D5A);
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

  // --- New v2 tokens (additive, nothing above was removed) ---
  static const Color bg = Color(0xFFF7F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE9E9EC);
  static const Color textPrimary = Color(0xFF101012);
  static const Color textSecondary = Color(0xFF6B6B70);
  static const Color shadow = Color(0x14000000);

  static const List<Color> heroGradient = [
    Color(0xFFFF1A2B),
    Color(0xFFB10510),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF0D0D0D),
  ];
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.speedBlack.withOpacity(0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.speedBlack.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> redGlow = [
    BoxShadow(
      color: AppColors.speedRed.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    primaryColor: AppColors.speedRed,
    fontFamily: GoogleFonts.cairo().fontFamily,
    textTheme: GoogleFonts.cairoTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.speedRed,
      primary: AppColors.speedRed,
      secondary: AppColors.speedBlack,
      surface: AppColors.surface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.speedBlack,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        color: AppColors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.speedRed,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.speedBlack,
        side: const BorderSide(color: AppColors.speedBlack, width: 1.4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.speedRed,
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: GoogleFonts.cairo(color: AppColors.greyMedium, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.speedRed, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.speedRed,
      unselectedItemColor: AppColors.greyMedium,
      showUnselectedLabels: true,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.speedBlack,
      contentTextStyle: GoogleFonts.cairo(color: AppColors.white, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}