import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  // Modern theme list with brightness
  static final themes = {
    'silver_dark': _createTheme(AppColors.silverDark, 'Silver Dark', Brightness.dark),
    'silver_light': _createTheme(AppColors.silverLight, 'Silver Light', Brightness.light),
    'dark_mode': _createTheme(AppColors.darkMode, 'Dark Mode', Brightness.dark),
    'light_mode': _createTheme(AppColors.lightMode, 'Light Mode', Brightness.light),
  };

  static ThemeData _createTheme(ColorScheme colorScheme, String name, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(brightness: brightness),
      
      // Elegant font - Playfair Display for Headings, Lato for Body
      textTheme: GoogleFonts.latoTextTheme(
        TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
            height: 1.1,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
          headlineLarge: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: colorScheme.onSurface,
            height: 1.3,
          ),
          titleLarge: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            color: colorScheme.onSurface,
            height: 1.4,
          ),
          titleMedium: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            color: colorScheme.onSurface.withOpacity(0.9),
            height: 1.4,
          ),
          bodyLarge: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.6,
            letterSpacing: 0.5,
            color: colorScheme.onSurface.withOpacity(0.9),
          ),
          bodyMedium: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            letterSpacing: 0.25,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          labelLarge: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: colorScheme.onSurface.withOpacity(0.9),
          ),
        ),
      ),

      // Card style
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),

      // Button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // Pill shape
          ),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withOpacity(0.05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        hintStyle: GoogleFonts.lato(
          color: colorScheme.onSurface.withOpacity(0.4),
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface.withOpacity(0.8),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
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
  static ThemeData get defaultTheme => themes['silver_dark']!;
}
