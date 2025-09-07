class Song {
  final int id;
  final String songName;
  final String artist;
  final String genre;
  final String audioPath;
  final String? thumbnail;
  final String? duration;
  final String? youtubeUrl;
  final String? videoId; // <-- ADD THIS FIELD

  Song({
    required this.id,
    required this.songName,
    required this.artist,
    required this.genre,
    required this.audioPath,
    this.thumbnail,
    this.duration,
    this.youtubeUrl,
    this.videoId, // <-- ADD THIS PARAMETER
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? 0,
      songName: json['song_name'] ?? 'Unknown Song',
      artist: json['artist'] ?? 'Unknown Artist',
      genre: json['genre'] ?? 'Unknown',
      audioPath: json['audio_path'] ?? '',
      thumbnail: json['thumbnail'],
      duration: json['duration'],
      youtubeUrl: json['youtube_url'],
      videoId: json['video_id'], // <-- ADD THIS LINE
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'song_name': songName,
      'artist': artist,
      'genre': genre,
      'audio_path': audioPath,
      'thumbnail': thumbnail,
      'duration': duration,
      'youtube_url': youtubeUrl,
      'video_id': videoId, // <-- ADD THIS LINE
    };
  }

  Song copyWith({
    int? id,
    String? songName,
    String? artist,
    String? genre,
    String? audioPath,
    String? thumbnail,
    String? duration,
    String? youtubeUrl,
    String? videoId, // <-- ADD THIS PARAMETER
  }) {
    return Song(
      id: id ?? this.id,
      songName: songName ?? this.songName,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      audioPath: audioPath ?? this.audioPath,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      videoId: videoId ?? this.videoId, // <-- ADD THIS LINE
    );
  }
}