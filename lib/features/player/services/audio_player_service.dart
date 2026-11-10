import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/error_handler.dart';
import '../../../models/song.dart';
import 'audio_handler.dart';

enum MSGXRepeatMode { off, all, one }

/// Core audio playback engine for MSGX.
/// Controls just_audio player, AudioService background integration, AudioSession focus,
/// queue logic, shuffle, repeat, and persistent history.
class AudioPlayerService extends ChangeNotifier {
  static AudioPlayerService? _instance;
  late final AudioPlayer _player;
  MSGXAudioHandler? _audioHandler;

  // Queue and Playback State
  List<Song> _queue = [];
  List<Song> _originalQueue = [];
  int _currentIndex = -1;
  bool _isShuffleEnabled = false;
  MSGXRepeatMode _repeatMode = MSGXRepeatMode.off;
  double _playbackSpeed = 1.0;
  String? _errorMessage;

  // Getters
  AudioPlayer get player => _player;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Song? get currentSong => (_currentIndex >= 0 && _currentIndex < _queue.length)
      ? _queue[_currentIndex]
      : null;
  bool get isPlaying => _player.playing;
  bool get isShuffleEnabled => _isShuffleEnabled;
  MSGXRepeatMode get repeatMode => _repeatMode;
  double get playbackSpeed => _playbackSpeed;
  String? get errorMessage => _errorMessage;

  // Position and Duration Streams
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  AudioPlayerService._internal() {
    _player = AudioPlayer();
    _initAudioSession();
    _initListeners();
  }

  factory AudioPlayerService() {
    _instance ??= AudioPlayerService._internal();
    return _instance!;
  }

