import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/playlist.dart';
import '../../../models/song.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../player/providers/player_provider.dart';
import '../providers/playlists_provider.dart';

/// Detail screen showing playlist tracks, reordering, and playback actions.
class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    if (widget.playlist.id == null) return;
    final songs = await ref
        .read(playlistsProvider.notifier)
        .getPlaylistSongs(widget.playlist.id!);
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
        title: Text(widget.playlist.name),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _songs.isEmpty
              ? const EmptyStateView(
                  icon: Icons.music_off_rounded,
                  title: 'This playlist is empty',
                  message:
                      'Add songs from Your Library by tapping the three dots next to any song.',
                )
              : Column(
                  children: [
                    // Play All & Shuffle Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow_rounded,
                                color: Colors.black),
                            label: const Text('Play',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              ref
                                  .read(audioPlayerServiceProvider)
                                  .playSong(_songs.first, contextQueue: _songs);
                            },
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.shuffle_rounded,
                                color: Colors.white),
                            onPressed: () {
                              ref
                                  .read(audioPlayerServiceProvider)
                                  .toggleShuffle();
                              ref
                                  .read(audioPlayerServiceProvider)
                                  .playSong(_songs.first, contextQueue: _songs);
                            },
                          ),
                          const Spacer(),
                          Text(
                            '${_songs.length} ${_songs.length == 1 ? 'song' : 'songs'}',
                            style: const TextStyle(
                                color: AppColors.darkTextSecondary,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Reorderable list
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: _songs.length,
                        // ignore: deprecated_member_use
                        onReorder: (oldIndex, newIndex) async {
                          setState(() {
                            if (oldIndex < newIndex) newIndex -= 1;
                            final item = _songs.removeAt(oldIndex);
                            _songs.insert(newIndex, item);
                          });
                          if (widget.playlist.id != null) {
                            final ids = _songs.map((s) => s.id!).toList();
                            await ref
                                .read(playlistsProvider.notifier)
                                .reorderSongs(widget.playlist.id!, ids);
                          }
                        },
                        itemBuilder: (context, index) {
                          final song = _songs[index];
                          return Dismissible(
                            key: ValueKey('pl_song_${song.id}_$index'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: AppColors.error,
                              child: const Icon(Icons.delete_rounded,
                                  color: Colors.white),
                            ),
                            onDismissed: (_) async {
                              setState(() {
                                _songs.removeAt(index);
                              });
                              if (widget.playlist.id != null &&
                                  song.id != null) {
                                await ref
                                    .read(playlistsProvider.notifier)
                                    .removeSongFromPlaylist(
                                        widget.playlist.id!, song.id!);
                              }
                            },
                            child: SongTile(
                              key: ValueKey('song_tile_${song.id}'),
                              song: song,
                              contextQueue: _songs,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
