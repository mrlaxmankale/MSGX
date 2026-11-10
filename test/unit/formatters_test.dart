import 'package:flutter_test/flutter_test.dart';
import 'package:msgx/core/utils/formatters.dart';

void main() {
  group('Formatters Unit Tests', () {
    test('formatDurationMs formats minutes and seconds properly', () {
      expect(Formatters.formatDurationMs(0), '0:00');
      expect(Formatters.formatDurationMs(45000), '0:45');
      expect(Formatters.formatDurationMs(65000), '1:05');
      expect(Formatters.formatDurationMs(215000), '3:35');
    });

    test('formatDurationMs formats hours correctly', () {
      expect(Formatters.formatDurationMs(3665000), '1:01:05');
      expect(Formatters.formatDurationMs(7325000), '2:02:05');
    });

    test('formatFileSize formats bytes, KB, MB, and GB properly', () {
      expect(Formatters.formatFileSize(0), '0 B');
      expect(Formatters.formatFileSize(512), '512.0 B');
      expect(Formatters.formatFileSize(1024), '1.0 KB');
      expect(Formatters.formatFileSize(5242880), '5.0 MB');
    });

    test('getGreeting returns valid context greeting', () {
      final greeting = Formatters.getGreeting();
      expect(
        greeting == 'Good morning' ||
            greeting == 'Good afternoon' ||
            greeting == 'Good evening',
        isTrue,
      );
    });
  });
}
