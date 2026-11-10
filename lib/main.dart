import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/database/app_database.dart';
import 'core/utils/error_handler.dart';
import 'features/player/services/audio_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style to Spotify dark aesthetics
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF181818),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    // 1. Initialize SQLite database
    await AppDatabase().database;

    // 2. Initialize Audio Service and Background Notification handler
    await AudioPlayerService().initAudioService();
  } catch (e, stack) {
    ErrorHandler.logError('main', e, stack);
  }

  runApp(
    const ProviderScope(
      child: MSGXApp(),
    ),
  );
}
