import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../player/providers/player_provider.dart';
import '../../scanner/screens/scanner_screen.dart';
import '../providers/library_provider.dart';

/// Songs tab inside Your Library.
class SongsTab extends ConsumerWidget {
  const SongsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(allSongsProvider);
    final sortOption = ref.watch(songSortProvider);

    return songsAsync.when(
      data: (songs) {
        if (songs.isEmpty) {
          return EmptyStateView(
            icon: Icons.music_note_rounded,
            title: 'No Songs Found',
            message:
                'Scan your device to find and play your local audio files.',
            actionLabel: 'Scan Music',
            onAction: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
            },
          );
        }

        return Column(
          children: [
            // Controls header: Play all, Shuffle all, and Sort button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                  const Spacer(),

                  // Sort Menu
                  PopupMenuButton<SongSortOption>(
                    icon: const Icon(Icons.sort_rounded,
                        color: Colors.white, size: 20),
                    tooltip: 'Sort songs',
                    initialValue: sortOption,
                    color: AppColors.darkPrimarySurface,
                    onSelected: (newSort) {
                      ref.read(songSortProvider.notifier).state = newSort;
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: SongSortOption.titleAsc,
                        child: Text('Title (A to Z)',
                            style: TextStyle(color: Colors.white)),
                      ),
                      PopupMenuItem(
                        value: SongSortOption.artistAsc,
                        child: Text('Artist',
                            style: TextStyle(color: Colors.white)),
                      ),
                      PopupMenuItem(
                        value: SongSortOption.albumAsc,
                        child: Text('Album',
                            style: TextStyle(color: Colors.white)),
                      ),
                      PopupMenuItem(
                        value: SongSortOption.dateAddedDesc,
                        child: Text('Recently Added',
                            style: TextStyle(color: Colors.white)),
                      ),
                      PopupMenuItem(
                        value: SongSortOption.durationDesc,
                        child: Text('Duration',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),

                  // Shuffle All button
                  IconButton(
                    icon: const Icon(Icons.shuffle_rounded,
                        color: AppColors.primaryGreen, size: 22),
                    tooltip: 'Shuffle all songs',
                    onPressed: () {
                      if (songs.isNotEmpty) {
                        ref.read(audioPlayerServiceProvider).toggleShuffle();
                        ref.read(audioPlayerServiceProvider).playSong(
                              songs.first,
                              contextQueue: songs,
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Songs list
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return SongTile(
                    song: song,
                    contextQueue: songs,
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      error: (e, _) => Center(
          child:
              Text('Error: $e', style: const TextStyle(color: Colors.white))),
    );
  }
}
