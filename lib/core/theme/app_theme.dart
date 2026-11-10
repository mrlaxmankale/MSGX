import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// Provides theme modes and getters for MSGX.
class AppTheme {
  static ThemeData get dark => darkTheme;
  static ThemeData get light => lightTheme;
}
