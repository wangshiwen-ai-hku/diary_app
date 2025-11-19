import 'package:flutter/material.dart';

class ThemeColors {
  final Color primary;
  final Color light;
  final Color medium;
  final Color dark;
  final Color onPrimary;
  final Color onLight;
  final Color onMedium;
  final Color onDark;
  
  const ThemeColors({
    required this.primary,
    required this.light,
    required this.medium,
    required this.dark,
    required this.onPrimary,
    required this.onLight,
    required this.onMedium,
    required this.onDark,
  });
  
  List<Color> getGradient(String type) {
    switch (type) {
      case 'sweet':
        return [primary, light];
      case 'highlight':
        return [medium, light];
      case 'quarrel':
        return [dark, medium];
      case 'travel':
        return [light, primary];
      default:
        return [primary, medium];
    }
  }
  
  Color getTypeColor(String type) {
    switch (type) {
      case 'sweet':
        return primary;
      case 'highlight':
        return light;
      case 'quarrel':
        return dark;
      case 'travel':
        return medium;
      default:
        return primary;
    }
  }
}

class SystemThemeColors {
  // Soft Dark Theme - 柔和暗色
  static const darkMode = ThemeColors(
    primary: Color(0xFF9BA8B8),
    light: Color(0xFFB8C5D5),
    medium: Color(0xFF7A8BA0),
    dark: Color(0xFF5C6B7E),
    onPrimary: Color(0xFFFFFFFF),
    onLight: Color(0xFF2A2D35),
    onMedium: Color(0xFFFFFFFF),
    onDark: Color(0xFFFFFFFF),
  );
  
  // Soft Light Theme - 柔和亮色
  static const lightMode = ThemeColors(
    primary: Color(0xFF6B7C8E),
    light: Color(0xFF9CAAB8),
    medium: Color(0xFF7E8FA3),
    dark: Color(0xFF4A5563),
    onPrimary: Color(0xFFFFFFFF),
    onLight: Color(0xFF2D3239),
    onMedium: Color(0xFFFFFFFF),
    onDark: Color(0xFFFFFFFF),
  );
  
  // Warm Beige - 温暖米色
  static const warmBeige = ThemeColors(
    primary: Color(0xFFC4B5A0),
    light: Color(0xFFD9CFC0),
    medium: Color(0xFFAE9F8A),
    dark: Color(0xFF8E8070),
    onPrimary: Color(0xFF2D2925),
    onLight: Color(0xFF2D2925),
    onMedium: Color(0xFF2D2925),
    onDark: Color(0xFFFFFFFF),
  );
  
  // Soft Blue - 柔和蓝
  static const softBlue = ThemeColors(
    primary: Color(0xFF7A9BB5),
    light: Color(0xFFA5BED3),
    medium: Color(0xFF6685A0),
    dark: Color(0xFF4F6B82),
    onPrimary: Color(0xFFFFFFFF),
    onLight: Color(0xFF253341),
    onMedium: Color(0xFFFFFFFF),
    onDark: Color(0xFFFFFFFF),
  );
  
  // Sage Green - 灰绿色
  static const sageGreen = ThemeColors(
    primary: Color(0xFF8FA58B),
    light: Color(0xFFB0C2AC),
    medium: Color(0xFF748D70),
    dark: Color(0xFF5A7056),
    onPrimary: Color(0xFFFFFFFF),
    onLight: Color(0xFF2A332A),
    onMedium: Color(0xFFFFFFFF),
    onDark: Color(0xFFFFFFFF),
  );
  
  // Silver Dark Theme
  static const silverDark = ThemeColors(
    primary: Color(0xFFC0C0C0), // Silver
    light: Color(0xFFE0E0E0), // Light Silver
    medium: Color(0xFF808080), // Grey
    dark: Color(0xFF404040), // Dark Grey
    onPrimary: Color(0xFF000000),
    onLight: Color(0xFF000000),
    onMedium: Color(0xFFFFFFFF),
    onDark: Color(0xFFFFFFFF),
  );

  // Silver Light Theme
  static const silverLight = ThemeColors(
    primary: Color(0xFF808080), // Grey
    light: Color(0xFFC0C0C0), // Silver
    medium: Color(0xFF606060), // Dark Grey
    dark: Color(0xFF404040), // Darker Grey
    onPrimary: Color(0xFFFFFFFF),
    onLight: Color(0xFF000000),
    onMedium: Color(0xFFFFFFFF),
    onDark: Color(0xFFFFFFFF),
  );
  
  static ThemeColors getThemeColors(String themeName) {
    switch (themeName) {
      case 'silver_dark':
        return silverDark;
      case 'silver_light':
        return silverLight;
      case 'dark_mode':
        return darkMode;
      case 'light_mode':
        return lightMode;
      case 'warm_beige':
        return warmBeige;
      case 'soft_blue':
        return softBlue;
      case 'sage_green':
        return sageGreen;
      default:
        return silverDark;
    }
  }
}
