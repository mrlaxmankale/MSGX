import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State provider holding the index of the currently active bottom navigation tab:
/// 0: Home
/// 1: Search
/// 2: Library
/// 3: Favorites
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Bottom navigation items enumeration
enum NavigationTab {
  home,
  search,
  library,
  favorites,
}
