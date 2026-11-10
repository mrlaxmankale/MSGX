import 'package:flutter_test/flutter_test.dart';
import 'package:msgx/features/scanner/services/music_scanner.dart';
import 'package:msgx/core/constants/app_constants.dart';

void main() {
  group('MusicScanner Unit Tests', () {
    test('ScanProgressState maintains immutable copy and defaults', () {
      const initial = ScanProgressState();
      expect(initial.isScanning, isFalse);
      expect(initial.discovered, 0);
      expect(initial.valid, 0);
      expect(initial.skipped, 0);
      expect(initial.error, isNull);

      final running = initial.copyWith(
        isScanning: true,
        discovered: 50,
        valid: 45,
        skipped: 5,
      );

      expect(running.isScanning, isTrue);
      expect(running.discovered, 50);
      expect(running.valid, 45);
      expect(running.skipped, 5);

      final errorState = running.copyWith(
        isScanning: false,
        error: 'Permission denied',
        completed: true,
      );

      expect(errorState.isScanning, isFalse);
      expect(errorState.error, 'Permission denied');
      expect(errorState.completed, isTrue);
    });

    test('Scanner duration thresholds adhere to minimum constants', () {
      const defaultMin = AppConstants.defaultMinAudioDurationMs;
      expect(defaultMin, equals(30000)); // 30 seconds

      const testDuration1 = 15000; // 15 seconds ringtone
      const testDuration2 = 180000; // 3 minute song

      expect(testDuration1 < defaultMin, isTrue);
      expect(testDuration2 >= defaultMin, isTrue);
    });
  });
}
