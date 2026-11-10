import 'dart:io';
import '../../../models/song.dart';
import '../../../core/utils/error_handler.dart';

class LyricLine {
  final Duration timestamp;
  final String text;

  const LyricLine({required this.timestamp, required this.text});
}

class LyricsData {
  final bool isSynced;
  final List<LyricLine> lines;
  final String rawText;

  const LyricsData({
    required this.isSynced,
    required this.lines,
    required this.rawText,
  });

  bool get isEmpty => lines.isEmpty && rawText.isEmpty;
}

/// Offline lyrics parser for LRC synchronized files and static lyrics text.
class LyricsService {
  /// Attempt to find and parse a local .lrc file in the same directory as the song
  static Future<LyricsData?> loadLyricsForSong(Song song) async {
    try {
      if (song.filePathOrUri.isEmpty) return null;

      final songFile = File(song.filePathOrUri);
      final directory = songFile.parent;
      final fileNameWithoutExt =
          songFile.uri.pathSegments.last.split('.').first;

      // Check standard .lrc file names
      final candidates = [
        File(
            '${directory.path}${Platform.pathSeparator}$fileNameWithoutExt.lrc'),
        File('${directory.path}${Platform.pathSeparator}${song.title}.lrc'),
      ];

      for (final candidate in candidates) {
        if (await candidate.exists()) {
          final content = await candidate.readAsString();
          return parseLrc(content);
        }
      }
    } catch (e, stack) {
      ErrorHandler.logError('LyricsService.loadLyricsForSong', e, stack);
    }
    return null;
  }

  /// Parses LRC formatted text with timestamps like [01:23.45]
  static LyricsData parseLrc(String lrcText) {
    final lines = lrcText.split(RegExp(r'\r?\n'));
    final List<LyricLine> parsedLines = [];
    final timestampRegex = RegExp(r'\[(\d{2}):(\d{2})\.?(\d{2,3})?\]');

    for (final line in lines) {
      final match = timestampRegex.firstMatch(line);
      if (match != null) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
        final millis = int.tryParse(match.group(3) ?? '0') ?? 0;

        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: millis * (match.group(3)?.length == 2 ? 10 : 1),
        );

        final text = line.replaceAll(timestampRegex, '').trim();
        if (text.isNotEmpty) {
          parsedLines.add(LyricLine(timestamp: duration, text: text));
        }
      }
    }

    parsedLines.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return LyricsData(
      isSynced: parsedLines.isNotEmpty,
      lines: parsedLines,
      rawText: lrcText,
    );
  }
}
