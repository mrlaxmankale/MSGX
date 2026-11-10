import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:msgx/features/settings/screens/settings_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('SettingsScreen displays theme, audio settings, and about info',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('AUDIO & PLAYBACK'), findsOneWidget);
    expect(find.text('Equalizer & Audio Effects'), findsOneWidget);
    expect(find.text('Sleep Timer'), findsOneWidget);
    expect(find.text('LIBRARY & STORAGE'), findsOneWidget);
    expect(find.text('Rescan Library'), findsOneWidget);
  });
}
