import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../library/providers/library_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) {
    return {'songs': [], 'albums': [], 'artists': []};
  }
  final db = ref.watch(databaseProvider);
  return await db.searchAll(query);
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  static const _historyKey = 'search_history_list';

  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    state = list;
  }

  Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final current = List<String>.from(state);
    current.remove(trimmed);
    current.insert(0, trimmed);
    if (current.length > 20) current.removeLast();
    state = current;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, current);
  }

  Future<void> removeQuery(String query) async {
    final current = List<String>.from(state)..remove(query);
    state = current;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, current);
  }

  Future<void> clearHistory() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});
