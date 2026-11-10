import 'package:flutter_test/flutter_test.dart';
import 'package:msgx/features/lyrics/services/lyrics_service.dart';

void main() {
  group('LyricsParser Unit Tests', () {
    test('parseLrc correctly parses timestamps and text', () {
      const lrc = '''
[00:12.50]Line 1 of the song
[00:18.20]Line 2 of the song
[01:05.00]Chorus line here
''';

      final result = LyricsService.parseLrc(lrc);
      expect(result.isSynced, isTrue);
      expect(result.lines.length, 3);
      expect(result.lines[0].text, 'Line 1 of the song');
      expect(result.lines[0].timestamp,
          const Duration(seconds: 12, milliseconds: 500));
      expect(result.lines[1].text, 'Line 2 of the song');
      expect(result.lines[2].text, 'Chorus line here');
      expect(result.lines[2].timestamp, const Duration(minutes: 1, seconds: 5));
    });

    test('parseLrc handles unsynced static text fallback', () {
      const staticText = 'Just some static lyrics\nwithout any timestamps.';
      final result = LyricsService.parseLrc(staticText);
      expect(result.isSynced, isFalse);
      expect(result.lines.isEmpty, isTrue);
      expect(result.rawText, staticText);
    });
  });
}
