/// Data model representing an album grouped by title and artist.
class Album {
  final int? id;
  final String name;
  final String artist;
  final String? artworkReference;
  final int songCount;
  final int totalDuration; // milliseconds

  const Album({
    this.id,
    required this.name,
    required this.artist,
    this.artworkReference,
    required this.songCount,
    this.totalDuration = 0,
  });

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'] as int?,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? map['name'] as String
          : 'Unknown Album',
      artist: (map['artist'] as String?)?.trim().isNotEmpty == true
          ? map['artist'] as String
          : 'Unknown Artist',
      artworkReference: map['artwork_reference'] as String?,
      songCount: (map['song_count'] as num?)?.toInt() ?? 0,
      totalDuration: (map['total_duration'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'artist': artist,
      'artwork_reference': artworkReference,
      'song_count': songCount,
      'total_duration': totalDuration,
    };
  }

  Album copyWith({
    int? id,
    String? name,
    String? artist,
    String? artworkReference,
    int? songCount,
    int? totalDuration,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      artworkReference: artworkReference ?? this.artworkReference,
      songCount: songCount ?? this.songCount,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          artist == other.artist;

  @override
  int get hashCode => name.hashCode ^ artist.hashCode;
}
