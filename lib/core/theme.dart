import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AegisTheme {
  // Color Palette
  static const Color background = Color(0xFF0A0F1D);
  static const Color surface = Color(0xFF111927);
  static const Color surfaceLight = Color(0xFF1B2537);
  static const Color surfaceBorder = Color(0xFF1E2C42);

  static const Color primaryBlue = Color(0xFF2575FC);
  static const Color primaryCyan = Color(0xFF00D2FF);

  static const Color statusSafe = Color(0xFF10B981);      // Emerald 500
  static const Color statusElevated = Color(0xFFF59E0B);  // Amber 500
  static const Color statusCritical = Color(0xFFEF4444);  // Red 500

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        surface: surface,
        onSurface: textPrimary,
        error: statusCritical,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
          ),
          displayMedium: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          titleLarge: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(
            color: textPrimary,
            fontSize: 16,
          ),
          bodyMedium: const TextStyle(
            color: textSecondary,
            fontSize: 14,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Returns color corresponding to CDI value
  static Color getCDIColor(double cdi) {
    if (cdi < 0.30) {
      return statusSafe;
    } else if (cdi < 0.60) {
      return statusElevated;
    } else {
      return statusCritical;
    }
  }

  // Returns status text label
  static String getCDILabel(double cdi) {
    if (cdi < 0.30) {
      return 'SAFE';
    } else if (cdi < 0.60) {
      return 'ELEVATED';
    } else {
      return 'CRITICAL';
    }
  }
}
