import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:msgx/core/database/database_migrations.dart';
import 'package:msgx/models/song.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Operations In-Memory Tests', () {
    late Database db;

    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: DatabaseMigrations.onCreate,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Insert and query songs with favorites', () async {
      const song = Song(
        mediaId: 'song_test_1',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        filePathOrUri: '/storage/music/blinding_lights.mp3',
        duration: 200000,
        fileSize: 4500000,
        format: 'mp3',
        dateAdded: 1600000000,
        lastModified: 1600000000,
      );

      final songId = await db.insert('songs', song.toMap());
      expect(songId, greaterThan(0));

      final rows = await db.query('songs');
      expect(rows.length, 1);
      expect(rows.first['title'], 'Blinding Lights');

      // Test favorite insertion
      await db.insert('favorites', {
        'song_id': songId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      final favs = await db.query('favorites');
      expect(favs.length, 1);
      expect(favs.first['song_id'], songId);
    });

    test('Playlist CRUD and many-to-many relationship', () async {
      // 1. Create playlist
      final playlistId = await db.insert('playlists', {
        'name': 'Gym Motivation',
        'description': 'High energy tracks',
        'created_at': 1000,
        'updated_at': 1000,
      });
      expect(playlistId, greaterThan(0));

      // 2. Insert test songs
      final s1Id = await db.insert('songs', {
        'media_id': 's1',
        'title': 'Track 1',
        'artist': 'Artist 1',
        'album': 'Album 1',
        'file_path_or_uri': '/path1.mp3',
        'duration': 180000,
        'file_size': 3000000,
        'format': 'mp3',
        'date_added': 100,
        'last_modified': 100,
      });

      final s2Id = await db.insert('songs', {
        'media_id': 's2',
        'title': 'Track 2',
        'artist': 'Artist 2',
        'album': 'Album 2',
        'file_path_or_uri': '/path2.mp3',
        'duration': 210000,
        'file_size': 3500000,
        'format': 'mp3',
        'date_added': 200,
        'last_modified': 200,
      });

      // 3. Add songs to playlist
      await db.insert('playlist_songs', {
        'playlist_id': playlistId,
        'song_id': s1Id,
        'position': 0,
        'added_at': 1000,
      });

      await db.insert('playlist_songs', {
        'playlist_id': playlistId,
        'song_id': s2Id,
        'position': 1,
        'added_at': 1001,
      });

      // Query playlist songs
      final pSongs = await db.rawQuery('''
        SELECT s.* FROM playlist_songs ps
        JOIN songs s ON ps.song_id = s.id
        WHERE ps.playlist_id = ?
        ORDER BY ps.position ASC
      ''', [playlistId]);

      expect(pSongs.length, 2);
      expect(pSongs[0]['title'], 'Track 1');
      expect(pSongs[1]['title'], 'Track 2');

      // 4. Delete playlist cascades
      await db.delete('playlists', where: 'id = ?', whereArgs: [playlistId]);
      final remainingLinks = await db.query('playlist_songs',
          where: 'playlist_id = ?', whereArgs: [playlistId]);
      expect(remainingLinks.isEmpty, isTrue);
    });

    test('Play history recording and limit', () async {
      final sId = await db.insert('songs', {
        'media_id': 's_hist',
        'title': 'History Song',
        'artist': 'Artist',
        'album': 'Album',
        'file_path_or_uri': '/hist.mp3',
        'duration': 120000,
        'file_size': 2000000,
        'format': 'mp3',
        'date_added': 10,
        'last_modified': 10,
      });

      await db.insert('play_history', {
        'song_id': sId,
        'played_at': 1000,
        'playback_position': 50000,
      });

      final history = await db.query('play_history');
      expect(history.length, 1);
      expect(history.first['playback_position'], 50000);
    });
  });
}
