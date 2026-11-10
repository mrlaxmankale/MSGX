import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:on_audio_query/on_audio_query.dart';
import '../utils/audio_utils.dart';
import '../../models/song.dart';
import 'artwork_service.dart';

/// Service responsible for extracting and normalizing metadata from files and MediaStore models.
class MetadataService {
  /// Converts an `on_audio_query` SongModel into an MSGX Song model
  static Song fromSongModel(SongModel model) {
    final sanitizedTitle = AudioUtils.sanitizeTrackTitle(
      model.title,
      model.displayNameWOExt,
    );

    final artist =
        (model.artist?.trim().isNotEmpty == true && model.artist != '<unknown>')
            ? model.artist!.trim()
            : 'Unknown Artist';

    final album =
        (model.album?.trim().isNotEmpty == true && model.album != '<unknown>')
            ? model.album!.trim()
            : 'Unknown Album';

    final format = model.fileExtension.isNotEmpty
        ? model.fileExtension.toLowerCase()
        : (model.data.contains('.')
            ? model.data.split('.').last.toLowerCase()
            : 'mp3');

    return Song(
      mediaId: model.id.toString(),
      title: sanitizedTitle,
      artist: artist,
      album: album,
      albumId: model.albumId,
      artistId: model.artistId,
      filePathOrUri: model.data,
      duration: model.duration ?? 0,
      fileSize: model.size,
      format: format,
      artworkReference: model.id.toString(),
      dateAdded:
          (model.dateAdded ?? DateTime.now().millisecondsSinceEpoch ~/ 1000) *
              1000,
      lastModified: (model.dateModified ??
              DateTime.now().millisecondsSinceEpoch ~/ 1000) *
          1000,
      trackNumber: model.track,
      genre: model.genre,
    );
  }

  /// Converts a physical File into an MSGX Song model with filesystem heuristics
  static Future<Song> fromFile(File file) async {
    final path = file.path;
    final fileName = path.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    final baseName =
        dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
    final ext =
        dotIndex != -1 ? fileName.substring(dotIndex + 1).toLowerCase() : 'mp3';

    // Generate stable unique mediaId using SHA1 of absolute path
    final mediaId = sha1.convert(utf8.encode(path)).toString();

    // Check for folder artwork
    final folderArtwork = await ArtworkService.findFolderArtwork(path);

    int statSize = 0;
    int modified = DateTime.now().millisecondsSinceEpoch;
    try {
      final stat = await file.stat();
      statSize = stat.size;
      modified = stat.modified.millisecondsSinceEpoch;
    } catch (_) {}

    final sanitizedTitle = AudioUtils.sanitizeTrackTitle(baseName, fileName);
    final parentDir = AudioUtils.getParentDirectoryName(path);

    return Song(
      mediaId: mediaId,
      title: sanitizedTitle,
      artist: parentDir.isNotEmpty &&
              parentDir != 'Music' &&
              parentDir != 'Download'
          ? parentDir
          : 'Local Music',
      album: parentDir.isNotEmpty ? parentDir : 'Local Files',
      filePathOrUri: path,
      duration: 0, // Will be updated when played or parsed
      fileSize: statSize,
      format: ext,
      artworkReference: folderArtwork,
      dateAdded: modified,
      lastModified: modified,
    );
  }
}
