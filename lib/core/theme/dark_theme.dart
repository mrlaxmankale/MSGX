import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Dark Theme specification for MSGX mimicking Spotify's design system.
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryGreen,
  scaffoldBackgroundColor: AppColors.darkBackground,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryGreen,
    onPrimary: Colors.white,
    secondary: AppColors.primaryGreenLight,
    surface: AppColors.darkPrimarySurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerHighest: AppColors.darkSecondarySurface,
    error: AppColors.error,
    onError: Colors.white,
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkPrimarySurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    margin: EdgeInsets.zero,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      letterSpacing: -0.4,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkPrimarySurface,
    selectedItemColor: AppColors.darkTextPrimary,
    unselectedItemColor: AppColors.darkTextSecondary,
    selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: AppColors.primaryGreen,
    inactiveTrackColor: AppColors.darkDivider,
    thumbColor: Colors.white,
    trackHeight: 3.5,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.darkDivider,
    thickness: 0.8,
  ),
  iconTheme: const IconThemeData(
    color: AppColors.darkTextPrimary,
    size: 24,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      letterSpacing: -0.6,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      letterSpacing: -0.4,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.darkTextPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextSecondary,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextMuted,
    ),
  ),
);
