import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../models/playlist.dart';
import '../../../models/song.dart';
import '../../library/providers/library_provider.dart';

class PlaylistsNotifier extends StateNotifier<AsyncValue<List<Playlist>>> {
  final AppDatabase _db;

  PlaylistsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    try {
      final playlists = await _db.getAllPlaylists();
      state = AsyncValue.data(playlists);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> createPlaylist(String name, {String? description}) async {
    final id = await _db.createPlaylist(name, description: description);
    await loadPlaylists();
    return id;
  }

  Future<void> renamePlaylist(int id, String newName) async {
    await _db.renamePlaylist(id, newName);
    await loadPlaylists();
  }

  Future<void> deletePlaylist(int id) async {
    await _db.deletePlaylist(id);
    await loadPlaylists();
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    await _db.addSongToPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await _db.removeSongFromPlaylist(playlistId, songId);
    await loadPlaylists();
  }

  Future<void> reorderSongs(int playlistId, List<int> orderedSongIds) async {
    await _db.reorderPlaylistSongs(playlistId, orderedSongIds);
  }

  Future<List<Song>> getPlaylistSongs(int playlistId) async {
    return await _db.getSongsForPlaylist(playlistId);
  }
}

final playlistsProvider =
    StateNotifierProvider<PlaylistsNotifier, AsyncValue<List<Playlist>>>((ref) {
  final db = ref.watch(databaseProvider);
  return PlaylistsNotifier(db);
});

/// Family provider to fetch tracks for a single playlist
final playlistSongsProvider =
    FutureProvider.family<List<Song>, int>((ref, playlistId) async {
  final db = ref.watch(databaseProvider);
  return await db.getSongsForPlaylist(playlistId);
});
