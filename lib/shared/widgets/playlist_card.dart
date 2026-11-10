import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/playlist.dart';

/// Spotify-style playlist card.
class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final double size;

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    this.size = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                gradient: const LinearGradient(
                  colors: [Color(0xFF333333), Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.playlist_play_rounded,
                  size: 48,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              playlist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${playlist.songCount} ${playlist.songCount == 1 ? 'song' : 'songs'}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
