import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/song.dart';
import '../services/audio_player_service.dart';

/// Provider for the AudioPlayerService singleton
final audioPlayerServiceProvider =
    ChangeNotifierProvider<AudioPlayerService>((ref) {
  return AudioPlayerService();
});

/// Current active song provider
final currentSongProvider = Provider<Song?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.currentSong;
});

/// Playing state provider
final isPlayingProvider = Provider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.isPlaying;
});

/// Queue provider
final playerQueueProvider = Provider<List<Song>>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.queue;
});

/// Shuffle state provider
final isShuffleProvider = Provider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.isShuffleEnabled;
});

/// Repeat mode provider
final repeatModeProvider = Provider<MSGXRepeatMode>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.repeatMode;
});

/// Player error message provider
final playerErrorProvider = Provider<String?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.errorMessage;
});

/// Current playback position stream
final playerPositionStreamProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.positionStream;
});

/// Current track duration stream
final playerDurationStreamProvider = StreamProvider<Duration?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.durationStream;
});

/// Sleep timer remaining duration provider
final sleepTimerRemainingProvider = Provider<Duration?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.remainingSleepTime;
});
