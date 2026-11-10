import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../providers/player_provider.dart';

/// Interactive progress slider with formatted position and duration timestamps.
class PlayerProgressBar extends ConsumerStatefulWidget {
  const PlayerProgressBar({super.key});

  @override
  ConsumerState<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends ConsumerState<PlayerProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(playerPositionStreamProvider);
    final durationAsync = ref.watch(playerDurationStreamProvider);
    final currentSong = ref.watch(currentSongProvider);

    final totalDurationMs =
        durationAsync.value?.inMilliseconds ?? currentSong?.duration ?? 0;
    final currentPositionMs = positionAsync.value?.inMilliseconds ?? 0;

    final double maxVal =
        (totalDurationMs > 0) ? totalDurationMs.toDouble() : 1.0;
    final double value =
        _dragValue ?? currentPositionMs.toDouble().clamp(0.0, maxVal);

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
            overlayColor: Colors.white10,
          ),
          child: Slider(
            min: 0.0,
            max: maxVal,
            value: value,
            onChanged: (newVal) {
              setState(() {
                _dragValue = newVal;
              });
            },
            onChangeEnd: (finalVal) {
              ref.read(audioPlayerServiceProvider).seek(
                    Duration(milliseconds: finalVal.toInt()),
                  );
              setState(() {
                _dragValue = null;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.formatDurationMs(value.toInt()),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                Formatters.formatDurationMs(totalDurationMs),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
