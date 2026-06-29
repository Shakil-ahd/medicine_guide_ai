import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  
  static const Color darkBg = Color(0xFF070A13); 
  static const Color cardBg = Color(0xFF111827); 
  static const Color accentTeal = Color(0xFF00E676); 
  static const Color accentIndigo = Color(0xFF6366F1); 
  static const Color warningRed = Color(0xFFFF5252); 
  static const Color textPrimary = Color(0xFFF9FAFB); 
  static const Color textSecondary = Color(0xFF9CA3AF); 

  
  static Color glassBg = const Color(0xFF1E293B).withAlpha(140);
  static Color glassBorder = const Color(0xFF334155).withAlpha(100);

  
  static const Gradient primaryGradient = LinearGradient(
    colors: [accentTeal, accentIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient welcomeGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1F2937), width: 1.2),
        ),
        elevation: 6,
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
