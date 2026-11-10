import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../navigation/app_navigation.dart';
import '../../../shared/widgets/app_bottom_navigation.dart';
import '../../../shared/widgets/mini_player.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../library/screens/library_screen.dart';
import '../../search/screens/search_screen.dart';
import 'home_screen.dart';

/// Main navigation shell housing the 4 core tabs and the persistent mini-player.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const List<Widget> _tabs = [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: IndexedStack(
        index: currentTab,
        children: _tabs,
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(),
          AppBottomNavigation(),
        ],
      ),
    );
  }
}
