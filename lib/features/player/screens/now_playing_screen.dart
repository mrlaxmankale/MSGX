import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/song.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../lyrics/screens/lyrics_screen.dart';
import '../../equalizer/screens/equalizer_screen.dart';
import '../providers/player_provider.dart';
import '../widgets/album_artwork.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

/// Full-screen Spotify-inspired Now Playing view.
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final errorMessage = ref.watch(playerErrorProvider);

    if (currentSong == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'No track currently playing',
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 32, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'PLAYING FROM LIBRARY',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentSong.album,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: Colors.white),
                    onPressed: () =>
                        _showNowPlayingOptions(context, ref, currentSong),
                  ),
                ],
              ),
            ),

            // Error Banner if file has issue
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Large Animated Album Artwork
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: PlayerAlbumArtwork(
                song: currentSong,
                isPlaying: isPlaying,
              ),
            ),

            const Spacer(),

            // Song Title, Artist, and Favorite Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentSong.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      currentSong.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: currentSong.isFavorite
                          ? AppColors.primaryGreen
                          : Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(currentSong);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Seek Bar
            const PlayerProgressBar(),

            const SizedBox(height: 12),

            // Playback Controls (Shuffle, Prev, Play/Pause, Next, Repeat)
            const PlayerControls(),

            const SizedBox(height: 16),

            // Bottom Auxiliary Actions: Equalizer, Lyrics, and Queue
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Equalizer / Audio Settings
                  IconButton(
                    icon: const Icon(Icons.tune_rounded,
                        color: AppColors.darkTextSecondary),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const EqualizerScreen()),
                      );
                    },
                  ),

                  // Offline Lyrics Button
                  TextButton.icon(
                    icon: const Icon(Icons.lyrics_rounded,
                        size: 18, color: AppColors.primaryGreen),
                    label: const Text(
                      'LYRICS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        letterSpacing: 1.0,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LyricsScreen(song: currentSong),
                        ),
                      );
                    },
                  ),

                  // Queue Drawer Button
                  IconButton(
                    icon: const Icon(Icons.queue_music_rounded,
                        color: AppColors.darkTextSecondary),
                    onPressed: () => _showQueueModal(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showQueueModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkPrimarySurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (c, scrollController) {
            final queue = ref.watch(playerQueueProvider);
            final currentSong = ref.watch(currentSongProvider);
            final playerService = ref.watch(audioPlayerServiceProvider);

            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Current Queue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          playerService.clearQueue();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: queue.isEmpty
                      ? const Center(
                          child: Text('Queue is empty',
                              style: TextStyle(
                                  color: AppColors.darkTextSecondary)),
                        )
                      : ReorderableListView.builder(
                          scrollController: scrollController,
                          itemCount: queue.length,
                          onReorder: (oldIndex, newIndex) { // ignore: deprecated_member_use
                            playerService.reorderQueue(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final song = queue[index];
                            final isPlayingThis = song.id == currentSong?.id;

                            return Dismissible(
                              key: ValueKey('queue_${song.mediaId}_$index'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: AppColors.error,
                                child: const Icon(Icons.delete_rounded,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) {
                                playerService.removeFromQueue(index);
                              },
                              child: ListTile(
                                key: ValueKey('tile_${song.mediaId}_$index'),
                                leading: isPlayingThis
                                    ? const Icon(Icons.volume_up_rounded,
                                        color: AppColors.primaryGreen)
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                            color: AppColors.darkTextSecondary),
                                      ),
                                title: Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isPlayingThis
                                        ? AppColors.primaryGreen
                                        : Colors.white,
                                    fontWeight: isPlayingThis
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.darkTextSecondary,
                                      fontSize: 12),
                                ),
                                trailing: const Icon(Icons.drag_handle_rounded,
                                    color: AppColors.darkTextSecondary),
                                onTap: () {
                                  playerService.playSong(song,
                                      startIndex: index);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNowPlayingOptions(BuildContext context, WidgetRef ref, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSecondarySurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: Colors.white),
                title: const Text('Sleep Timer',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSleepTimerDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.speed_rounded, color: Colors.white),
                title: const Text('Playback Speed',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSpeedDialog(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSleepTimerDialog(BuildContext context, WidgetRef ref) {
    final playerService = ref.read(audioPlayerServiceProvider);
    final durations = [5, 10, 15, 30, 45, 60];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.darkPrimarySurface,
          title:
              const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...durations.map((mins) => ListTile(
                    title: Text('$mins minutes',
                        style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      playerService.setSleepTimer(mins);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Sleep timer set for $mins minutes')),
                      );
                    },
                  )),
              ListTile(
                title: const Text('Turn off timer',
                    style: TextStyle(color: AppColors.error)),
                onTap: () {
                  playerService.cancelSleepTimer();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedDialog(BuildContext context, WidgetRef ref) {
    final playerService = ref.read(audioPlayerServiceProvider);
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.darkPrimarySurface,
          title: const Text('Playback Speed',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: speeds
                .map((s) => ListTile(
                      title: Text('${s}x',
                          style: const TextStyle(color: Colors.white)),
                      trailing: playerService.playbackSpeed == s
                          ? const Icon(Icons.check,
                              color: AppColors.primaryGreen)
                          : null,
                      onTap: () {
                        playerService.setPlaybackSpeed(s);
                        Navigator.pop(ctx);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
