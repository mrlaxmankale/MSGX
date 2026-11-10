import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/artist.dart';

/// Spotify-style circular artist avatar card.
class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final double size;

  const ArtistCard({
    super.key,
    required this.artist,
    this.onTap,
    this.size = 110.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 14.0),
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkSecondarySurface,
                    AppColors.darkCardHighlight
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  artist.name.isNotEmpty ? artist.name[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${artist.songCount} ${artist.songCount == 1 ? 'song' : 'songs'}',
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
