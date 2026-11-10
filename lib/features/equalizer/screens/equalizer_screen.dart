import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../player/providers/player_provider.dart';

/// Audio settings & Equalizer screen supporting presets, playback speed, and audio sessions.
class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  String _selectedPreset = 'Normal';
  final List<String> _presets = [
    'Normal',
    'Bass Boost',
    'Classical',
    'Dance',
    'Electronic',
    'Hip-Hop',
    'Jazz',
    'Pop',
    'Rock',
  ];

  // Frequency bands (dB gain representation: -10 to +10 dB)
  final Map<String, double> _bandGains = {
    '60 Hz': 0.0,
    '230 Hz': 0.0,
    '910 Hz': 0.0,
    '3.6 kHz': 0.0,
    '14 kHz': 0.0,
  };

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      switch (preset) {
        case 'Bass Boost':
          _bandGains['60 Hz'] = 6.0;
          _bandGains['230 Hz'] = 4.0;
          _bandGains['910 Hz'] = 1.0;
          _bandGains['3.6 kHz'] = 0.0;
          _bandGains['14 kHz'] = 0.0;
          break;
        case 'Classical':
          _bandGains['60 Hz'] = 4.0;
          _bandGains['230 Hz'] = 3.0;
          _bandGains['910 Hz'] = -2.0;
          _bandGains['3.6 kHz'] = 3.0;
          _bandGains['14 kHz'] = 4.0;
          break;
        case 'Dance':
          _bandGains['60 Hz'] = 5.0;
          _bandGains['230 Hz'] = 4.0;
          _bandGains['910 Hz'] = 2.0;
          _bandGains['3.6 kHz'] = 3.0;
          _bandGains['14 kHz'] = 1.0;
          break;
        case 'Hip-Hop':
          _bandGains['60 Hz'] = 6.0;
          _bandGains['230 Hz'] = 5.0;
          _bandGains['910 Hz'] = 0.0;
          _bandGains['3.6 kHz'] = 2.0;
          _bandGains['14 kHz'] = 3.0;
          break;
        case 'Rock':
          _bandGains['60 Hz'] = 5.0;
          _bandGains['230 Hz'] = 3.0;
          _bandGains['910 Hz'] = -1.0;
          _bandGains['3.6 kHz'] = 3.0;
          _bandGains['14 kHz'] = 5.0;
          break;
        case 'Normal':
        default:
          _bandGains.updateAll((key, val) => 0.0);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerService = ref.watch(audioPlayerServiceProvider);
    final speed = playerService.playbackSpeed;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Audio Settings & Equalizer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform notice if hardware equalizer requires native DSP support
            if (!Platform.isAndroid)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkSecondarySurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkDivider),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.primaryGreen, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hardware EQ presets are enabled. Platform DSP adjustments apply when device audio engine allows.',
                        style: TextStyle(
                            color: AppColors.darkTextSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Presets Section
            const Text(
              'PRESETS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((preset) {
                final isSelected = preset == _selectedPreset;
                return ChoiceChip(
                  label: Text(preset),
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.darkSecondarySurface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) _applyPreset(preset);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Equalizer Frequency Bands Sliders
            const Text(
              'FREQUENCY BANDS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.darkPrimarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _bandGains.entries.map((entry) {
                  return Column(
                    children: [
                      Text(
                        '${entry.value > 0 ? '+' : ''}${entry.value.toInt()}dB',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.darkTextSecondary),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 160,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                              trackHeight: 3.0,
                            ),
                            child: Slider(
                              value: entry.value,
                              min: -10.0,
                              max: 10.0,
                              activeColor: AppColors.primaryGreen,
                              inactiveColor: AppColors.darkDivider,
                              onChanged: (newVal) {
                                setState(() {
                                  _bandGains[entry.key] =
                                      newVal.roundToDouble();
                                  _selectedPreset = 'Custom';
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Playback Speed Adjustment
            const Text(
              'PLAYBACK SPEED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkPrimarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.speed_rounded,
                      color: AppColors.primaryGreen),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '${speed}x',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  DropdownButton<double>(
                    value: speed,
                    dropdownColor: AppColors.darkSecondarySurface,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: 0.5,
                          child: Text('0.5x',
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: 0.75,
                          child: Text('0.75x',
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: 1.0,
                          child: Text('1.0x (Normal)',
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: 1.25,
                          child: Text('1.25x',
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: 1.5,
                          child: Text('1.5x',
                              style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(
                          value: 2.0,
                          child: Text('2.0x',
                              style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (newSpeed) {
                      if (newSpeed != null) {
                        playerService.setPlaybackSpeed(newSpeed);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
