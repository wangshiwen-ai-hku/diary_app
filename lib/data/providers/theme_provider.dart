import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

// Theme name provider - defaults to dark_mode
final themeNameProvider = StateProvider<String>((ref) => 'dark_mode');

// Brightness mode provider
final brightnessProvider = StateProvider<Brightness>((ref) => Brightness.dark);

// Theme data provider
final themeProvider = Provider<ThemeData>((ref) {
  final themeName = ref.watch(themeNameProvider);
  return AppTheme.themes[themeName] ?? AppTheme.defaultTheme;
});
