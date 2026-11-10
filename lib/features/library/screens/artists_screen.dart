import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/artist.dart';
import '../../../models/song.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../player/providers/player_provider.dart';
import '../providers/library_provider.dart';

/// Artists list view inside Your Library.
class ArtistsTab extends ConsumerWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(allArtistsProvider);

    return artistsAsync.when(
      data: (artists) {
        if (artists.isEmpty) {
          return const EmptyStateView(
            icon: Icons.person_rounded,
            title: 'No Artists Found',
            message: 'Scan your device to organize songs by artist.',
          );
        }

        return ListView.builder(
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkSecondarySurface,
                ),
                child: Center(
                  child: Text(
                    artist.name.isNotEmpty ? artist.name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryGreen),
                  ),
                ),
              ),
              title: Text(
                artist.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                '${artist.songCount} ${artist.songCount == 1 ? 'song' : 'songs'} • ${artist.albumCount} ${artist.albumCount == 1 ? 'album' : 'albums'}',
                style: const TextStyle(
                    color: AppColors.darkTextSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.darkTextSecondary),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ArtistDetailScreen(artist: artist)),
                );
              },
            );
          },
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

/// Detail screen showing songs performed by selected Artist.
class ArtistDetailScreen extends ConsumerStatefulWidget {
  final Artist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  ConsumerState<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends ConsumerState<ArtistDetailScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtistSongs();
  }

  Future<void> _loadArtistSongs() async {
    final db = ref.read(databaseProvider);
    final songs = await db.getSongsForArtist(widget.artist.name);
    if (mounted) {
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(widget.artist.name),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded,
                            color: Colors.black),
                        label: const Text('Play All',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: _songs.isEmpty
                            ? null
                            : () {
                                ref.read(audioPlayerServiceProvider).playSong(
                                    _songs.first,
                                    contextQueue: _songs);
                              },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.shuffle_rounded,
                            color: Colors.white),
                        onPressed: _songs.isEmpty
                            ? null
                            : () {
                                ref
                                    .read(audioPlayerServiceProvider)
                                    .toggleShuffle();
                                ref.read(audioPlayerServiceProvider).playSong(
                                    _songs.first,
                                    contextQueue: _songs);
                              },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return SongTile(song: song, contextQueue: _songs);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
