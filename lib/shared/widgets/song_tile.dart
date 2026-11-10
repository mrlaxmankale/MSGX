import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/artwork_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/song.dart';
import '../../../features/player/providers/player_provider.dart';
import '../../../features/favorites/providers/favorites_provider.dart';
import '../../../features/playlists/providers/playlists_provider.dart';

/// Clean Spotify-styled song list tile.
class SongTile extends ConsumerWidget {
  final Song song;
  final List<Song>? contextQueue;
  final VoidCallback? onTap;

  const SongTile({
    super.key,
    required this.song,
    this.contextQueue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final isCurrentSong =
        currentSong?.id == song.id || currentSong?.mediaId == song.mediaId;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      onTap: onTap ??
          () {
            ref.read(audioPlayerServiceProvider).playSong(
                  song,
                  contextQueue: contextQueue,
                );
          },
      leading: Stack(
        alignment: Alignment.center,
        children: [
          ArtworkService.buildArtwork(
            id: int.tryParse(song.artworkReference ?? ''),
            type: ArtworkType.AUDIO,
            localFilePath: song.artworkReference,
            size: 48.0,
            borderRadius: 4.0,
            fallbackTitle: song.title,
          ),
          if (isCurrentSong && isPlaying)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
        ],
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.w500,
          color: isCurrentSong ? AppColors.primaryGreen : Colors.white,
        ),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          if (song.duration > 0) ...[
            const SizedBox(width: 6),
            Text(
              Formatters.formatDurationMs(song.duration),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.darkTextMuted,
              ),
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert_rounded,
            color: AppColors.darkTextSecondary, size: 20),
        onPressed: () {
          _showSongOptionsBottomSheet(context, ref, song);
        },
      ),
    );
  }

  void _showSongOptionsBottomSheet(
      BuildContext context, WidgetRef ref, Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSecondarySurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ArtworkService.buildArtwork(
                      id: int.tryParse(song.artworkReference ?? ''),
                      type: ArtworkType.AUDIO,
                      localFilePath: song.artworkReference,
                      size: 52.0,
                      borderRadius: 6.0,
                      fallbackTitle: song.title,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${song.artist} • ${song.album}',
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
                  ],
                ),
              ),
              const Divider(height: 1),

              // Actions
              ListTile(
                leading:
                    const Icon(Icons.playlist_add_rounded, color: Colors.white),
                title: const Text('Add to playlist',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToPlaylistDialog(context, ref, song);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.queue_music_rounded, color: Colors.white),
                title: const Text('Play next',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(audioPlayerServiceProvider).insertNext(song);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playing next in queue')),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.add_to_queue_rounded, color: Colors.white),
                title: const Text('Add to queue',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(audioPlayerServiceProvider).addToQueue(song);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to queue')),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  song.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color:
                      song.isFavorite ? AppColors.primaryGreen : Colors.white,
                ),
                title: Text(
                  song.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(favoritesProvider.notifier).toggleFavorite(song);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.info_outline_rounded, color: Colors.white),
                title: const Text('Song info',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSongDetailsDialog(context, song);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylistDialog(
      BuildContext context, WidgetRef ref, Song song) {
    final playlistsAsync = ref.read(playlistsProvider);
    playlistsAsync.whenData((playlists) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: AppColors.darkPrimarySurface,
            title: const Text('Add to Playlist',
                style: TextStyle(color: Colors.white)),
            content: playlists.isEmpty
                ? const Text(
                    'No playlists found. Create one in Your Library first.',
                    style: TextStyle(color: AppColors.darkTextSecondary))
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (c, idx) {
                        final p = playlists[idx];
                        return ListTile(
                          title: Text(p.name,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text('${p.songCount} songs',
                              style: const TextStyle(
                                  color: AppColors.darkTextSecondary,
                                  fontSize: 12)),
                          onTap: () {
                            if (p.id != null && song.id != null) {
                              ref
                                  .read(playlistsProvider.notifier)
                                  .addSongToPlaylist(p.id!, song.id!);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added to ${p.name}')),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.primaryGreen)),
              ),
            ],
          );
        },
      );
    });
  }

  void _showSongDetailsDialog(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.darkPrimarySurface,
          title: const Text('Song Information',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Title', song.title),
                _detailRow('Artist', song.artist),
                _detailRow('Album', song.album),
                _detailRow(
                    'Duration', Formatters.formatDurationMs(song.duration)),
                _detailRow('Format', song.format.toUpperCase()),
                _detailRow('Size', Formatters.formatFileSize(song.fileSize)),
                _detailRow('Path', song.filePathOrUri),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close',
                  style: TextStyle(color: AppColors.primaryGreen)),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.darkTextSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }
}
