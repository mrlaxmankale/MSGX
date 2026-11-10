import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:msgx/features/player/services/audio_player_service.dart';
import 'package:msgx/models/song.dart';

void main() {
  group('Queue and Playback Logic Tests', () {
    const s1 = Song(
      id: 1,
      mediaId: 'm1',
      title: 'Song 1',
      artist: 'Artist',
      album: 'Album',
      filePathOrUri: '/path1.mp3',
      duration: 100,
      fileSize: 1000,
      format: 'mp3',
      dateAdded: 1,
      lastModified: 1,
    );

    const s2 = Song(
      id: 2,
      mediaId: 'm2',
      title: 'Song 2',
      artist: 'Artist',
      album: 'Album',
      filePathOrUri: '/path2.mp3',
      duration: 100,
      fileSize: 1000,
      format: 'mp3',
      dateAdded: 2,
      lastModified: 2,
    );

    const s3 = Song(
      id: 3,
      mediaId: 'm3',
      title: 'Song 3',
      artist: 'Artist',
      album: 'Album',
      filePathOrUri: '/path3.mp3',
      duration: 100,
      fileSize: 1000,
      format: 'mp3',
      dateAdded: 3,
      lastModified: 3,
    );

    test('Shuffle logic retains currently playing song at index 0', () {
      final list = [s1, s2, s3];
      const current = s2;

      final shuffled = List<Song>.from(list);
      shuffled.removeWhere((s) => s.id == current.id);
      shuffled.shuffle(Random(42));
      shuffled.insert(0, current);

      expect(shuffled.first, equals(current));
      expect(shuffled.length, 3);
      expect(shuffled.contains(s1), isTrue);
      expect(shuffled.contains(s2), isTrue);
      expect(shuffled.contains(s3), isTrue);
    });

    test('RepeatMode cycles off -> all -> one -> off', () {
      MSGXRepeatMode mode = MSGXRepeatMode.off;

      // Cycle 1
      mode = (mode == MSGXRepeatMode.off)
          ? MSGXRepeatMode.all
          : (mode == MSGXRepeatMode.all
              ? MSGXRepeatMode.one
              : MSGXRepeatMode.off);
      expect(mode, MSGXRepeatMode.all);

      // Cycle 2
      mode = (mode == MSGXRepeatMode.off)
          ? MSGXRepeatMode.all
          : (mode == MSGXRepeatMode.all
              ? MSGXRepeatMode.one
              : MSGXRepeatMode.off);
      expect(mode, MSGXRepeatMode.one);

      // Cycle 3
      mode = (mode == MSGXRepeatMode.off)
          ? MSGXRepeatMode.all
          : (mode == MSGXRepeatMode.all
              ? MSGXRepeatMode.one
              : MSGXRepeatMode.off);
      expect(mode, MSGXRepeatMode.off);
    });
  });
}
