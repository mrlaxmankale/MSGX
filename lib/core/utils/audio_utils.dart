import 'dart:io';
import '../constants/app_constants.dart';

/// Audio utilities for validating extensions, calculating paths, and extracting folder names.
class AudioUtils {
  /// Checks whether a given file path or extension represents a supported audio format.
  static bool isSupportedAudioFile(String path) {
    if (path.isEmpty) return false;
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return false;
    final ext = path.substring(dotIndex + 1).toLowerCase();
    return AppConstants.supportedAudioExtensions.contains(ext);
  }

  /// Extracts the parent directory name from a given file path.
  static String getParentDirectoryName(String filePath) {
    if (filePath.isEmpty) return 'Unknown Folder';
    try {
      final file = File(filePath);
      return file.parent.path.split(Platform.pathSeparator).last;
    } catch (_) {
      return 'Unknown Folder';
    }
  }

  /// Extracts the parent directory full path from a given file path.
  static String getParentDirectoryPath(String filePath) {
    if (filePath.isEmpty) return '';
    try {
      return File(filePath).parent.path;
    } catch (_) {
      return '';
    }
  }

  /// Sanitizes track titles by stripping common junk like track numbers ("01 - "), extensions, etc.
  static String sanitizeTrackTitle(String rawTitle, String? fallbackFileName) {
    var title = rawTitle.trim();
    if (title.isEmpty && fallbackFileName != null) {
      title = fallbackFileName;
      final dot = title.lastIndexOf('.');
      if (dot != -1) {
        title = title.substring(0, dot);
      }
    }
    // Remove track number prefixes like "01. ", "01 - "
    title = title.replaceFirst(RegExp(r'^\d{1,3}[\s\.\-_]+'), '');
    return title.isEmpty ? 'Unknown Title' : title;
  }
}
