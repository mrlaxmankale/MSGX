/// Data model representing a music artist.
class Artist {
  final int? id;
  final String name;
  final int songCount;
  final int albumCount;

  const Artist({
    this.id,
    required this.name,
    required this.songCount,
    this.albumCount = 0,
  });

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map['id'] as int?,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? map['name'] as String
          : 'Unknown Artist',
      songCount: (map['song_count'] as num?)?.toInt() ?? 0,
      albumCount: (map['album_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'song_count': songCount,
      'album_count': albumCount,
    };
  }

  Artist copyWith({
    int? id,
    String? name,
    int? songCount,
    int? albumCount,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      songCount: songCount ?? this.songCount,
      albumCount: albumCount ?? this.albumCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
