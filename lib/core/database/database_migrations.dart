import 'package:sqflite/sqflite.dart';

/// Database schema definitions, tables, and migration logic for MSGX SQLite database.
class DatabaseMigrations {
  /// Execute initial schema creation (Version 1)
  static Future<void> onCreate(Database db, int version) async {
    final batch = db.batch();

    // 1. Songs Table
    batch.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        media_id TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT NOT NULL,
        album_id INTEGER,
        artist_id INTEGER,
        file_path_or_uri TEXT NOT NULL UNIQUE,
        duration INTEGER NOT NULL,
        file_size INTEGER NOT NULL,
        format TEXT NOT NULL,
        artwork_reference TEXT,
        date_added INTEGER NOT NULL,
        last_modified INTEGER NOT NULL,
        track_number INTEGER,
        year INTEGER,
        genre TEXT
      )
    ''');

    // Indexes for fast querying, sorting, and deduplication
    batch.execute('CREATE INDEX idx_songs_media_id ON songs(media_id)');
    batch
        .execute('CREATE INDEX idx_songs_title ON songs(title COLLATE NOCASE)');
    batch.execute(
        'CREATE INDEX idx_songs_artist ON songs(artist COLLATE NOCASE)');
    batch
        .execute('CREATE INDEX idx_songs_album ON songs(album COLLATE NOCASE)');
    batch
        .execute('CREATE INDEX idx_songs_date_added ON songs(date_added DESC)');
    batch.execute('CREATE INDEX idx_songs_duration ON songs(duration)');

    // 2. Albums Table
    batch.execute('''
      CREATE TABLE albums (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        artist TEXT NOT NULL,
        artwork_reference TEXT,
        song_count INTEGER NOT NULL DEFAULT 0,
        total_duration INTEGER NOT NULL DEFAULT 0,
        UNIQUE(name, artist)
      )
    ''');
    batch
        .execute('CREATE INDEX idx_albums_name ON albums(name COLLATE NOCASE)');

    // 3. Artists Table
    batch.execute('''
      CREATE TABLE artists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        song_count INTEGER NOT NULL DEFAULT 0,
        album_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
    batch.execute(
        'CREATE INDEX idx_artists_name ON artists(name COLLATE NOCASE)');

    // 4. Playlists Table
    batch.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        artwork_reference TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    batch.execute(
        'CREATE INDEX idx_playlists_name ON playlists(name COLLATE NOCASE)');

    // 5. Playlist Songs Table (Many-to-Many mapping with order position)
    batch.execute('''
      CREATE TABLE playlist_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER NOT NULL,
        song_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        added_at INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE,
        FOREIGN KEY (song_id) REFERENCES songs (id) ON DELETE CASCADE,
        UNIQUE(playlist_id, song_id)
      )
    ''');
    batch.execute(
        'CREATE INDEX idx_playlist_songs_playlist ON playlist_songs(playlist_id, position ASC)');

    // 6. Favorites Table
    batch.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL UNIQUE,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (song_id) REFERENCES songs (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('CREATE INDEX idx_favorites_song_id ON favorites(song_id)');
    batch.execute(
        'CREATE INDEX idx_favorites_created_at ON favorites(created_at DESC)');

    // 7. Play History Table
    batch.execute('''
      CREATE TABLE play_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        played_at INTEGER NOT NULL,
        playback_position INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (song_id) REFERENCES songs (id) ON DELETE CASCADE
      )
    ''');
    batch
        .execute('CREATE INDEX idx_play_history_song ON play_history(song_id)');
    batch.execute(
        'CREATE INDEX idx_play_history_played_at ON play_history(played_at DESC)');

    // 8. Settings Table (Key-Value persistence)
    batch.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await batch.commit(noResult: true);
  }

  /// Handles schema migrations for future updates
  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Migration steps will be placed here as schema increments
  }
}
