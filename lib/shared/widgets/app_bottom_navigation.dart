import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../navigation/app_navigation.dart';

/// Spotify-style 4-tab bottom navigation bar for MSGX.
class AppBottomNavigation extends ConsumerWidget {
  const AppBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkPrimarySurface,
        border: Border(
          top: BorderSide(
            color: Color(0x1FFFFFFF),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: AppColors.darkTextSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            activeIcon: Icon(Icons.library_music_rounded),
            label: 'Your Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
