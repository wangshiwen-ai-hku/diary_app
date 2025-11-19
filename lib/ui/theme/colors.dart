import 'package:flutter/material.dart';

class AppColors {
  // Dark Mode - 暗色模式
  static const darkMode = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9BA8B8),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFB8C5D5),
    onSecondary: Color(0xFF2A2D35),
    tertiary: Color(0xFF7A8BA0),
    error: Color(0xFFCF6679),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFF121218),
    onSurface: Color(0xFFE5E7EB),
    surfaceContainerHighest: Color(0xFF1E1E24),
  );

  // Light Mode - 亮色模式
  static const lightMode = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF6B7C8E),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF9CAAB8),
    onSecondary: Color(0xFF2D3239),
    tertiary: Color(0xFF7E8FA3),
    error: Color(0xFFCF6679),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF8F9FA),
    onSurface: Color(0xFF2D3239),
    surfaceContainerHighest: Color(0xFFFFFFFF),
  );

  // Warm Beige - 温暖米色
  static const warmBeige = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFC4B5A0),
    onPrimary: Color(0xFF2D2925),
    secondary: Color(0xFFD9CFC0),
    onSecondary: Color(0xFF2D2925),
    tertiary: Color(0xFFAE9F8A),
    error: Color(0xFFCF6679),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F2ED),
    onSurface: Color(0xFF2D2925),
    surfaceContainerHighest: Color(0xFFFFFBF5),
  );

  // Soft Blue - 柔和蓝
  static const softBlue = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF7A9BB5),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFA5BED3),
    onSecondary: Color(0xFF253341),
    tertiary: Color(0xFF6685A0),
    error: Color(0xFFCF6679),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF0F4F8),
    onSurface: Color(0xFF253341),
    surfaceContainerHighest: Color(0xFFFFFFFF),
  );

  // Sage Green - 灰绿色
  static const sageGreen = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF8FA58B),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFB0C2AC),
    onSecondary: Color(0xFF2A332A),
    tertiary: Color(0xFF748D70),
    error: Color(0xFFCF6679),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF2F5F3),
    onSurface: Color(0xFF2A332A),
    surfaceContainerHighest: Color(0xFFFFFFFF),
  );
  // Silver & Pink - 银灰粉色主题 (主推)
  static const silverDark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFC0C0C0), // Silver
    onPrimary: Color(0xFF000000),
    secondary: Color(0xFFFFD1DC), // Pale Pink
    onSecondary: Color(0xFF000000),
    tertiary: Color(0xFF808080), // Grey
    error: Color(0xFFCF6679),
    onError: Color(0xFF000000),
    surface: Color(0xFF000000), // Black
    onSurface: Color(0xFFE0E0E0),
    surfaceContainerHighest: Color(0xFF1A1A1A), // Dark Grey
  );

  static const silverLight = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF808080), // Grey
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFFFD1DC), // Pale Pink
    onSecondary: Color(0xFF000000),
    tertiary: Color(0xFFC0C0C0), // Silver
    error: Color(0xFFB00020),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F5F5), // White Smoke
    onSurface: Color(0xFF000000),
    surfaceContainerHighest: Color(0xFFE0E0E0),
  );
}
