import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:msgx/features/favorites/screens/favorites_screen.dart';
import 'package:msgx/features/favorites/providers/favorites_provider.dart';
import 'package:msgx/models/song.dart';

class FakeFavoritesNotifier extends StateNotifier<AsyncValue<List<Song>>>
    implements FavoritesNotifier {
  FakeFavoritesNotifier([List<Song> initial = const []])
      : super(AsyncValue.data(initial));

  @override
  Future<void> loadFavorites() async {}

  @override
  Future<bool> toggleFavorite(Song song) async => true;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets(
      'FavoritesScreen displays empty state when library has no favorites',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((ref) => FakeFavoritesNotifier([])),
        ],
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Songs you like will appear here'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
  });
}

