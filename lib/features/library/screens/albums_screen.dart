import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/artwork_service.dart';
import '../../../models/album.dart';
import '../../../models/song.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../player/providers/player_provider.dart';
import '../providers/library_provider.dart';

/// Albums grid view inside Your Library.
class AlbumsTab extends ConsumerWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(allAlbumsProvider);

    return albumsAsync.when(
      data: (albums) {
        if (albums.isEmpty) {
          return const EmptyStateView(
            icon: Icons.album_rounded,
            title: 'No Albums Found',
            message:
                'Scan your device to discover albums from your local music tags.',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.76,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => AlbumDetailScreen(album: album)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ArtworkService.buildArtwork(
                        id: album.id,
                        type: ArtworkType.ALBUM,
                        localFilePath: album.artworkReference,
                        size: double.infinity,
                        borderRadius: 8,
                        fallbackTitle: album.name,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album.artist} • ${album.songCount} songs',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.darkTextSecondary, fontSize: 11),
                  ),
                ],
              ),
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

/// Detail screen showing tracks belonging to a selected Album.
class AlbumDetailScreen extends ConsumerStatefulWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbumSongs();
  }

  Future<void> _loadAlbumSongs() async {
    final db = ref.read(databaseProvider);
    final songs =
        await db.getSongsForAlbum(widget.album.name, widget.album.artist);
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.darkPrimarySurface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF424242), AppColors.darkBackground],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    ArtworkService.buildArtwork(
                      id: widget.album.id,
                      type: ArtworkType.ALBUM,
                      localFilePath: widget.album.artworkReference,
                      size: 140,
                      borderRadius: 8,
                      fallbackTitle: widget.album.name,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.album.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.album.artist} • ${_songs.length} songs',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.darkTextSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded,
                        color: Colors.black),
                    label: const Text('Play Album',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _songs.isEmpty
                        ? null
                        : () {
                            ref
                                .read(audioPlayerServiceProvider)
                                .playSong(_songs.first, contextQueue: _songs);
                          },
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon:
                        const Icon(Icons.shuffle_rounded, color: Colors.white),
                    onPressed: _songs.isEmpty
                        ? null
                        : () {
                            ref
                                .read(audioPlayerServiceProvider)
                                .toggleShuffle();
                            ref
                                .read(audioPlayerServiceProvider)
                                .playSong(_songs.first, contextQueue: _songs);
                          },
                  ),
                ],
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen)),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = _songs[index];
                      return SongTile(song: song, contextQueue: _songs);
                    },
                    childCount: _songs.length,
                  ),
                ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}
