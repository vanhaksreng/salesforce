import 'package:flutter/material.dart';
import 'package:salesforce/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(primary: primary, onPrimary: white),
    appBarTheme: const AppBarTheme(elevation: 0.0, surfaceTintColor: white, backgroundColor: background),
    dividerColor: background,
    dividerTheme: const DividerThemeData(color: Colors.transparent),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: secondary,
        textStyle: const TextStyle(color: white),
      ),
    ),
  );
}
