import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SynapTheme {
  // Color Palette - Sleek Google Pay Dark Inspired
  static const Color background = Color(0xFF0F141C);
  static const Color surface = Color(0xFF19202D);
  static const Color surfaceLight = Color(0xFF242D3D);
  static const Color surfaceBorder = Color(0xFF2D384D);

  static const Color primaryBlue = Color(0xFF1A73E8);     // Google Pay Blue
  static const Color primaryCyan = Color(0xFF00D2FF);
  static const Color primaryAccent = Color(0xFF4285F4);

  static const Color statusSafe = Color(0xFF0F9D58);      // Google Green 
  static const Color statusElevated = Color(0xFFF4B400);  // Google Amber
  static const Color statusCritical = Color(0xFFDB4437);  // Google Red

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFA0AEC0);
  static const Color textMuted = Color(0xFF718096);

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
            fontSize: 32,
            letterSpacing: -0.5,
          ),
          displayMedium: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 26,
            letterSpacing: -0.5,
          ),
          titleLarge: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          bodyLarge: const TextStyle(
            color: textPrimary,
            fontSize: 17, // Generous and legible for seniors
          ),
          bodyMedium: const TextStyle(
            color: textSecondary,
            fontSize: 15,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: surfaceBorder, width: 1.2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static Color getCDIColor(double cdi) {
    if (cdi < 0.30) {
      return statusSafe;
    } else if (cdi < 0.60) {
      return statusElevated;
    } else {
      return statusCritical;
    }
  }

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

// Backwards compatibility alias
typedef AegisTheme = SynapTheme;
