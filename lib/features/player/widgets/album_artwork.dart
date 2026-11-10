import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/services/artwork_service.dart';
import '../../../models/song.dart';

/// Large animated square album cover for the Now Playing screen.
class PlayerAlbumArtwork extends StatelessWidget {
  final Song song;
  final bool isPlaying;

  const PlayerAlbumArtwork({
    super.key,
    required this.song,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width - 64;

    return Center(
      child: AnimatedScale(
        scale: isPlaying ? 1.0 : 0.94,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                offset: const Offset(0, 16),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: ArtworkService.buildArtwork(
              id: int.tryParse(song.artworkReference ?? ''),
              type: ArtworkType.AUDIO,
              localFilePath: song.artworkReference,
              size: size,
              borderRadius: 12.0,
              fallbackTitle: song.title,
            ),
          ),
        ),
      ),
    );
  }
}
