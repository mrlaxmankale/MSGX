/// Data model representing a local folder containing audio files.
class MusicFolder {
  final String path;
  final String name;
  final int songCount;

  const MusicFolder({
    required this.path,
    required this.name,
    required this.songCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicFolder &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
