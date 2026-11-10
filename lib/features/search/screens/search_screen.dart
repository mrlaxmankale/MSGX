import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/song.dart';
import '../../../models/album.dart';
import '../../../models/artist.dart';
import '../../../shared/widgets/album_card.dart';
import '../../../shared/widgets/artist_card.dart';
import '../../../shared/widgets/song_tile.dart';
import '../providers/search_provider.dart';
import '../../library/screens/albums_screen.dart';
import '../../library/screens/artists_screen.dart';

/// Real-time offline search screen for MSGX.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Spotify-style white search bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'What do you want to listen to?',
                  hintStyle:
                      const TextStyle(color: Color(0xFF757575), fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Colors.black),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: Colors.black),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  ref.read(searchQueryProvider.notifier).state = val;
                },
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    ref.read(searchHistoryProvider.notifier).addQuery(val);
                  }
                },
              ),
            ),
          ),

          // Content: Search history or Real-time Search Results
          Expanded(
            child: query.trim().isEmpty
                ? _buildSearchHistory(context, ref, history)
                : resultsAsync.when(
                    data: (results) {
                      final songs = (results['songs'] as List).cast<Song>();
                      final albums = (results['albums'] as List).cast<Album>();
                      final artists =
                          (results['artists'] as List).cast<Artist>();

                      if (songs.isEmpty && albums.isEmpty && artists.isEmpty) {
                        return const Center(
                          child: Text(
                            'No matching music found on device',
                            style:
                                TextStyle(color: AppColors.darkTextSecondary),
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // Matching Artists
                          if (artists.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text(
                                'Artists',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: artists.length,
                                itemBuilder: (ctx, idx) => ArtistCard(
                                  artist: artists[idx],
                                  onTap: () {
                                    ref
                                        .read(searchHistoryProvider.notifier)
                                        .addQuery(query);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ArtistDetailScreen(
                                            artist: artists[idx]),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Matching Albums
                          if (albums.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text(
                                'Albums',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              height: 185,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: albums.length,
                                itemBuilder: (ctx, idx) => AlbumCard(
                                  album: albums[idx],
                                  onTap: () {
                                    ref
                                        .read(searchHistoryProvider.notifier)
                                        .addQuery(query);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AlbumDetailScreen(
                                            album: albums[idx]),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Matching Songs
                          if (songs.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text(
                                'Songs',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                            ...songs.map(
                              (s) => SongTile(
                                song: s,
                                contextQueue: songs,
                                onTap: () {
                                  ref
                                      .read(searchHistoryProvider.notifier)
                                      .addQuery(query);
                                },
                              ),
                            ),
                          ],

                          const SizedBox(height: 80),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen),
                    ),
                    error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(
      BuildContext context, WidgetRef ref, List<String> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'Play what you love\nSearch for songs, artists, or albums',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTextSecondary,
            height: 1.5,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  ref.read(searchHistoryProvider.notifier).clearHistory();
                },
                child: const Text('Clear all',
                    style: TextStyle(
                        color: AppColors.darkTextSecondary, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                leading: const Icon(Icons.history_rounded,
                    color: AppColors.darkTextSecondary),
                title: Text(item, style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.darkTextSecondary, size: 18),
                  onPressed: () {
                    ref.read(searchHistoryProvider.notifier).removeQuery(item);
                  },
                ),
                onTap: () {
                  _searchController.text = item;
                  ref.read(searchQueryProvider.notifier).state = item;
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
