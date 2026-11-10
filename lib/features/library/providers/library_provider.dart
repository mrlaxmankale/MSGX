import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../models/song.dart';
import '../../../models/album.dart';
import '../../../models/artist.dart';
import '../../../models/music_folder.dart';

enum SongSortOption {
  titleAsc,
  titleDesc,
  artistAsc,
  albumAsc,
  dateAddedDesc,
  durationDesc,
}

final songSortProvider =
    StateProvider<SongSortOption>((ref) => SongSortOption.titleAsc);

/// Database instance provider
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Provider for all songs from SQLite with sorting
final allSongsProvider = FutureProvider<List<Song>>((ref) async {
  final db = ref.watch(databaseProvider);
  final sortOption = ref.watch(songSortProvider);

  String orderBy;
  switch (sortOption) {
    case SongSortOption.titleAsc:
      orderBy = 's.title COLLATE NOCASE ASC';
      break;
    case SongSortOption.titleDesc:
      orderBy = 's.title COLLATE NOCASE DESC';
      break;
    case SongSortOption.artistAsc:
      orderBy = 's.artist COLLATE NOCASE ASC, s.title COLLATE NOCASE ASC';
      break;
    case SongSortOption.albumAsc:
      orderBy = 's.album COLLATE NOCASE ASC, s.title COLLATE NOCASE ASC';
      break;
    case SongSortOption.dateAddedDesc:
      orderBy = 's.date_added DESC';
      break;
    case SongSortOption.durationDesc:
      orderBy = 's.duration DESC';
      break;
  }

  return await db.getAllSongs(orderBy: orderBy);
});

/// Provider for all albums
final allAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getAllAlbums();
});

/// Provider for all artists
final allArtistsProvider = FutureProvider<List<Artist>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getAllArtists();
});

/// Provider for all music folders
final allFoldersProvider = FutureProvider<List<MusicFolder>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getMusicFolders();
});

/// Provider for recently added songs
final recentlyAddedProvider = FutureProvider<List<Song>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getRecentlyAddedSongs(limit: 20);
});

/// Provider for recently played songs
final recentlyPlayedProvider = FutureProvider<List<Song>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getRecentlyPlayedSongs(limit: 20);
});
