/// Data model representing a local audio track in MSGX.
class Song {
  final int? id;
  final String mediaId;
  final String title;
  final String artist;
  final String album;
  final int? albumId;
  final int? artistId;
  final String filePathOrUri;
  final int duration; // in milliseconds
  final int fileSize; // in bytes
  final String format; // mp3, m4a, flac, etc.
  final String? artworkReference;
  final int dateAdded;
  final int lastModified;
  final bool isFavorite;
  final int? trackNumber;
  final int? year;
  final String? genre;

  const Song({
    this.id,
    required this.mediaId,
    required this.title,
    required this.artist,
    required this.album,
    this.albumId,
    this.artistId,
    required this.filePathOrUri,
    required this.duration,
    required this.fileSize,
    required this.format,
    this.artworkReference,
    required this.dateAdded,
    required this.lastModified,
    this.isFavorite = false,
    this.trackNumber,
    this.year,
    this.genre,
  });

  /// Factory constructor to deserialize SQLite map
  factory Song.fromMap(Map<String, dynamic> map, {bool isFav = false}) {
    return Song(
      id: map['id'] as int?,
      mediaId: map['media_id'] as String? ?? (map['id']?.toString() ?? ''),
      title: (map['title'] as String?)?.trim().isNotEmpty == true
          ? map['title'] as String
          : 'Unknown Title',
      artist: (map['artist'] as String?)?.trim().isNotEmpty == true
          ? map['artist'] as String
          : 'Unknown Artist',
      album: (map['album'] as String?)?.trim().isNotEmpty == true
          ? map['album'] as String
          : 'Unknown Album',
      albumId: map['album_id'] as int?,
      artistId: map['artist_id'] as int?,
      filePathOrUri: map['file_path_or_uri'] as String? ?? '',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      fileSize: (map['file_size'] as num?)?.toInt() ?? 0,
      format: (map['format'] as String?)?.toLowerCase() ?? 'audio',
      artworkReference: map['artwork_reference'] as String?,
      dateAdded: (map['date_added'] as num?)?.toInt() ?? 0,
      lastModified: (map['last_modified'] as num?)?.toInt() ?? 0,
      isFavorite:
          isFav || (map['is_favorite'] == 1 || map['is_favorite'] == true),
      trackNumber: map['track_number'] as int?,
      year: map['year'] as int?,
      genre: map['genre'] as String?,
    );
  }

  /// Serialize to SQLite map for the 'songs' table
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'media_id': mediaId,
      'title': title,
      'artist': artist,
      'album': album,
      'album_id': albumId,
      'artist_id': artistId,
      'file_path_or_uri': filePathOrUri,
      'duration': duration,
      'file_size': fileSize,
      'format': format,
      'artwork_reference': artworkReference,
      'date_added': dateAdded,
      'last_modified': lastModified,
      'track_number': trackNumber,
      'year': year,
      'genre': genre,
    };
  }

  Song copyWith({
    int? id,
    String? mediaId,
    String? title,
    String? artist,
    String? album,
    int? albumId,
    int? artistId,
    String? filePathOrUri,
    int? duration,
    int? fileSize,
    String? format,
    String? artworkReference,
    int? dateAdded,
    int? lastModified,
    bool? isFavorite,
    int? trackNumber,
    int? year,
    String? genre,
  }) {
    return Song(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
      filePathOrUri: filePathOrUri ?? this.filePathOrUri,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      format: format ?? this.format,
      artworkReference: artworkReference ?? this.artworkReference,
      dateAdded: dateAdded ?? this.dateAdded,
      lastModified: lastModified ?? this.lastModified,
      isFavorite: isFavorite ?? this.isFavorite,
      trackNumber: trackNumber ?? this.trackNumber,
      year: year ?? this.year,
      genre: genre ?? this.genre,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song &&
          runtimeType == other.runtimeType &&
          mediaId == other.mediaId &&
          filePathOrUri == other.filePathOrUri;

  @override
  int get hashCode => mediaId.hashCode ^ filePathOrUri.hashCode;
}
