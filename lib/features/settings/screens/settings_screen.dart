import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../equalizer/screens/equalizer_screen.dart';
import '../../library/providers/library_provider.dart';
import '../../player/providers/player_provider.dart';
import '../../scanner/screens/scanner_screen.dart';

/// Provider for app theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Application Settings and About Screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Section: General
          _sectionHeader('GENERAL'),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: Colors.white),
            title: const Text('Theme', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              currentTheme == ThemeMode.dark
                  ? 'Dark (Spotify Classic)'
                  : (currentTheme == ThemeMode.light
                      ? 'Light'
                      : 'System default'),
              style: const TextStyle(
                  color: AppColors.darkTextSecondary, fontSize: 12),
            ),
            trailing: DropdownButton<ThemeMode>(
              value: currentTheme,
              dropdownColor: AppColors.darkSecondarySurface,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).state = mode;
                }
              },
            ),
          ),

          // Section: Audio & Playback
          _sectionHeader('AUDIO & PLAYBACK'),
          ListTile(
            leading: const Icon(Icons.tune_rounded, color: Colors.white),
            title: const Text('Equalizer & Audio Effects',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Adjust frequency bands, presets and playback speed',
                style: TextStyle(
                    color: AppColors.darkTextSecondary, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.darkTextSecondary),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EqualizerScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined, color: Colors.white),
            title: const Text('Sleep Timer',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Automatically stop playback after duration',
                style: TextStyle(
                    color: AppColors.darkTextSecondary, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.darkTextSecondary),
            onTap: () {
              _showSleepTimerPicker(context, ref);
            },
          ),

          // Section: Library & Storage
          _sectionHeader('LIBRARY & STORAGE'),
          ListTile(
            leading: const Icon(Icons.radar_rounded, color: Colors.white),
            title: const Text('Rescan Library',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Discover new or updated audio files on your device',
                style: TextStyle(
                    color: AppColors.darkTextSecondary, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.darkTextSecondary),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded, color: Colors.white),
            title: const Text('Clear Playback History',
                style: TextStyle(color: Colors.white)),
            onTap: () async {
              await AppDatabase().clearPlayHistory();
              ref.invalidate(recentlyPlayedProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Playback history cleared')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            title: const Text('Reset Library Database',
                style: TextStyle(color: AppColors.error)),
            subtitle: const Text(
                'Clears metadata cache and rescans device files',
                style: TextStyle(
                    color: AppColors.darkTextSecondary, fontSize: 12)),
            onTap: () => _confirmResetDatabase(context, ref),
          ),

          // Section: About
          _sectionHeader('ABOUT'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded, color: Colors.white),
            title: Text('MSGX Offline Music Player',
                style: TextStyle(color: Colors.white)),
            subtitle: Text(
                'Version ${AppConstants.appVersion}\n${AppConstants.appTagline}',
                style: TextStyle(
                    color: AppColors.darkTextSecondary, fontSize: 12)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Text(
              'MSGX is an independent, 100% offline-first music player application. Built with Flutter, Riverpod, SQLite, and just_audio.',
              style: TextStyle(
                  color: AppColors.darkTextMuted, fontSize: 11, height: 1.4),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showSleepTimerPicker(BuildContext context, WidgetRef ref) {
    final playerService = ref.read(audioPlayerServiceProvider);
    final durations = [5, 10, 15, 30, 45, 60];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkPrimarySurface,
        title: const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations
              .map((m) => ListTile(
                    title: Text('$m minutes',
                        style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      playerService.setSleepTimer(m);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Sleep timer set for $m minutes')),
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _confirmResetDatabase(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkPrimarySurface,
        title: const Text('Reset Library Database?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will clear the cached database and history. Your actual audio files on your device will NOT be touched.',
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AppDatabase().close();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              ref.invalidate(allSongsProvider);
              ref.invalidate(allAlbumsProvider);
              ref.invalidate(allArtistsProvider);
              ref.invalidate(recentlyAddedProvider);
              ref.invalidate(recentlyPlayedProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Database reset. Tap scan to reload your music.')),
                );
              }
            },
            child:
                const Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
