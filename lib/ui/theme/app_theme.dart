import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  // Modern theme list with brightness
  static final themes = {
    'dark_mode': _createTheme(AppColors.darkMode, 'Dark Mode', Brightness.dark),
    'light_mode': _createTheme(AppColors.lightMode, 'Light Mode', Brightness.light),
    'warm_beige': _createTheme(AppColors.warmBeige, 'Warm Beige', Brightness.light),
    'soft_blue': _createTheme(AppColors.softBlue, 'Soft Blue', Brightness.light),
    'sage_green': _createTheme(AppColors.sageGreen, 'Sage Green', Brightness.light),
  };

  static ThemeData _createTheme(ColorScheme colorScheme, String name, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(brightness: brightness),
      
      // Elegant font - Cormorant Garamond for English, Noto Sans JP for CJK
      textTheme: GoogleFonts.cormorantGaramondTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: isDark ? Colors.white.withOpacity(0.95) : const Color(0xFF2D2D2D),
            height: 1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: isDark ? Colors.white.withOpacity(0.95) : const Color(0xFF2D2D2D),
            height: 1.2,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: isDark ? Colors.white.withOpacity(0.95) : const Color(0xFF2D2D2D),
            height: 1.3,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF3A3A3A),
            height: 1.3,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF3A3A3A),
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF4A4A4A),
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            height: 1.8,
            letterSpacing: 0.3,
            color: isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF3A3A3A),
          ),
          bodyMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.7,
            letterSpacing: 0.3,
            color: isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF4A4A4A),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
            color: isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF4A4A4A),
          ),
        ),
      ),

      // Card style
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),

      // Button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Scaffold
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  // Default theme
  static ThemeData get defaultTheme => themes['dark_space']!;
}
