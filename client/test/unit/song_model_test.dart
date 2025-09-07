import 'package:flutter_test/flutter_test.dart';
import 'package:client/models/song_model.dart';

void main() {
  group('Song Model Tests', () {
    test('should create Song with required fields', () {
      // Arrange & Act
      final song = Song(
        id: 123,
        songName: 'Test Song',
        artist: 'Test Artist',
        audioPath: 'https://example.com/audio.mp3',
        genre: 'Pop',
      );

      // Assert
      expect(song.id, equals(123));
      expect(song.songName, equals('Test Song'));
      expect(song.artist, equals('Test Artist'));
      expect(song.audioPath, equals('https://example.com/audio.mp3'));
      expect(song.genre, equals('Pop'));
    });

    test('should convert Song to JSON correctly', () {
      // Arrange
      final song = Song(
        id: 123,
        songName: 'Test Song',
        artist: 'Test Artist',
        audioPath: 'https://example.com/audio.mp3',
        genre: 'Pop',
      );

      // Act
      final json = song.toJson();

      // Assert - Use snake_case field names as per your model
      expect(json['id'], equals(123));
      expect(json['song_name'], equals('Test Song'));  // ✅ Fixed: snake_case
      expect(json['artist'], equals('Test Artist'));
      expect(json['audio_path'], equals('https://example.com/audio.mp3'));  // ✅ Fixed: snake_case
      expect(json['genre'], equals('Pop'));
    });

    test('should create Song from JSON correctly', () {
      // Arrange - Use snake_case field names as per your model
      final json = {
        'id': 123,
        'song_name': 'Test Song',      // ✅ Fixed: snake_case
        'artist': 'Test Artist',
        'audio_path': 'https://example.com/audio.mp3',  // ✅ Fixed: snake_case
        'genre': 'Pop',
      };

      // Act
      final song = Song.fromJson(json);

      // Assert
      expect(song.id, equals(123));
      expect(song.songName, equals('Test Song'));
      expect(song.artist, equals('Test Artist'));
      expect(song.audioPath, equals('https://example.com/audio.mp3'));
      expect(song.genre, equals('Pop'));
    });

    test('should handle fromJson with missing fields (defaults)', () {
      // Arrange - Test default values when fields are missing
      final json = {
        'id': 456,
        // Missing other fields to test defaults
      };

      // Act
      final song = Song.fromJson(json);

      // Assert - Check default values from your model
      expect(song.id, equals(456));
      expect(song.songName, equals('Unknown Song'));   // Default from your model
      expect(song.artist, equals('Unknown Artist'));   // Default from your model
      expect(song.genre, equals('Unknown'));           // Default from your model
      expect(song.audioPath, equals(''));              // Default from your model
    });

    test('should handle copyWith correctly', () {
      // Arrange
      final originalSong = Song(
        id: 123,
        songName: 'Original Song',
        artist: 'Original Artist',
        audioPath: 'https://example.com/audio.mp3',
        genre: 'Pop',
      );

      // Act
      final updatedSong = originalSong.copyWith(genre: 'Rock');

      // Assert
      expect(updatedSong.genre, equals('Rock'));
      expect(updatedSong.id, equals(originalSong.id));
      expect(updatedSong.songName, equals(originalSong.songName));
      expect(updatedSong.artist, equals(originalSong.artist));
    });

    test('should handle optional fields correctly', () {
      // Arrange & Act
      final song = Song(
        id: 123,
        songName: 'Test Song',
        artist: 'Test Artist',
        audioPath: 'https://example.com/audio.mp3',
        genre: 'Pop',
        thumbnail: 'https://example.com/thumb.jpg',
        duration: '3:45',
        youtubeUrl: 'https://youtube.com/watch?v=abc123',
        videoId: 'abc123',
      );

      // Assert
      expect(song.thumbnail, equals('https://example.com/thumb.jpg'));
      expect(song.duration, equals('3:45'));
      expect(song.youtubeUrl, equals('https://youtube.com/watch?v=abc123'));
      expect(song.videoId, equals('abc123'));
    });

    test('should handle null optional fields', () {
      // Arrange & Act
      final song = Song(
        id: 123,
        songName: 'Test Song',
        artist: 'Test Artist',
        audioPath: 'https://example.com/audio.mp3',
        genre: 'Pop',
        thumbnail: null,
        duration: null,
        youtubeUrl: null,
        videoId: null,
      );

      // Assert
      expect(song.thumbnail, isNull);
      expect(song.duration, isNull);
      expect(song.youtubeUrl, isNull);
      expect(song.videoId, isNull);
    });

    test('should handle JSON round-trip correctly', () {
      // Arrange
      final originalSong = Song(
        id: 123,
        songName: 'Test Song',
        artist: 'Test Artist',
        audioPath: 'https://example.com/audio.mp3',
        genre: 'Pop',
        thumbnail: 'https://example.com/thumb.jpg',
        duration: '3:45',
        youtubeUrl: 'https://youtube.com/watch?v=abc123',
        videoId: 'abc123',
      );

      // Act
      final json = originalSong.toJson();
      final recreatedSong = Song.fromJson(json);

      // Assert
      expect(recreatedSong.id, equals(originalSong.id));
      expect(recreatedSong.songName, equals(originalSong.songName));
      expect(recreatedSong.artist, equals(originalSong.artist));
      expect(recreatedSong.audioPath, equals(originalSong.audioPath));
      expect(recreatedSong.genre, equals(originalSong.genre));
      expect(recreatedSong.thumbnail, equals(originalSong.thumbnail));
      expect(recreatedSong.duration, equals(originalSong.duration));
      expect(recreatedSong.youtubeUrl, equals(originalSong.youtubeUrl));
      expect(recreatedSong.videoId, equals(originalSong.videoId));
    });

    test('should handle complete JSON with all fields', () {
      // Arrange
      final json = {
        'id': 789,
        'song_name': 'Complete Song',
        'artist': 'Complete Artist',
        'genre': 'Rock',
        'audio_path': 'https://example.com/complete.mp3',
        'thumbnail': 'https://example.com/complete_thumb.jpg',
        'duration': '4:20',
        'youtube_url': 'https://youtube.com/watch?v=complete123',
        'video_id': 'complete123',
      };

      // Act
      final song = Song.fromJson(json);

      // Assert
      expect(song.id, equals(789));
      expect(song.songName, equals('Complete Song'));
      expect(song.artist, equals('Complete Artist'));
      expect(song.genre, equals('Rock'));
      expect(song.audioPath, equals('https://example.com/complete.mp3'));
      expect(song.thumbnail, equals('https://example.com/complete_thumb.jpg'));
      expect(song.duration, equals('4:20'));
      expect(song.youtubeUrl, equals('https://youtube.com/watch?v=complete123'));
      expect(song.videoId, equals('complete123'));
    });

    test('should handle zero ID correctly', () {
      // Arrange & Act
      final song = Song(
        id: 0,
        songName: 'Zero ID Song',
        artist: 'Test Artist',
        audioPath: 'https://example.com/zero.mp3',
        genre: 'Pop',
      );

      // Assert
      expect(song.id, equals(0));
      expect(song.songName, equals('Zero ID Song'));
    });

    test('should handle copyWith with all parameters', () {
      // Arrange
      final originalSong = Song(
        id: 123,
        songName: 'Original',
        artist: 'Original Artist',
        audioPath: 'original.mp3',
        genre: 'Pop',
      );

      // Act
      final updatedSong = originalSong.copyWith(
        id: 456,
        songName: 'Updated Song',
        artist: 'Updated Artist',
        genre: 'Rock',
        audioPath: 'updated.mp3',
        thumbnail: 'updated_thumb.jpg',
        duration: '5:00',
        youtubeUrl: 'https://youtube.com/updated',
        videoId: 'updated123',
      );

      // Assert
      expect(updatedSong.id, equals(456));
      expect(updatedSong.songName, equals('Updated Song'));
      expect(updatedSong.artist, equals('Updated Artist'));
      expect(updatedSong.genre, equals('Rock'));
      expect(updatedSong.audioPath, equals('updated.mp3'));
      expect(updatedSong.thumbnail, equals('updated_thumb.jpg'));
      expect(updatedSong.duration, equals('5:00'));
      expect(updatedSong.youtubeUrl, equals('https://youtube.com/updated'));
      expect(updatedSong.videoId, equals('updated123'));
    });
  });
}