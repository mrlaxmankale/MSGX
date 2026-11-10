import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../player/providers/player_provider.dart';
import '../providers/favorites_provider.dart';

/// Favorites (Liked Songs) screen with Spotify-style purple-blue gradient header.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: favoritesAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return const EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'Songs you like will appear here',
              message:
                  'Save songs you love by tapping the heart icon anywhere in MSGX.',
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: const Color(0xFF450AF5),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF450AF5), Color(0xFF191414)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Liked Songs',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Play & Shuffle Action Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded,
                            color: Colors.black),
                        label: const Text(
                          'Play All',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          ref.read(audioPlayerServiceProvider).playSong(
                                songs.first,
                                contextQueue: songs,
                              );
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.shuffle_rounded,
                            color: Colors.white, size: 24),
                        tooltip: 'Shuffle Favorites',
                        onPressed: () {
                          ref.read(audioPlayerServiceProvider).toggleShuffle();
                          ref.read(audioPlayerServiceProvider).playSong(
                                songs.first,
                                contextQueue: songs,
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // List of favorite songs
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = songs[index];
                    return SongTile(
                      song: song,
                      contextQueue: songs,
                    );
                  },
                  childCount: songs.length,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(
            child:
                Text('Error: $e', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
