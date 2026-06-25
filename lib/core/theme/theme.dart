import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color cardBg = Color(0xFF161E31);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color accentIndigo = Color(0xFF5C6BC0);
  static const Color warningRed = Color(0xFFFF5252);
  static const Color textPrimary = Color(0xFFECEFF1);
  static const Color textSecondary = Color(0xFF90A4AE);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: accentTeal,
        secondary: accentIndigo,
        surface: cardBg,
        error: warningRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            bodyMedium: GoogleFonts.hindSiliguri(
              textStyle: const TextStyle(color: textPrimary, fontSize: 16),
            ),
            bodyLarge: GoogleFonts.hindSiliguri(
              textStyle: const TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            titleLarge: GoogleFonts.outfit(
              textStyle: const TextStyle(
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      cardTheme: CardThemeData(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF263238), width: 1),
        ),
        elevation: 4,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
