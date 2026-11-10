import 'package:flutter_test/flutter_test.dart';
import 'package:msgx/core/utils/audio_utils.dart';

void main() {
  group('AudioUtils Unit Tests', () {
    test('isSupportedAudioFile validates standard audio formats', () {
      expect(AudioUtils.isSupportedAudioFile('song.mp3'), isTrue);
      expect(AudioUtils.isSupportedAudioFile('audio.m4a'), isTrue);
      expect(AudioUtils.isSupportedAudioFile('track.flac'), isTrue);
      expect(AudioUtils.isSupportedAudioFile('sound.wav'), isTrue);
      expect(AudioUtils.isSupportedAudioFile('clip.aac'), isTrue);
      expect(AudioUtils.isSupportedAudioFile('voice.ogg'), isTrue);
      expect(AudioUtils.isSupportedAudioFile('track.opus'), isTrue);

      expect(AudioUtils.isSupportedAudioFile('video.mp4'), isFalse);
      expect(AudioUtils.isSupportedAudioFile('image.jpg'), isFalse);
      expect(AudioUtils.isSupportedAudioFile('document.pdf'), isFalse);
      expect(AudioUtils.isSupportedAudioFile(''), isFalse);
    });

    test('sanitizeTrackTitle removes track number prefixes', () {
      expect(
          AudioUtils.sanitizeTrackTitle('01 - Song Title', null), 'Song Title');
      expect(AudioUtils.sanitizeTrackTitle('02. Another Track', null),
          'Another Track');
      expect(
          AudioUtils.sanitizeTrackTitle('12_Track Name', null), 'Track Name');
      expect(AudioUtils.sanitizeTrackTitle('', 'fallback.mp3'), 'fallback');
    });
  });
}
