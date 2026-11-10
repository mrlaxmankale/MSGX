import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/utils/error_handler.dart';

/// Background audio handler integrating just_audio playback with system media notifications
/// and lock-screen controls on Android and iOS.
class MSGXAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  MSGXAudioHandler(this._player) {
    _initStreams();
  }

  void _initStreams() {
    // Listen to player state changes and update AudioService playback state
    _player.playbackEventStream.listen(
      (PlaybackEvent event) {
        final playing = _player.playing;
        playbackState.add(
          playbackState.value.copyWith(
            controls: [
              MediaControl.skipToPrevious,
              if (playing) MediaControl.pause else MediaControl.play,
              MediaControl.stop,
              MediaControl.skipToNext,
            ],
            systemActions: const {
              MediaAction.seek,
              MediaAction.seekForward,
              MediaAction.seekBackward,
            },
            androidCompactActionIndices: const [0, 1, 3],
            processingState: const {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[_player.processingState]!,
            playing: playing,
            updatePosition: _player.position,
            bufferedPosition: _player.bufferedPosition,
            speed: _player.speed,
            queueIndex: event.currentIndex,
          ),
        );
      },
      onError: (Object e, StackTrace stack) {
        ErrorHandler.logError('MSGXAudioHandler.playbackEventStream', e, stack);
      },
    );
  }

  /// Update the current active media item shown on lock-screen and notifications
  void setMediaItem({
    required String id,
    required String title,
    required String artist,
    required String album,
    required Duration duration,
    String? artworkUri,
  }) {
    mediaItem.add(
      MediaItem(
        id: id,
        title: title,
        artist: artist,
        album: album,
        duration: duration,
        artUri: artworkUri != null && artworkUri.isNotEmpty
            ? Uri.tryParse(artworkUri)
            : null,
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> skipToNext() async {
    // Delegates to the AudioPlayerService skip next
    if (customActionCallbacks.containsKey('skipToNext')) {
      await customActionCallbacks['skipToNext']!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // Delegates to the AudioPlayerService skip previous
    if (customActionCallbacks.containsKey('skipToPrevious')) {
      await customActionCallbacks['skipToPrevious']!();
    }
  }

  final Map<String, Future<dynamic> Function()> customActionCallbacks = {};
}
