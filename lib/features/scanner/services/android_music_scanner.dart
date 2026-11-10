import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/metadata_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../models/song.dart';

/// Android MediaStore audio scanning engine.
class AndroidMusicScanner {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Scans Android MediaStore for local audio files, applying filters for min duration,
  /// file existence, and format verification.
  Future<List<Song>> scan({
    int minDurationMs = AppConstants.defaultMinAudioDurationMs,
    void Function(int discovered, int valid)? onProgress,
  }) async {
    final List<Song> validSongs = [];
    try {
      final List<SongModel> songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );

      int discovered = 0;
      for (final songModel in songs) {
        discovered++;

        // Filter out ringtones, notification sounds, and podcasts
        if (songModel.isMusic != true && songModel.isMusic != null) {
          continue;
        }

        // Apply duration filter
        final duration = songModel.duration ?? 0;
        if (duration < minDurationMs) {
          continue;
        }

        // Verify physical file existence if file path is available
        if (songModel.data.isNotEmpty &&
            !songModel.data.startsWith('content://') &&
            !File(songModel.data).existsSync()) {
          continue;
        }

        final song = MetadataService.fromSongModel(songModel);
        validSongs.add(song);

        onProgress?.call(discovered, validSongs.length);
      }
    } catch (e, stack) {
      ErrorHandler.logError('AndroidMusicScanner.scan', e, stack);
    }
    return validSongs;
  }
}
