import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/song.dart';
import '../services/music_scanner.dart';

/// Scanner instance provider
final musicScannerProvider = Provider<MusicScanner>((ref) {
  return MusicScanner();
});

/// State notifier holding current scan progress
class ScannerNotifier extends StateNotifier<ScanProgressState> {
  final MusicScanner _scanner;

  ScannerNotifier(this._scanner) : super(const ScanProgressState());

  Future<List<Song>> startScan({int? minDurationMs}) async {
    state = const ScanProgressState(isScanning: true);
    final songs = await _scanner.scanDevice(
      minDurationMs: minDurationMs ?? 30000,
      onProgress: (progress) {
        state = progress;
      },
    );
    return songs;
  }

  void setProgress(ScanProgressState progress) {
    state = progress;
  }

  void cancel() {
    _scanner.cancelScan();
    state = state.copyWith(isScanning: false);
  }
}

final scannerStateProvider =
    StateNotifierProvider<ScannerNotifier, ScanProgressState>((ref) {
  final scanner = ref.watch(musicScannerProvider);
  return ScannerNotifier(scanner);
});
