import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/music_folder.dart';
import '../../../models/song.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/song_tile.dart';
import '../../player/providers/player_provider.dart';
import '../providers/library_provider.dart';

/// Folders tab inside Your Library allowing users to browse music by storage directory.
class FoldersTab extends ConsumerWidget {
  const FoldersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(allFoldersProvider);

    return foldersAsync.when(
      data: (folders) {
        if (folders.isEmpty) {
          return const EmptyStateView(
            icon: Icons.folder_rounded,
            title: 'No Folders Found',
            message:
                'Scan your device to view audio files organized by physical folder.',
          );
        }

        return ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.darkSecondarySurface,
                ),
                child: const Icon(Icons.folder_rounded,
                    color: AppColors.primaryGreen),
              ),
              title: Text(
                folder.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                '${folder.songCount} ${folder.songCount == 1 ? 'song' : 'songs'}\n${folder.path}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.darkTextSecondary, fontSize: 11),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.darkTextSecondary),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => FolderDetailScreen(folder: folder)),
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

/// Detail screen showing tracks inside a selected storage folder.
class FolderDetailScreen extends ConsumerStatefulWidget {
  final MusicFolder folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolderSongs();
  }

  Future<void> _loadFolderSongs() async {
    final db = ref.read(databaseProvider);
    final songs = await db.getSongsInFolder(widget.folder.path);
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
        title: Text(widget.folder.name),
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
