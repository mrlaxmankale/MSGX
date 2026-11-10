import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import '../../models/song.dart';
import '../../models/album.dart';
import '../../models/artist.dart';
import '../../models/playlist.dart';
import '../../models/music_folder.dart';
import 'database_migrations.dart';

/// SQLite Database manager and DAO for MSGX.
class AppDatabase {
  static AppDatabase? _instance;
  static Database? _database;

  AppDatabase._internal();

  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  /// Exposed database getter with lazy initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialise the SQLite database file
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, AppConstants.databaseName);

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onConfigure: (db) async {
          // Enable foreign keys for referential integrity
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: DatabaseMigrations.onCreate,
        onUpgrade: DatabaseMigrations.onUpgrade,
      );
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase._initDatabase', e, stack);
      rethrow;
    }
  }

  // ==========================================
  // SONGS DAO
  // ==========================================

  /// Inserts or updates a list of scanned songs atomically inside a transaction
  Future<void> upsertSongsBatch(List<Song> songs) async {
    if (songs.isEmpty) return;
    final db = await database;

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final song in songs) {
        batch.insert(
          'songs',
          song.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });

    // Automatically recalculate albums and artists summaries
    await syncAlbumsAndArtists();
  }

  /// Retrieves all songs ordered by a specific field
  Future<List<Song>> getAllSongs(
      {String orderBy = 'title COLLATE NOCASE ASC'}) async {
    final db = await database;
    try {
      // Left join with favorites to populate isFavorite flag
      final result = await db.rawQuery('''
        SELECT s.*, (CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END) AS is_favorite
        FROM songs s
        LEFT JOIN favorites f ON s.id = f.song_id
        ORDER BY $orderBy
      ''');

      return result.map((row) => Song.fromMap(row)).toList();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getAllSongs', e, stack);
      return [];
    }
  }

  /// Retrieve a song by its SQLite ID
  Future<Song?> getSongById(int id) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT s.*, (CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END) AS is_favorite
        FROM songs s
        LEFT JOIN favorites f ON s.id = f.song_id
        WHERE s.id = ?
        LIMIT 1
      ''', [id]);

      if (result.isEmpty) return null;
      return Song.fromMap(result.first);
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getSongById', e, stack);
      return null;
    }
  }

  /// Retrieve a song by its mediaId
  Future<Song?> getSongByMediaId(String mediaId) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT s.*, (CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END) AS is_favorite
        FROM songs s
        LEFT JOIN favorites f ON s.id = f.song_id
        WHERE s.media_id = ?
        LIMIT 1
      ''', [mediaId]);

      if (result.isEmpty) return null;
      return Song.fromMap(result.first);
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getSongByMediaId', e, stack);
      return null;
    }
  }

  /// Delete songs that no longer exist on disk
  Future<void> removeMissingSongs(List<String> validMediaIds) async {
    if (validMediaIds.isEmpty) return;
    final db = await database;
    try {
      final placeholders = List.filled(validMediaIds.length, '?').join(',');
      await db.delete(
        'songs',
        where: 'media_id NOT IN ($placeholders)',
        whereArgs: validMediaIds,
      );
      await syncAlbumsAndArtists();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.removeMissingSongs', e, stack);
    }
  }

  // ==========================================
  // ALBUMS & ARTISTS DAO
  // ==========================================

  /// Regenerates albums and artists summaries from current songs table
  Future<void> syncAlbumsAndArtists() async {
    final db = await database;
    await db.transaction((txn) async {
      // Rebuild albums
      await txn.delete('albums');
      await txn.execute('''
        INSERT INTO albums (name, artist, artwork_reference, song_count, total_duration)
        SELECT 
          album, 
          artist, 
          MAX(artwork_reference) as artwork_reference, 
          COUNT(id) as song_count, 
          SUM(duration) as total_duration
        FROM songs
        GROUP BY album, artist
      ''');

      // Rebuild artists
      await txn.delete('artists');
      await txn.execute('''
        INSERT INTO artists (name, song_count, album_count)
        SELECT 
          artist, 
          COUNT(DISTINCT id) as song_count, 
          COUNT(DISTINCT album) as album_count
        FROM songs
        GROUP BY artist
      ''');
    });
  }

  /// Retrieve all albums
  Future<List<Album>> getAllAlbums() async {
    final db = await database;
    try {
      final result =
          await db.query('albums', orderBy: 'name COLLATE NOCASE ASC');
      return result.map((row) => Album.fromMap(row)).toList();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getAllAlbums', e, stack);
      return [];
    }
  }

  /// Retrieve all songs in an album
  Future<List<Song>> getSongsForAlbum(
      String albumName, String artistName) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT s.*, (CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END) AS is_favorite
        FROM songs s
        LEFT JOIN favorites f ON s.id = f.song_id
        WHERE s.album = ? AND s.artist = ?
        ORDER BY s.track_number ASC, s.title COLLATE NOCASE ASC
      ''', [albumName, artistName]);
      return result.map((row) => Song.fromMap(row)).toList();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getSongsForAlbum', e, stack);
      return [];
    }
  }

  /// Retrieve all artists
  Future<List<Artist>> getAllArtists() async {
    final db = await database;
    try {
      final result =
          await db.query('artists', orderBy: 'name COLLATE NOCASE ASC');
      return result.map((row) => Artist.fromMap(row)).toList();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getAllArtists', e, stack);
      return [];
    }
  }

  /// Retrieve all songs by an artist
  Future<List<Song>> getSongsForArtist(String artistName) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT s.*, (CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END) AS is_favorite
        FROM songs s
        LEFT JOIN favorites f ON s.id = f.song_id
        WHERE s.artist = ?
        ORDER BY s.album COLLATE NOCASE ASC, s.title COLLATE NOCASE ASC
      ''', [artistName]);
      return result.map((row) => Song.fromMap(row)).toList();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getSongsForArtist', e, stack);
      return [];
    }
  }

  // ==========================================
  // PLAYLISTS DAO
  // ==========================================

  /// Retrieve all playlists
  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT p.*, COUNT(ps.id) AS song_count
        FROM playlists p
        LEFT JOIN playlist_songs ps ON p.id = ps.playlist_id
        GROUP BY p.id
        ORDER BY p.updated_at DESC
      ''');
      return result.map((row) => Playlist.fromMap(row)).toList();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getAllPlaylists', e, stack);
      return [];
    }
  }

  /// Create a new playlist
  Future<int> createPlaylist(String name, {String? description}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.insert(
      'playlists',
      {
        'name': name.trim(),
        'description': description,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Rename a playlist
  Future<int> renamePlaylist(int playlistId, String newName) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      'playlists',
      {'name': newName.trim(), 'updated_at': now},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  /// Delete a playlist
  Future<int> deletePlaylist(int playlistId) async {
    final db = await database;
    return await db
        .delete('playlists', where: 'id = ?', whereArgs: [playlistId]);
  }

  /// Add a song to a playlist
  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Get current max position
    final posResult = await db.rawQuery(
      'SELECT MAX(position) as max_pos FROM playlist_songs WHERE playlist_id = ?',
      [playlistId],
    );
    final maxPos = (posResult.first['max_pos'] as int?) ?? 0;

    await db.insert(
      'playlist_songs',
      {
        'playlist_id': playlistId,
        'song_id': songId,
        'position': maxPos + 1,
        'added_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Update playlist updated_at timestamp
    await db.update(
      'playlists',
      {'updated_at': now},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  /// Remove a song from a playlist
  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    final db = await database;
    await db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }

  /// Reorder songs in a playlist
  Future<void> reorderPlaylistSongs(
      int playlistId, List<int> orderedSongIds) async {
    final db = await database;
    await db.transaction((txn) async {
      for (int i = 0; i < orderedSongIds.length; i++) {
        await txn.update(
          'playlist_songs',
          {'position': i},
          where: 'playlist_id = ? AND song_id = ?',
          whereArgs: [playlistId, orderedSongIds[i]],
        );
      }
    });
  }

  /// Retrieve all songs in a playlist
  Future<List<Song>> getSongsForPlaylist(int playlistId) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT s.*, (CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END) AS is_favorite
        FROM playlist_songs ps
        JOIN songs s ON ps.song_id = s.id
        LEFT JOIN favorites f ON s.id = f.song_id
        WHERE ps.playlist_id = ?
        ORDER BY ps.position ASC
      ''', [playlistId]);
      return result.map((row) => Song.fromMap(row)).toList();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getSongsForPlaylist', e, stack);
      return [];
    }
  }

  // ==========================================
  // FAVORITES DAO
  // ==========================================

  /// Toggle favorite status of a song
  Future<bool> toggleFavorite(int songId) async {
    final db = await database;
    final exists = await db.query(
      'favorites',
      where: 'song_id = ?',
      whereArgs: [songId],
      limit: 1,
    );

    if (exists.isNotEmpty) {
      await db.delete('favorites', where: 'song_id = ?', whereArgs: [songId]);
      return false;
    } else {
      await db.insert('favorites', {
        'song_id': songId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    }
  }

  /// Check if a song is favorited
  Future<bool> isFavorite(int songId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'song_id = ?',
      whereArgs: [songId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Retrieve all favorite songs
  Future<List<Song>> getFavoriteSongs() async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT s.*, 1 AS is_favorite
        FROM favorites f
        JOIN songs s ON f.song_id = s.id
        ORDER BY f.created_at DESC
      ''');
      return result.map((row) => Song.fromMap(row, isFav: true)).toList();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getFavoriteSongs', e, stack);
      return [];
    }
  }

  // ==========================================
  // PLAY HISTORY DAO
  // ==========================================

  /// Record a song play event
  Future<void> recordPlayHistory(int songId, {int positionMs = 0}) async {
    final db = await database;
    try {
      await db.insert('play_history', {
        'song_id': songId,
        'played_at': DateTime.now().millisecondsSinceEpoch,
        'playback_position': positionMs,
      });

      // Keep history bounded to most recent 500 plays
      await db.execute('''
        DELETE FROM play_history 
        WHERE id NOT IN (
          SELECT id FROM play_history ORDER BY played_at DESC LIMIT 500
        )
      ''');
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.recordPlayHistory', e, stack);
    }
  }

  /// Retrieve recently played distinct songs
  Future<List<Song>> getRecentlyPlayedSongs({int limit = 30}) async {
    final db = await database;
    try {
      final result = await db.rawQuery('''
        SELECT s.*, (CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END) AS is_favorite,
               MAX(ph.played_at) as last_played
        FROM play_history ph
        JOIN songs s ON ph.song_id = s.id
        LEFT JOIN favorites f ON s.id = f.song_id
        GROUP BY s.id
        ORDER BY last_played DESC
        LIMIT ?
      ''', [limit]);
      return result.map((row) => Song.fromMap(row)).toList();
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.getRecentlyPlayedSongs', e, stack);
      return [];
    }
  }

  /// Clear all playback history
  Future<void> clearPlayHistory() async {
    final db = await database;
    await db.delete('play_history');
  }

  // ==========================================
  // FOLDERS & RECENTLY ADDED DAO
  // ==========================================

  /// Retrieve songs grouped by folder
  Future<List<MusicFolder>> getMusicFolders() async {
    final songs = await getAllSongs();
    final Map<String, List<Song>> folderMap = {};

    for (final song in songs) {
      final path = song.filePathOrUri;
      final folderPath = p.dirname(path);
      folderMap.putIfAbsent(folderPath, () => []).add(song);
    }

    return folderMap.entries.map((entry) {
      final folderName = p.basename(entry.key);
      return MusicFolder(
        path: entry.key,
        name: folderName.isEmpty ? 'Root' : folderName,
        songCount: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Retrieve songs belonging to a specific directory path
  Future<List<Song>> getSongsInFolder(String folderPath) async {
    final songs = await getAllSongs();
    return songs
        .where((s) => p.dirname(s.filePathOrUri) == folderPath)
        .toList();
  }

  /// Retrieve recently added songs
  Future<List<Song>> getRecentlyAddedSongs({int limit = 30}) async {
    return await getAllSongs(orderBy: 'date_added DESC LIMIT $limit');
  }

  // ==========================================
  // SEARCH DAO
  // ==========================================

  /// Search across songs, artists, and albums offline
  Future<Map<String, dynamic>> searchAll(String query) async {
    if (query.trim().isEmpty) {
      return {'songs': <Song>[], 'albums': <Album>[], 'artists': <Artist>[]};
    }
    final db = await database;
    final term = '%${query.trim()}%';

    try {
      final songRows = await db.rawQuery('''
        SELECT s.*, (CASE WHEN f.id IS NOT NULL THEN 1 ELSE 0 END) AS is_favorite
        FROM songs s
        LEFT JOIN favorites f ON s.id = f.song_id
        WHERE s.title LIKE ? OR s.artist LIKE ? OR s.album LIKE ?
        ORDER BY s.title COLLATE NOCASE ASC
        LIMIT 50
      ''', [term, term, term]);

      final albumRows = await db.rawQuery('''
        SELECT * FROM albums
        WHERE name LIKE ? OR artist LIKE ?
        ORDER BY name COLLATE NOCASE ASC
        LIMIT 20
      ''', [term, term]);

      final artistRows = await db.rawQuery('''
        SELECT * FROM artists
        WHERE name LIKE ?
        ORDER BY name COLLATE NOCASE ASC
        LIMIT 20
      ''', [term]);

      return {
        'songs': songRows.map((r) => Song.fromMap(r)).toList(),
        'albums': albumRows.map((r) => Album.fromMap(r)).toList(),
        'artists': artistRows.map((r) => Artist.fromMap(r)).toList(),
      };
    } catch (e, stack) {
      ErrorHandler.logError('AppDatabase.searchAll', e, stack);
      return {'songs': <Song>[], 'albums': <Album>[], 'artists': <Artist>[]};
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
