/// Application-wide constants, keys, defaults, and thresholds for MSGX.
class AppConstants {
  static const String appName = 'MSGX';
  static const String appTagline = 'Your Music. Your World.';
  static const String appVersion = '1.0.0';

  // Scanner Thresholds
  /// Audio files shorter than this threshold (in milliseconds) are ignored by default
  /// to filter out ringtones, system sound effects, and short notification clips.
  static const int defaultMinAudioDurationMs = 30000; // 30 seconds
  static const int notificationAudioDurationMs =
      5000; // 5 seconds threshold if user allows short tracks

  // Supported Extensions
  static const List<String> supportedAudioExtensions = [
    'mp3',
    'm4a',
    'aac',
    'flac',
    'wav',
    'ogg',
    'opus',
  ];

  // Storage and Database
  static const String databaseName = 'msgx_library.db';
  static const int databaseVersion = 1;

  // Preferences Keys
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefMinAudioDuration = 'pref_min_audio_duration';
  static const String prefIncludeNotificationSounds =
      'pref_include_notifications';
  static const String prefShuffleState = 'pref_shuffle_state';
  static const String prefRepeatMode = 'pref_repeat_mode';
  static const String prefLastPlayedSongId = 'pref_last_played_song_id';
  static const String prefLastPlayedPositionMs = 'pref_last_played_position_ms';
  static const String prefSleepTimerDurationMinutes =
      'pref_sleep_timer_minutes';
  static const String prefPlaybackSpeed = 'pref_playback_speed';

  // UI Metrics
  static const double miniPlayerHeight = 64.0;
  static const double bottomNavHeight = 60.0;
  static const double cardBorderRadius = 8.0;
  static const double artworkBorderRadius = 6.0;
  static const double pillBorderRadius = 24.0;
}
