import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primary = Color(0xFFE53935); // Red — fraud alert energy
  static const _secondary = Color(0xFF1E88E5); // Blue — trust / investigation
  static const _surface = Color(0xFF121212);
  static const _background = Color(0xFF0A0A0A);
  static const _card = Color(0xFF1E1E1E);

  // Pin colors
  static const pinNotInvestigated = Color(0xFF9E9E9E);
  static const pinRedFlag = Color(0xFFE53935);
  static const pinSeemsLegit = Color(0xFF43A047);
  static const pinUserSubmitted = Color(0xFF1E88E5);
  static const pinInconclusive = Color(0xFFFFA726);

  // Fraud score colors
  static Color fraudScoreColor(int score) {
    if (score >= 80) return const Color(0xFFE53935);
    if (score >= 60) return const Color(0xFFFF7043);
    if (score >= 40) return const Color(0xFFFFA726);
    if (score >= 20) return const Color(0xFFFFEE58);
    return const Color(0xFF66BB6A);
  }

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _primary,
          secondary: _secondary,
          surface: _surface,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: _background,
        cardColor: _card,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _surface,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surface,
          indicatorColor: _primary.withValues(alpha: 0.2),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _card,
          selectedColor: _primary.withValues(alpha: 0.3),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      );
}