  /// Initialize AudioService and bind handler callbacks
  Future<void> initAudioService() async {
    try {
      _audioHandler = await AudioService.init(
        builder: () => MSGXAudioHandler(_player),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.msgx.player.channel.audio',
          androidNotificationChannelName: 'MSGX Playback',
          androidNotificationChannelDescription:
              'Offline music player playback controls',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidShowNotificationBadge: true,
          notificationColor: Color(0xFF1DB954),
        ),
      );

      _audioHandler!.customActionCallbacks['skipToNext'] =
          () async => await next();
      _audioHandler!.customActionCallbacks['skipToPrevious'] =
          () async => await previous();
    } catch (e, stack) {
      ErrorHandler.logError('AudioPlayerService.initAudioService', e, stack);
    }
  }

  /// Configure AudioSession for phone call interruptions and headphone disconnection
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Auto pause when headphones are unplugged
      session.becomingNoisyEventStream.listen((_) {
        pause();
      });

      // Handle interruptions (e.g. phone calls)
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.3);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
    } catch (e, stack) {
      ErrorHandler.logError('AudioPlayerService._initAudioSession', e, stack);
    }
  }

  void _initListeners() {
    // Listen for song completion
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleSongCompletion();
      }
      notifyListeners();
    });

    // Save playback position periodically
    _player.positionStream.listen((pos) {
      if (_currentIndex >= 0 && _currentIndex < _queue.length) {
        _saveLastPlaybackState(pos);
      }
    });
  }

  /// Automatically advance queue when song completes based on repeat mode
  void _handleSongCompletion() {
    if (_repeatMode == MSGXRepeatMode.one) {
      _player.seek(Duration.zero);
      _player.play();
    } else if (_currentIndex < _queue.length - 1) {
      next();
    } else if (_repeatMode == MSGXRepeatMode.all && _queue.isNotEmpty) {
      _currentIndex = 0;
      _loadAndPlayCurrentSong();
    }
  }

  // ==========================================
  // PLAYBACK CONTROL METHODS
  // ==========================================

  /// Play a specific song and optionally update the active playback queue
  Future<void> playSong(Song song,
      {List<Song>? contextQueue, int? startIndex}) async {
    _errorMessage = null;

    if (contextQueue != null && contextQueue.isNotEmpty) {
      _originalQueue = List.from(contextQueue);
      if (_isShuffleEnabled) {
        _queue = _generateShuffledQueue(_originalQueue, song);
        _currentIndex = 0;
      } else {
        _queue = List.from(contextQueue);
        _currentIndex = startIndex ?? _queue.indexWhere((s) => s.id == song.id);
        if (_currentIndex == -1) _currentIndex = 0;
      }
    } else {
      final existingIndex = _queue.indexWhere((s) => s.id == song.id);
      if (existingIndex != -1) {
        _currentIndex = existingIndex;
      } else {
        _queue.add(song);
        _originalQueue.add(song);
        _currentIndex = _queue.length - 1;
      }
    }

    await _loadAndPlayCurrentSong();
  }

  /// Internal loader that validates file existence, loads into just_audio, and starts playback
  Future<void> _loadAndPlayCurrentSong() async {
    final song = currentSong;
    if (song == null) return;

    try {
      _errorMessage = null;
      notifyListeners();

      // Check if file exists when path is local
      if (!song.filePathOrUri.startsWith('content://') &&
          !song.filePathOrUri.startsWith('http')) {
        final file = File(song.filePathOrUri);
        if (!file.existsSync()) {
          throw Exception('File not found: ${song.filePathOrUri}');
        }
      }

      // Load audio source into just_audio
      if (song.filePathOrUri.startsWith('content://')) {
        await _player
            .setAudioSource(AudioSource.uri(Uri.parse(song.filePathOrUri)));
      } else {
        await _player.setFilePath(song.filePathOrUri);
      }

      await _player.setSpeed(_playbackSpeed);
      await _player.play();

      // Update background notification
      _updateBackgroundNotification(song);

      // Record in play history
      if (song.id != null) {
        await AppDatabase().recordPlayHistory(song.id!);
      }

      notifyListeners();
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logError(
          'AudioPlayerService._loadAndPlayCurrentSong', e, stack);
      notifyListeners();

      // Attempt to automatically skip to next track if file is missing/unplayable
      if (_queue.length > 1 && _currentIndex < _queue.length - 1) {
        await Future.delayed(const Duration(seconds: 1));
        await next();
      }
    }
  }

  void _updateBackgroundNotification(Song song) {
    _audioHandler?.setMediaItem(
      id: song.mediaId,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: Duration(milliseconds: song.duration),
      artworkUri: song.artworkReference != null
          ? 'file://${song.artworkReference}'
          : null,
    );
  }

  Future<void> play() async {
    await _player.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      if (currentSong != null) {
        await play();
      } else if (_queue.isNotEmpty) {
        _currentIndex = 0;
        await _loadAndPlayCurrentSong();
      }
    }
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _loadAndPlayCurrentSong();
    } else if (_repeatMode == MSGXRepeatMode.all) {
      _currentIndex = 0;
      await _loadAndPlayCurrentSong();
    }
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    // If playing for more than 3 seconds, restart current track
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
      await _loadAndPlayCurrentSong();
    } else if (_repeatMode == MSGXRepeatMode.all) {
      _currentIndex = _queue.length - 1;
      await _loadAndPlayCurrentSong();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _player.setSpeed(speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.prefPlaybackSpeed, speed);
    notifyListeners();
  }

  // ==========================================
  // SHUFFLE & REPEAT
  // ==========================================

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    final current = currentSong;

    if (_isShuffleEnabled) {
      if (current != null) {
        _queue = _generateShuffledQueue(_originalQueue, current);
        _currentIndex = 0;
      }
    } else {
      if (current != null) {
        _queue = List.from(_originalQueue);
        _currentIndex = _queue.indexWhere((s) => s.id == current.id);
        if (_currentIndex == -1) _currentIndex = 0;
      }
    }
    notifyListeners();
  }

  List<Song> _generateShuffledQueue(List<Song> source, Song current) {
    final list = List<Song>.from(source);
    list.removeWhere((s) => s.id == current.id);
    list.shuffle(Random());
    list.insert(0, current);
    return list;
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case MSGXRepeatMode.off:
        _repeatMode = MSGXRepeatMode.all;
        break;
      case MSGXRepeatMode.all:
        _repeatMode = MSGXRepeatMode.one;
        break;
      case MSGXRepeatMode.one:
        _repeatMode = MSGXRepeatMode.off;
        break;
    }
    notifyListeners();
  }

  // ==========================================
  // QUEUE MANAGEMENT
  // ==========================================

  void addToQueue(Song song) {
    _queue.add(song);
    _originalQueue.add(song);
    notifyListeners();
  }

  void insertNext(Song song) {
    final insertIndex = _currentIndex + 1;
    if (insertIndex <= _queue.length) {
      _queue.insert(insertIndex, song);
      _originalQueue.add(song);
      notifyListeners();
    }
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    if (index == _currentIndex) {
      // Removing currently playing song
      if (_queue.length > 1) {
        next();
        _queue.removeAt(index);
        if (_currentIndex > index) _currentIndex--;
      } else {
        _player.stop();
        _queue.clear();
        _originalQueue.clear();
        _currentIndex = -1;
      }
    } else {
      _queue.removeAt(index);
      if (index < _currentIndex) _currentIndex--;
    }
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _queue.length ||
        newIndex < 0 ||
        newIndex > _queue.length) {
      return;
    }
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);

    if (oldIndex == _currentIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex++;
    }
    notifyListeners();
  }

  void clearQueue() {
    _player.stop();
    _queue.clear();
    _originalQueue.clear();
    _currentIndex = -1;
    notifyListeners();
  }

  // ==========================================
  // SLEEP TIMER
  // ==========================================

  Timer? _sleepTimer;
  DateTime? _sleepTimerEndTime;

  Duration? get remainingSleepTime =>
      _sleepTimerEndTime?.difference(DateTime.now());

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes <= 0) {
      _sleepTimerEndTime = null;
      notifyListeners();
      return;
    }

    _sleepTimerEndTime = DateTime.now().add(Duration(minutes: minutes));
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      pause();
      _sleepTimerEndTime = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerEndTime = null;
    notifyListeners();
  }

  // ==========================================
  // PERSISTENCE HELPER
  // ==========================================

  Future<void> _saveLastPlaybackState(Duration position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (currentSong?.id != null) {
        await prefs.setInt(AppConstants.prefLastPlayedSongId, currentSong!.id!);
        await prefs.setInt(
            AppConstants.prefLastPlayedPositionMs, position.inMilliseconds);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}
