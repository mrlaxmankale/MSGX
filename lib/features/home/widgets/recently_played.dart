import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../library/providers/library_provider.dart';
import '../../player/providers/player_provider.dart';
import '../../../shared/widgets/album_card.dart';
import '../../../models/album.dart';

/// Horizontally scrollable Recently Played section on the Home screen.
class RecentlyPlayedSection extends ConsumerWidget {
  const RecentlyPlayedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentlyPlayedProvider);

    return recentAsync.when(
      data: (songs) {
        if (songs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recently Played',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 195,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  // Map to temporary album-style presentation
                  final album = Album(
                    name: song.title,
                    artist: song.artist,
                    artworkReference: song.artworkReference,
                    songCount: 1,
                  );

                  return AlbumCard(
                    album: album,
                    width: 135,
                    onTap: () {
                      ref.read(audioPlayerServiceProvider).playSong(
                            song,
                            contextQueue: songs,
                          );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
