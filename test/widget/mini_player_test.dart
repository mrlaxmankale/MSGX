import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:msgx/shared/widgets/mini_player.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('MiniPlayer is hidden when no track is loaded',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MiniPlayer(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Since currentSong is null, MiniPlayer should be sized box shrink
    expect(find.byType(MiniPlayer), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
  });
}
