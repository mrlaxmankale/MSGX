import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/artwork_service.dart';
import '../../../models/album.dart';

/// Spotify-style rectangular album card.
class AlbumCard extends ConsumerWidget {
  final Album album;
  final VoidCallback? onTap;
  final double width;

  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.width = 140.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Artwork with subtle rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ArtworkService.buildArtwork(
                  id: album.id,
                  type: ArtworkType.ALBUM,
                  localFilePath: album.artworkReference,
                  size: width,
                  borderRadius: 6.0,
                  fallbackTitle: album.name,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Album Name
            Text(
              album.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),

            // Artist Name & Track count
            Text(
              album.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
