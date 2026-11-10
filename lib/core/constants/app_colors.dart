import 'package:flutter/material.dart';

/// Central color palette for MSGX adhering to the Spotify-inspired dark aesthetic
/// and clean accessible light scheme.
class AppColors {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF1DB954);
  static const Color primaryGreenLight = Color(0xFF1ED760);
  static const Color primaryGreenDark = Color(0xFF169C46);

  // Dark Theme Palette (Default Spotify aesthetic)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkPrimarySurface = Color(0xFF181818);
  static const Color darkSecondarySurface = Color(0xFF242424);
  static const Color darkCardHighlight = Color(0xFF2A2A2A);
  static const Color darkDivider = Color(0xFF303030);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextMuted = Color(0xFF757575);

  // Light Theme Palette (Clean companion)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightPrimarySurface = Color(0xFFFFFFFF);
  static const Color lightSecondarySurface = Color(0xFFF1F3F5);
  static const Color lightCardHighlight = Color(0xFFE9ECEF);
  static const Color lightDivider = Color(0xFFDEE2E6);

  static const Color lightTextPrimary = Color(0xFF191414);
  static const Color lightTextSecondary = Color(0xFF535353);
  static const Color lightTextMuted = Color(0xFF8E8E93);

  // Status & Feedback Colors
  static const Color error = Color(0xFFE91429);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF1DB954);
  static const Color info = Color(0xFF2E77D0);

  // Accent Gradients
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF282828),
      Color(0xFF181818),
    ],
  );

  static const LinearGradient nowPlayingOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xCC121212),
      Color(0xFF121212),
    ],
  );
}
