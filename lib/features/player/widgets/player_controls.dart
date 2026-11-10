import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/player_provider.dart';
import '../services/audio_player_service.dart';

/// Primary playback control button row for Now Playing screen.
class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.watch(audioPlayerServiceProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final isShuffle = ref.watch(isShuffleProvider);
    final repeatMode = ref.watch(repeatModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            icon: Icon(
              Icons.shuffle_rounded,
              color: isShuffle
                  ? AppColors.primaryGreen
                  : AppColors.darkTextSecondary,
              size: 26,
            ),
            onPressed: () {
              playerService.toggleShuffle();
            },
          ),

          // Previous Track
          IconButton(
            icon: const Icon(
              Icons.skip_previous_rounded,
              color: Colors.white,
              size: 38,
            ),
            onPressed: () {
              playerService.previous();
            },
          ),

          // Play / Pause Prominent Button
          GestureDetector(
            onTap: () {
              playerService.togglePlayPause();
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 38,
                ),
              ),
            ),
          ),

          // Next Track
          IconButton(
            icon: const Icon(
              Icons.skip_next_rounded,
              color: Colors.white,
              size: 38,
            ),
            onPressed: () {
              playerService.next();
            },
          ),

          // Repeat Mode
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  repeatMode == MSGXRepeatMode.one
                      ? Icons.repeat_one_rounded
                      : Icons.repeat_rounded,
                  color: repeatMode != MSGXRepeatMode.off
                      ? AppColors.primaryGreen
                      : AppColors.darkTextSecondary,
                  size: 26,
                ),
                if (repeatMode != MSGXRepeatMode.off)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              playerService.cycleRepeatMode();
            },
          ),
        ],
      ),
    );
  }
}
