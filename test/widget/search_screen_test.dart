import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:msgx/features/search/screens/search_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('SearchScreen renders search bar and placeholder invitation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Search'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('What do you want to listen to?'), findsOneWidget);
    expect(
        find.text('Play what you love\nSearch for songs, artists, or albums'),
        findsOneWidget);
  });
}
