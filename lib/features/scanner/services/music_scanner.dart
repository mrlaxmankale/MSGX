import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../models/song.dart';
import 'android_music_scanner.dart';
import 'ios_music_scanner.dart';

class ScanProgressState {
  final bool isScanning;
  final int discovered;
  final int valid;
  final int skipped;
  final String? error;
  final bool completed;

  const ScanProgressState({
    this.isScanning = false,
    this.discovered = 0,
    this.valid = 0,
    this.skipped = 0,
    this.error,
    this.completed = false,
  });

  ScanProgressState copyWith({
    bool? isScanning,
    int? discovered,
    int? valid,
    int? skipped,
    String? error,
    bool? completed,
  }) {
    return ScanProgressState(
      isScanning: isScanning ?? this.isScanning,
      discovered: discovered ?? this.discovered,
      valid: valid ?? this.valid,
      skipped: skipped ?? this.skipped,
      error: error,
      completed: completed ?? this.completed,
    );
  }
}

/// Unified cross-platform music scanner
class MusicScanner {
  final AndroidMusicScanner _androidScanner = AndroidMusicScanner();
  final IOSMusicScanner _iosScanner = IOSMusicScanner();
  final AppDatabase _db = AppDatabase();

  bool _isCancelled = false;

  void cancelScan() {
    _isCancelled = true;
  }

  /// Perform a full device audio scan with incremental persistence
  Future<List<Song>> scanDevice({
    int minDurationMs = AppConstants.defaultMinAudioDurationMs,
    void Function(ScanProgressState progress)? onProgress,
  }) async {
    _isCancelled = false;
    onProgress?.call(const ScanProgressState(isScanning: true));

    final hasPerm = await PermissionService.hasMediaPermission();
    if (!hasPerm) {
      final status = await PermissionService.requestMediaPermission();
      if (!status.isGranted) {
        onProgress?.call(const ScanProgressState(
          isScanning: false,
          error:
              'Media permission was denied. Please grant permission in Settings.',
          completed: true,
        ));
        return [];
      }
    }

    try {
      List<Song> songs = [];

      if (Platform.isAndroid) {
        songs = await _androidScanner.scan(
          minDurationMs: minDurationMs,
          onProgress: (discovered, valid) {
            if (!_isCancelled) {
              onProgress?.call(ScanProgressState(
                isScanning: true,
                discovered: discovered,
                valid: valid,
                skipped: discovered - valid,
              ));
            }
          },
        );
      } else if (Platform.isIOS) {
        songs = await _iosScanner.scan(
          minDurationMs: minDurationMs,
          onProgress: (discovered, valid) {
            if (!_isCancelled) {
              onProgress?.call(ScanProgressState(
                isScanning: true,
                discovered: discovered,
                valid: valid,
                skipped: discovered - valid,
              ));
            }
          },
        );
      }

      if (_isCancelled) {
        onProgress
            ?.call(const ScanProgressState(isScanning: false, completed: true));
        return [];
      }

      // Persist discovered tracks into SQLite database
      if (songs.isNotEmpty) {
        await _db.upsertSongsBatch(songs);
      }

      onProgress?.call(ScanProgressState(
        isScanning: false,
        discovered: songs.length,
        valid: songs.length,
        skipped: 0,
        completed: true,
      ));

      return songs;
    } catch (e, stack) {
      ErrorHandler.logError('MusicScanner.scanDevice', e, stack);
      onProgress?.call(ScanProgressState(
        isScanning: false,
        error: 'Scan failed: ${e.toString()}',
        completed: true,
      ));
      return [];
    }
  }

  /// Manually import files from directory picker
  Future<List<Song>> importCustomFolder({
    void Function(ScanProgressState progress)? onProgress,
  }) async {
    try {
      onProgress?.call(const ScanProgressState(isScanning: true));
      final files = await FileService.pickAudioFolder();
      final List<Song> songs = [];

      for (int i = 0; i < files.length; i++) {
        final song = await _iosScanner.importUserFiles();
        songs.addAll(song);
      }

      if (songs.isNotEmpty) {
        await _db.upsertSongsBatch(songs);
      }

      onProgress?.call(ScanProgressState(
        isScanning: false,
        discovered: songs.length,
        valid: songs.length,
        completed: true,
      ));

      return songs;
    } catch (e, stack) {
      ErrorHandler.logError('MusicScanner.importCustomFolder', e, stack);
      return [];
    }
  }
}
