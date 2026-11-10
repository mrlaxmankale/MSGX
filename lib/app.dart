import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/equalizer/screens/equalizer_screen.dart';
import 'features/home/screens/main_shell.dart';
import 'features/player/screens/now_playing_screen.dart';
import 'features/scanner/screens/scanner_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'navigation/route_manager.dart';

/// MSGX Root Application Widget.
class MSGXApp extends ConsumerWidget {
  const MSGXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'MSGX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: RouteManager.mainShell,
      routes: {
        RouteManager.mainShell: (context) => const MainShell(),
        RouteManager.nowPlaying: (context) => const NowPlayingScreen(),
        RouteManager.equalizer: (context) => const EqualizerScreen(),
        RouteManager.settings: (context) => const SettingsScreen(),
        RouteManager.scanner: (context) => const ScannerScreen(),
      },
    );
  }
}
