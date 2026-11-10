import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../models/song.dart';
import '../../library/providers/library_provider.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<List<Song>>> {
  final AppDatabase _db;
  final Ref _ref;

  FavoritesNotifier(this._db, this._ref) : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final songs = await _db.getFavoriteSongs();
      state = AsyncValue.data(songs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> toggleFavorite(Song song) async {
    if (song.id == null) return false;
    final isFav = await _db.toggleFavorite(song.id!);
    await loadFavorites();
    _ref.invalidate(allSongsProvider);
    return isFav;
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Song>>>((ref) {
  final db = ref.watch(databaseProvider);
  return FavoritesNotifier(db, ref);
});
