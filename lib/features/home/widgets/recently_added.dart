import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../library/providers/library_provider.dart';
import '../../../shared/widgets/song_tile.dart';

/// Recently added songs list section on the Home screen.
class RecentlyAddedSection extends ConsumerWidget {
  const RecentlyAddedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAddedAsync = ref.watch(recentlyAddedProvider);

    return recentAddedAsync.when(
      data: (songs) {
        if (songs.isEmpty) return const SizedBox.shrink();

        final displaySongs = songs.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recently Added',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displaySongs.length,
              itemBuilder: (context, index) {
                final song = displaySongs[index];
                return SongTile(
                  song: song,
                  contextQueue: songs,
                );
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
