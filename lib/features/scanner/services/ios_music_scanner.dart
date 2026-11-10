import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/metadata_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../models/song.dart';

/// iOS media discovery engine querying MPMediaLibrary and integrating document import.
class IOSMusicScanner {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Scans iOS Apple Music library via MPMediaQuery
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
        final duration = songModel.duration ?? 0;
        if (duration < minDurationMs) continue;

        final song = MetadataService.fromSongModel(songModel);
        validSongs.add(song);

        onProgress?.call(discovered, validSongs.length);
      }
    } catch (e, stack) {
      ErrorHandler.logError('IOSMusicScanner.scan', e, stack);
    }
    return validSongs;
  }

  /// Imports audio files picked from iOS Files app / document picker
  Future<List<Song>> importUserFiles() async {
    final List<Song> importedSongs = [];
    try {
      final files = await FileService.pickAudioFiles();
      for (final file in files) {
        final song = await MetadataService.fromFile(file);
        importedSongs.add(song);
      }
    } catch (e, stack) {
      ErrorHandler.logError('IOSMusicScanner.importUserFiles', e, stack);
    }
    return importedSongs;
  }
}
