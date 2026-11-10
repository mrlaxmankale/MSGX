import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:msgx/app.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('MSGX smoke test: app launches and renders bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MSGXApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify presence of MSGX branding and core navigation labels
    expect(find.text('MSGX'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Your Library'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
  });
}
