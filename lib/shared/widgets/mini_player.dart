import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/artwork_service.dart';
import '../../../features/player/providers/player_provider.dart';
import '../../../features/favorites/providers/favorites_provider.dart';
import '../../../navigation/route_manager.dart';

/// Persistent Spotify-inspired floating mini-player.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(playerPositionStreamProvider);
    final durationAsync = ref.watch(playerDurationStreamProvider);

    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    final durationMs =
        durationAsync.value?.inMilliseconds ?? currentSong.duration;
    final positionMs = positionAsync.value?.inMilliseconds ?? 0;
    final double progress =
        durationMs > 0 ? (positionMs / durationMs).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(RouteManager.nowPlaying);
        },
        child: Container(
          height: AppConstants.miniPlayerHeight,
          decoration: BoxDecoration(
            color: AppColors.darkSecondarySurface,
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            child: Stack(
              children: [
                // Main mini player row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      // Album Artwork
                      ArtworkService.buildArtwork(
                        id: int.tryParse(currentSong.artworkReference ?? ''),
                        type: ArtworkType.AUDIO,
                        localFilePath: currentSong.artworkReference,
                        size: 46.0,
                        borderRadius: 4.0,
                        fallbackTitle: currentSong.title,
                      ),
                      const SizedBox(width: 12),

                      // Title & Artist
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
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
                              currentSong.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Favorite Button Shortcut
                      IconButton(
                        icon: Icon(
                          currentSong.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: currentSong.isFavorite
                              ? AppColors.primaryGreen
                              : AppColors.darkTextSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(currentSong);
                        },
                      ),

                      // Play/Pause Action Button
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          ref
                              .read(audioPlayerServiceProvider)
                              .togglePlayPause();
                        },
                      ),
                    ],
                  ),
                ),

                // Tiny progress bar at the bottom edge
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen),
                    minHeight: 2.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
