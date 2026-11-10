/// Data model representing a user-created or smart playlist.
class Playlist {
  final int? id;
  final String name;
  final String? description;
  final String? artworkReference;
  final int createdAt;
  final int updatedAt;
  final int songCount;

  const Playlist({
    this.id,
    required this.name,
    this.description,
    this.artworkReference,
    required this.createdAt,
    required this.updatedAt,
    this.songCount = 0,
  });

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] as int?,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? map['name'] as String
          : 'My Playlist',
      description: map['description'] as String?,
      artworkReference: map['artwork_reference'] as String?,
      createdAt: (map['created_at'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
      songCount: (map['song_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'artwork_reference': artworkReference,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Playlist copyWith({
    int? id,
    String? name,
    String? description,
    String? artworkReference,
    int? createdAt,
    int? updatedAt,
    int? songCount,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      artworkReference: artworkReference ?? this.artworkReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songCount: songCount ?? this.songCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
