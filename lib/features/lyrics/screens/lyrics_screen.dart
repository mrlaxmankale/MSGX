import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/song.dart';
import '../../player/providers/player_provider.dart';
import '../services/lyrics_service.dart';

/// Screen presenting real-time synchronized offline lyrics.
class LyricsScreen extends ConsumerStatefulWidget {
  final Song song;

  const LyricsScreen({super.key, required this.song});

  @override
  ConsumerState<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends ConsumerState<LyricsScreen> {
  LyricsData? _lyricsData;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  Future<void> _loadLyrics() async {
    final data = await LyricsService.loadLyricsForSong(widget.song);
    if (mounted) {
      setState(() {
        _lyricsData = data;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(playerPositionStreamProvider);
    final currentPosition = positionAsync.value ?? Duration.zero;

    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.song.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.song.artist,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.darkTextSecondary),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : (_lyricsData == null || _lyricsData!.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lyrics_outlined,
                          size: 64,
                          color: AppColors.darkTextSecondary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Lyrics Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Place a .lrc file named "${widget.song.title}.lrc" in the song\'s folder for synchronized offline lyrics.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkTextSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _lyricsData!.isSynced
                  ? ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 40),
                      itemCount: _lyricsData!.lines.length,
                      itemBuilder: (context, index) {
                        final line = _lyricsData!.lines[index];
                        final nextTimestamp =
                            (index < _lyricsData!.lines.length - 1)
                                ? _lyricsData!.lines[index + 1].timestamp
                                : const Duration(hours: 1);

                        final isActive = currentPosition >= line.timestamp &&
                            currentPosition < nextTimestamp;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(audioPlayerServiceProvider)
                                  .seek(line.timestamp);
                            },
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: isActive ? 24 : 19,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.darkTextMuted,
                                height: 1.3,
                              ),
                              child: Text(line.text),
                            ),
                          ),
                        );
                      },
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: Text(
                        _lyricsData!.rawText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                    ),
    );
  }
}
