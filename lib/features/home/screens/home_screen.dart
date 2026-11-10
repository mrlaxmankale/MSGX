import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../navigation/route_manager.dart';
import '../../../shared/widgets/album_card.dart';
import '../../../shared/widgets/artist_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../library/providers/library_provider.dart';
import '../../library/screens/albums_screen.dart';
import '../../library/screens/artists_screen.dart';
import '../../scanner/screens/scanner_screen.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/recently_added.dart';
import '../widgets/recently_played.dart';

/// Main Spotify-inspired Home Screen for MSGX.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSongsAsync = ref.watch(allSongsProvider);
    final albumsAsync = ref.watch(allAlbumsProvider);
    final artistsAsync = ref.watch(allArtistsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'MSGX',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.radar_rounded, color: Colors.white),
            tooltip: 'Scan Music',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).pushNamed(RouteManager.settings);
            },
          ),
        ],
      ),
      body: allSongsAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return EmptyStateView(
              icon: Icons.music_note_rounded,
              title: 'Your Music Library is Empty',
              message:
                  'MSGX discovers audio files stored on your device automatically. Grant permission and scan to begin playback.',
              actionLabel: 'Scan Device Music',
              onAction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScannerScreen()),
                );
              },
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.darkPrimarySurface,
            onRefresh: () async {
              ref.invalidate(allSongsProvider);
              ref.invalidate(allAlbumsProvider);
              ref.invalidate(allArtistsProvider);
              ref.invalidate(recentlyAddedProvider);
              ref.invalidate(recentlyPlayedProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Quick Access Grid
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text(
                      Formatters.getGreeting(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: QuickAccessGrid(),
                  ),

                  const SizedBox(height: 24),

                  // Recently Played Section
                  const RecentlyPlayedSection(),

                  const SizedBox(height: 24),

                  // Popular Local Albums Section
                  albumsAsync.when(
                    data: (albums) {
                      if (albums.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Local Albums',
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              scrollDirection: Axis.horizontal,
                              itemCount: albums.length,
                              itemBuilder: (context, index) {
                                final album = albums[index];
                                return AlbumCard(
                                  album: album,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AlbumDetailScreen(album: album),
                                      ),
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
                  ),

                  const SizedBox(height: 24),

                  // Recently Added Section
                  const RecentlyAddedSection(),

                  const SizedBox(height: 24),

                  // Local Artists Section
                  artistsAsync.when(
                    data: (artists) {
                      if (artists.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Artists',
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
                            height: 160,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              scrollDirection: Axis.horizontal,
                              itemCount: artists.length,
                              itemBuilder: (context, index) {
                                final artist = artists[index];
                                return ArtistCard(
                                  artist: artist,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ArtistDetailScreen(artist: artist),
                                      ),
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
                  ),

                  const SizedBox(height: 100), // padding for miniplayer
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (err, _) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
