import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../scanner/screens/scanner_screen.dart';
import 'songs_screen.dart';
import 'albums_screen.dart';
import 'artists_screen.dart';
import 'folders_screen.dart';
import '../../playlists/screens/playlists_screen.dart';

/// Main Your Library screen with 5 tabs: Songs, Albums, Artists, Playlists, and Folders.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Your Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.radar_rounded, color: Colors.white),
            tooltip: 'Scan Library',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3.0,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.darkTextSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Songs'),
            Tab(text: 'Albums'),
            Tab(text: 'Artists'),
            Tab(text: 'Playlists'),
            Tab(text: 'Folders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SongsTab(),
          AlbumsTab(),
          ArtistsTab(),
          PlaylistsTab(),
          FoldersTab(),
        ],
      ),
    );
  }
}
