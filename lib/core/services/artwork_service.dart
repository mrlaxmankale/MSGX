import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../constants/app_colors.dart';
import '../utils/error_handler.dart';

/// Service responsible for managing, resolving, and fallback rendering of album artwork.
class ArtworkService {
  /// Checks if a local image file exists in the audio directory (e.g., cover.jpg, folder.jpg)
  static Future<String?> findFolderArtwork(String songFilePath) async {
    try {
      if (songFilePath.isEmpty) return null;
      final dir = File(songFilePath).parent;
      final commonNames = [
        'cover.jpg',
        'cover.png',
        'folder.jpg',
        'folder.png',
        'albumart.jpg',
        'album.jpg'
      ];

      for (final name in commonNames) {
        final imgFile = File('${dir.path}${Platform.pathSeparator}$name');
        if (await imgFile.exists()) {
          return imgFile.path;
        }
      }
    } catch (e) {
      ErrorHandler.logError('ArtworkService.findFolderArtwork', e);
    }
    return null;
  }

  /// Builds an artwork widget given a song/album identifier, with Spotify-inspired fallback
  static Widget buildArtwork({
    required int? id,
    required ArtworkType type,
    String? localFilePath,
    double size = 50.0,
    double borderRadius = 6.0,
    String? fallbackTitle,
  }) {
    // If a local image file path exists, load from file
    if (localFilePath != null &&
        localFilePath.isNotEmpty &&
        File(localFilePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          File(localFilePath),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => buildFallbackPlaceholder(
            title: fallbackTitle,
            size: size,
            borderRadius: borderRadius,
          ),
        ),
      );
    }

    // If ID is valid, attempt to query system artwork via on_audio_query
    if (id != null && id > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: QueryArtworkWidget(
          id: id,
          type: type,
          artworkWidth: size,
          artworkHeight: size,
          artworkFit: BoxFit.cover,
          artworkBorder: BorderRadius.circular(borderRadius),
          nullArtworkWidget: buildFallbackPlaceholder(
            title: fallbackTitle,
            size: size,
            borderRadius: borderRadius,
          ),
          errorBuilder: (_, __, ___) => buildFallbackPlaceholder(
            title: fallbackTitle,
            size: size,
            borderRadius: borderRadius,
          ),
        ),
      );
    }

    // Default to Spotify-style geometric gradient placeholder
    return buildFallbackPlaceholder(
      title: fallbackTitle,
      size: size,
      borderRadius: borderRadius,
    );
  }

  /// Generates a Spotify-inspired dark gradient placeholder with music note icon
  static Widget buildFallbackPlaceholder({
    String? title,
    double size = 50.0,
    double borderRadius = 6.0,
  }) {
    // Generate deterministic subtle gradient hue based on title hash
    final hash =
        (title ?? 'MSGX').codeUnits.fold(0, (prev, elem) => prev + elem);
    final List<Color> gradientColors = [
      Color.lerp(AppColors.darkSecondarySurface, const Color(0xFF333333),
          (hash % 10) / 10.0)!,
      AppColors.darkPrimarySurface,
    ];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: AppColors.darkTextSecondary.withValues(alpha: 0.6),
          size: size * 0.45,
        ),
      ),
    );
  }
}
