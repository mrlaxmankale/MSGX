import 'package:flutter_test/flutter_test.dart';
import 'package:msgx/models/song.dart';

void main() {
  group('Song Model Unit Tests', () {
    test('Song serialization toMap and fromMap works correctly', () {
      const song = Song(
        id: 1,
        mediaId: 'song_123',
        title: 'Starboy',
        artist: 'The Weeknd',
        album: 'Starboy Album',
        albumId: 42,
        artistId: 10,
        filePathOrUri: '/storage/emulated/0/Music/starboy.mp3',
        duration: 230000,
        fileSize: 5500000,
        format: 'mp3',
        artworkReference: 'art_123',
        dateAdded: 1680000000,
        lastModified: 1680000500,
        trackNumber: 1,
        year: 2016,
        genre: 'R&B',
      );

      final map = song.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Starboy');
      expect(map['artist'], 'The Weeknd');
      expect(map['duration'], 230000);

      final fromMapSong = Song.fromMap(map, isFav: true);
      expect(fromMapSong.id, 1);
      expect(fromMapSong.mediaId, 'song_123');
      expect(fromMapSong.title, 'Starboy');
      expect(fromMapSong.artist, 'The Weeknd');
      expect(fromMapSong.isFavorite, true);
    });

    test('Song copyWith produces updated immutable copy', () {
      const song = Song(
        id: 1,
        mediaId: 'm1',
        title: 'Old Title',
        artist: 'Artist',
        album: 'Album',
        filePathOrUri: '/music/song.mp3',
        duration: 100000,
        fileSize: 2000000,
        format: 'mp3',
        dateAdded: 1000,
        lastModified: 2000,
      );

      final updated = song.copyWith(title: 'New Title', isFavorite: true);
      expect(updated.title, 'New Title');
      expect(updated.isFavorite, true);
      expect(updated.mediaId, 'm1');
      expect(updated.artist, 'Artist');
    });

    test('Song equality is determined by mediaId and filePath', () {
      const s1 = Song(
        id: 1,
        mediaId: 'm1',
        title: 'Song',
        artist: 'Artist',
        album: 'Album',
        filePathOrUri: '/path/song.mp3',
        duration: 100,
        fileSize: 200,
        format: 'mp3',
        dateAdded: 1,
        lastModified: 2,
      );

      const s2 = Song(
        id: 2,
        mediaId: 'm1',
        title: 'Different Title',
        artist: 'Different Artist',
        album: 'Different Album',
        filePathOrUri: '/path/song.mp3',
        duration: 500,
        fileSize: 600,
        format: 'mp3',
        dateAdded: 3,
        lastModified: 4,
      );

      expect(s1, equals(s2));
    });
  });
}
