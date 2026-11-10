import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../utils/audio_utils.dart';
import '../utils/error_handler.dart';

/// Service responsible for filesystem operations, user file imports, and directory management.
class FileService {
  /// Allows the user to select one or multiple audio files using system file picker
  static Future<List<File>> pickAudioFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedAudioExtensions,
        allowMultiple: true,
      );

      if (result != null && result.paths.isNotEmpty) {
        return result.paths
            .whereType<String>()
            .map((path) => File(path))
            .where((file) => file.existsSync())
            .toList();
      }
    } catch (e, stack) {
      ErrorHandler.logError('FileService.pickAudioFiles', e, stack);
    }
    return [];
  }

  /// Allows the user to select an entire folder containing audio files
  static Future<List<File>> pickAudioFolder() async {
    try {
      final String? selectedDirectory =
          await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        final dir = Directory(selectedDirectory);
        if (await dir.exists()) {
          final List<File> audioFiles = [];
          await for (final entity
              in dir.list(recursive: true, followLinks: false)) {
            if (entity is File &&
                AudioUtils.isSupportedAudioFile(entity.path)) {
              audioFiles.add(entity);
            }
          }
          return audioFiles;
        }
      }
    } catch (e, stack) {
      ErrorHandler.logError('FileService.pickAudioFolder', e, stack);
    }
    return [];
  }

  /// Get application document directory
  static Future<Directory> getAppDocumentDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Verify whether a file exists and is readable
  static bool isFileReadable(String path) {
    if (path.isEmpty) return false;
    try {
      final file = File(path);
      return file.existsSync() && file.lengthSync() > 0;
    } catch (_) {
      return false;
    }
  }

  /// Get file size in bytes safely
  static int getFileSize(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        return file.lengthSync();
      }
    } catch (_) {}
    return 0;
  }
}
