import 'package:flutter/material.dart';

/// Centralized route manager for declarative named navigation throughout MSGX.
class RouteManager {
  static const String mainShell = '/';
  static const String nowPlaying = '/now_playing';
  static const String playlistDetail = '/playlist_detail';
  static const String albumDetail = '/album_detail';
  static const String artistDetail = '/artist_detail';
  static const String folderDetail = '/folder_detail';
  static const String equalizer = '/equalizer';
  static const String settings = '/settings';
  static const String lyrics = '/lyrics';
  static const String scanner = '/scanner';

  /// Custom smooth Spotify-style slide transition for screen pushes
  static Route<T> buildSlideRoute<T>({
    required Widget page,
    RouteSettings? settings,
    Offset begin = const Offset(0.0, 1.0), // default slide from bottom
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curveTween = CurveTween(curve: Curves.easeOutCubic);
        final tween =
            Tween<Offset>(begin: begin, end: Offset.zero).chain(curveTween);
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
