import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Winline-inspired signature sport colors: vibrant energetic orange & dark graphite
  static const Color primary = Color(0xFFFF5500); // Signature vibrant sport orange
  static const Color primaryLight = Color(0xFFFF7722);
  static const Color primaryDark = Color(0xFFCC4400);
  
  static const Color accentGold = Color(0xFFFFB800); // Gold / Trophies
  static const Color accentEmerald = Color(0xFF10B981); // Live match / Success
  static const Color accentRose = Color(0xFFEF4444); // Red / Errors
  static const Color accentBlue = Color(0xFF3B82F6); // Info / Highlights

  // Deep dark sports surfaces
  static const Color background = Color(0xFF0C0F16); // Deep charcoal black
  static const Color surface = Color(0xFF141924); // Dark slate
  static const Color surfaceCard = Color(0xFF1C2232); // Card surface
  static const Color surfaceElevated = Color(0xFF242C3E); // Elevated surface
  static const Color surfaceBorder = Color(0xFF2E384D); // Card border

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Box Shadows & Glows
  static List<BoxShadow> get orangeGlow => [
        BoxShadow(
          color: primary.withAlpha(60),
          blurRadius: 18,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get neonGlow => orangeGlow;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(80),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accentGold,
        surface: surface,
        error: accentRose,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
