import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Light Theme specification for MSGX.
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.primaryGreen,
  scaffoldBackgroundColor: AppColors.lightBackground,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryGreen,
    onPrimary: Colors.white,
    secondary: AppColors.primaryGreenDark,
    surface: AppColors.lightPrimarySurface,
    onSurface: AppColors.lightTextPrimary,
    surfaceContainerHighest: AppColors.lightSecondarySurface,
    error: AppColors.error,
    onError: Colors.white,
  ),
  cardTheme: CardThemeData(
    color: AppColors.lightPrimarySurface,
    elevation: 0.5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    margin: EdgeInsets.zero,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    foregroundColor: AppColors.lightTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
      letterSpacing: -0.4,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.lightPrimarySurface,
    selectedItemColor: AppColors.primaryGreenDark,
    unselectedItemColor: AppColors.lightTextSecondary,
    selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: AppColors.primaryGreen,
    inactiveTrackColor: AppColors.lightDivider,
    thumbColor: AppColors.primaryGreenDark,
    trackHeight: 3.5,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.lightDivider,
    thickness: 0.8,
  ),
  iconTheme: const IconThemeData(
    color: AppColors.lightTextPrimary,
    size: 24,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
      letterSpacing: -0.6,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
      letterSpacing: -0.4,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.lightTextPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextSecondary,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextMuted,
    ),
  ),
);
