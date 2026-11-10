import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/playlist.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/playlists_provider.dart';
import 'playlist_detail_screen.dart';

/// Playlists tab inside Your Library.
class PlaylistsTab extends ConsumerWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return playlistsAsync.when(
      data: (playlists) {
        if (playlists.isEmpty) {
          return EmptyStateView(
            icon: Icons.playlist_add_rounded,
            title: 'No Playlists Yet',
            message:
                'Create customized playlists to organize your favorite offline tracks.',
            actionLabel: 'Create Playlist',
            onAction: () => _showCreatePlaylistDialog(context, ref),
          );
        }

        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    '${playlists.length} ${playlists.length == 1 ? 'playlist' : 'playlists'}',
                    style: const TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add,
                        color: AppColors.primaryGreen, size: 20),
                    label: const Text('New',
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold)),
                    onPressed: () => _showCreatePlaylistDialog(context, ref),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.darkSecondarySurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(Icons.playlist_play_rounded,
                            color: AppColors.primaryGreen, size: 28),
                      ),
                    ),
                    title: Text(
                      playlist.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      '${playlist.songCount} ${playlist.songCount == 1 ? 'song' : 'songs'}',
                      style: const TextStyle(
                          color: AppColors.darkTextSecondary, fontSize: 12),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: AppColors.darkTextSecondary, size: 20),
                      color: AppColors.darkPrimarySurface,
                      onSelected: (action) {
                        if (action == 'rename' && playlist.id != null) {
                          _showRenamePlaylistDialog(context, ref, playlist);
                        } else if (action == 'delete' && playlist.id != null) {
                          _showDeletePlaylistDialog(context, ref, playlist);
                        }
                      },
                      itemBuilder: (ctx) => const [
                        PopupMenuItem(
                            value: 'rename',
                            child: Text('Rename',
                                style: TextStyle(color: Colors.white))),
                        PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete',
                                style: TextStyle(color: AppColors.error))),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PlaylistDetailScreen(playlist: playlist),
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
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      error: (e, _) => Center(
          child:
              Text('Error: $e', style: const TextStyle(color: Colors.white))),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkPrimarySurface,
        title:
            const Text('New Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: AppColors.darkTextSecondary),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.darkDivider)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryGreen)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(playlistsProvider.notifier).createPlaylist(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRenamePlaylistDialog(
      BuildContext context, WidgetRef ref, Playlist playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkPrimarySurface,
        title: const Text('Rename Playlist',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'New name',
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryGreen)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && playlist.id != null) {
                ref
                    .read(playlistsProvider.notifier)
                    .renamePlaylist(playlist.id!, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistDialog(
      BuildContext context, WidgetRef ref, Playlist playlist) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkPrimarySurface,
        title: const Text('Delete Playlist?',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'Are you sure you want to delete "${playlist.name}"? The songs on your device will not be deleted.',
            style: const TextStyle(color: AppColors.darkTextSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (playlist.id != null) {
                ref
                    .read(playlistsProvider.notifier)
                    .deletePlaylist(playlist.id!);
                Navigator.pop(ctx);
              }
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
