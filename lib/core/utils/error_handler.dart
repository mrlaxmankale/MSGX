import 'package:flutter/foundation.dart';

/// Centralized error handling and logging for MSGX.
class ErrorHandler {
  /// Logs an error with optional stack trace and user context.
  static void logError(String source, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[MSGX ERROR][$source]: $error');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }

  /// Converts common system and playback exceptions into user-friendly messages.
  static String getUserFriendlyMessage(Object error) {
    final str = error.toString().toLowerCase();
    if (str.contains('permission')) {
      return 'Permission denied. Please grant media access in Settings to view and play songs.';
    } else if (str.contains('filenotfound') || str.contains('does not exist')) {
      return 'The audio file could not be found. It may have been moved, renamed, or deleted.';
    } else if (str.contains('codec') ||
        str.contains('unsupported') ||
        str.contains('format')) {
      return 'This audio format is not supported by your device decoder.';
    } else if (str.contains('database') || str.contains('sqlite')) {
      return 'A database storage error occurred. Please try rescanning your library.';
    } else {
      return 'An unexpected audio playback error occurred.';
    }
  }
}
