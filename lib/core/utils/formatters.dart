import 'package:intl/intl.dart';

/// Formatting utilities for durations, file sizes, and dates in MSGX.
class Formatters {
  /// Format duration in milliseconds to "m:ss" or "h:mm:ss"
  static String formatDurationMs(int milliseconds) {
    if (milliseconds <= 0) return '0:00';
    final duration = Duration(milliseconds: milliseconds);
    return formatDuration(duration);
  }

  /// Format Duration object to "m:ss" or "h:mm:ss"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Format byte size into readable string (e.g. "4.2 MB", "850 KB")
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Format timestamp into relative date or human-readable format
  static String formatDate(int timestampSecondsOrMs) {
    if (timestampSecondsOrMs <= 0) return '';
    // Normalize to milliseconds if timestamp was in seconds
    final ms = timestampSecondsOrMs < 10000000000
        ? timestampSecondsOrMs * 1000
        : timestampSecondsOrMs;
    final date = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateFormat.yMMMd().format(date);
  }

  /// Format greeting based on current local hour
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
