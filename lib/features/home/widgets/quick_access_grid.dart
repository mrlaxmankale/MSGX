import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../playlists/providers/playlists_provider.dart';
import '../../playlists/screens/playlist_detail_screen.dart';
import '../../../navigation/app_navigation.dart';

/// 2-column Spotify-inspired quick access grid for favorites and top playlists.
class QuickAccessGrid extends ConsumerWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final playlistsAsync = ref.watch(playlistsProvider);

    final favCount = favoritesAsync.value?.length ?? 0;
    final playlists = playlistsAsync.value ?? [];

    final List<Widget> items = [];

    // Liked Songs card
    items.add(
      _QuickAccessCard(
        title: 'Liked Songs',
        subtitle: '$favCount songs',
        gradientColors: const [Color(0xFF450AF5), Color(0xFF8E8EE5)],
        icon: Icons.favorite_rounded,
        onTap: () {
          ref.read(currentTabProvider.notifier).state =
              3; // Switch to Favorites tab
        },
      ),
    );

    // Up to 5 user playlists
    for (int i = 0; i < playlists.length && i < 5; i++) {
      final p = playlists[i];
      items.add(
        _QuickAccessCard(
          title: p.name,
          subtitle: '${p.songCount} songs',
          gradientColors: const [Color(0xFF282828), Color(0xFF181818)],
          icon: Icons.playlist_play_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlaylistDetailScreen(playlist: p),
              ),
            );
          },
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items,
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkPrimarySurface,
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              width: 52,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
