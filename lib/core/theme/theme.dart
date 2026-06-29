import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Neon and Dark Color Palette
  static const Color darkBg = Color(0xFF070A13); // Richer deeper black-blue
  static const Color cardBg = Color(0xFF111827); // Sleek modern dark grey-blue
  static const Color accentTeal = Color(0xFF00E676); // High-vibrancy Neon Teal
  static const Color accentIndigo = Color(0xFF6366F1); // Modern Premium Indigo
  static const Color warningRed = Color(0xFFFF5252); // Vibrant Warning Red
  static const Color textPrimary = Color(0xFFF9FAFB); // Pure White-Grey
  static const Color textSecondary = Color(0xFF9CA3AF); // Neutral Cool Grey

  // Custom Glassmorphism / Acrylic Colors
  static Color glassBg = const Color(0xFF1E293B).withAlpha(140);
  static Color glassBorder = const Color(0xFF334155).withAlpha(100);

  // Premium Linear Gradients
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
