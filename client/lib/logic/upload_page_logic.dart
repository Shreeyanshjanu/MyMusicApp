import 'package:client/errors/upload_page_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/services/auth_services.dart';
import '../core/constants/server_constant.dart';

class YouTubeVideoInfo {
  final String title;
  final String artist;
  final String thumbnailUrl;
  final Duration duration;
  final String audioUrl;
  final String? videoId;

  YouTubeVideoInfo({
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.duration,
    required this.audioUrl,
    required this.videoId,
  });
}

class UploadPageLogic {
  static final YoutubeExplode _yt = YoutubeExplode();

  // Common suggestion genres
  static const List<String> suggestionGenres = [
    'Pop', 'Rock', 'Hip Hop', 'Electronic', 'Jazz', 'Classical', 
    'Country', 'R&B', 'Reggae', 'Blues', 'Folk', 'Alternative',
    'Indie', 'Metal', 'Punk', 'Disco', 'Funk', 'Soul', 'Gospel',
    'Latin', 'World Music', 'Ambient', 'Techno', 'House', 'Dubstep',
    'Romantic', 'Love', 'Motivational', 'Oldies', 'Chill', 'Lofi'
  ];

  // Authentication validation
  static bool validateAuthentication(BuildContext context) {
    if (!AuthService.isLoggedIn()) {
      UploadPageErrors.showErrorSnackBar(context, 'Please log in to upload songs');
      return false;
    }
    return true;
  }

  // Load existing genres from server
  static Future<List<String>> loadExistingGenres() async {
    try {
      UploadPageErrors.logInfo('Genres', 'Loading existing genres from server');
      
      final response = await http.get(
        Uri.parse('${ServerConstant.serverURL}${ServerConstant.songsEndpoint}/'),
        headers: AuthService.getAuthHeaders(),
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> songsData = jsonDecode(response.body);
        Set<String> genresSet = {};
        
        for (var songData in songsData) {
          if (songData['genre'] != null && songData['genre'].toString().trim().isNotEmpty) {
            genresSet.add(songData['genre'].toString().trim());
          }
        }
        
        final genres = genresSet.toList()..sort();
        UploadPageErrors.logSuccess('Genres', 'Loaded ${genres.length} existing genres: $genres');
        return genres;
      } else {
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      UploadPageErrors.logError('Genres', e);
      final errorMessage = UploadPageErrors.getGenreLoadErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // Paste from clipboard
  static Future<String?> pasteFromClipboard(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        UploadPageErrors.showSuccessSnackBar(context, 'URL pasted from clipboard');
        return clipboardData.text!;
      } else {
        UploadPageErrors.showErrorSnackBar(context, 'Clipboard is empty');
        return null;
      }
    } catch (e) {
      final errorMessage = UploadPageErrors.getClipboardErrorMessage(e);
      UploadPageErrors.showErrorSnackBar(context, errorMessage);
      return null;
    }
  }

  // Extract video ID from URL
  static String? extractVideoId(String url) {
    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)'),
      RegExp(r'youtube\.com\/embed\/([^&\n?#]+)'),
      RegExp(r'youtube\.com\/v\/([^&\n?#]+)'),
      RegExp(r'youtube\.com\/shorts\/([^&\n?#]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }
    return null;
  }

  // Clean video title to extract artist and title
  static Map<String, String> cleanTitle(String title) {
    title = title
        .replaceAll(RegExp(r'\(Official.*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[Official.*?\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(Music Video\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(Audio\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(Lyric.*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[Lyric.*?\]', caseSensitive: false), '')
        .trim();

    final patterns = [
      RegExp(r'^(.+?)\s*[-–—]\s*(.+)$'),
      RegExp(r'^(.+?)\s*[:|]\s*(.+)$'),
      RegExp(r'^(.+?)\s*by\s+(.+)$', caseSensitive: false),
      RegExp(r'^(.+?)\s*\|\s*(.+)$'),
      RegExp(r'^(.+?)\s*ft\.?\s+(.+)$', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(title);
      if (match != null) {
        return {
          'artist': match.group(1)?.trim() ?? '',
          'title': match.group(2)?.trim() ?? '',
        };
      }
    }

    return {'title': title, 'artist': ''};
  }

  // Extract song information from YouTube URL
  static Future<YouTubeVideoInfo> extractSongInfo(BuildContext context, String url) async {
    // Validate URL
    final urlError = UploadPageErrors.validateUrl(url);
    if (urlError != null) {
      throw Exception(urlError);
    }

    try {
      final videoId = extractVideoId(url.trim());
      if (videoId == null) {
        throw Exception('Invalid YouTube URL format');
      }

      UploadPageErrors.logInfo('Extraction', 'Extracting video with ID: $videoId');

      final video = await _yt.videos.get(videoId);
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      
      if (audioStream == null) {
        throw Exception('No audio stream available for this video');
      }

      String title = video.title;
      String artist = video.author;
      
      final cleanTitle = UploadPageLogic.cleanTitle(title);
      if (cleanTitle['artist']?.isNotEmpty == true) {
        artist = cleanTitle['artist']!;
        title = cleanTitle['title']!;
      }

      final videoInfo = YouTubeVideoInfo(
        title: title,
        artist: artist,
        thumbnailUrl: video.thumbnails.highResUrl,
        duration: video.duration ?? Duration.zero,
        audioUrl: audioStream.url.toString(),
        videoId: videoId,
      );

      UploadPageErrors.logSuccess('Extraction', 'Song information extracted successfully');
      UploadPageErrors.showSuccessSnackBar(context, 'Song information extracted successfully!');
      
      return videoInfo;
      
    } catch (e) {
      UploadPageErrors.logError('Extraction', e);
      final errorMessage = UploadPageErrors.getExtractionErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // Upload song to server
  static Future<bool> uploadSong({
    required BuildContext context,
    required YouTubeVideoInfo extractedVideo,
    required String selectedGenre,
    required Function(List<String>) updateGenres,
  }) async {
    // Validate upload data
    final validationError = UploadPageErrors.validateUploadData(
      extractedVideo: extractedVideo,
      selectedGenre: selectedGenre,
    );

    if (validationError != null) {
      UploadPageErrors.showErrorSnackBar(context, validationError);
      return false;
    }

    // Double-check authentication
    if (!validateAuthentication(context)) {
      return false;
    }

    try {
      // Clean and validate genre
      final cleanGenre = UploadPageErrors.cleanGenreName(selectedGenre);
      
      final songData = {
        'song_name': extractedVideo.title,
        'artist': extractedVideo.artist,
        'genre': cleanGenre,
        'audio_path': extractedVideo.audioUrl,
        'video_path': null,
        'thumbnail': extractedVideo.thumbnailUrl,
        'duration': formatDuration(extractedVideo.duration),
        'youtube_url': "https://youtu.be/${extractedVideo.videoId}",
        'video_id': extractedVideo.videoId,
      };

      UploadPageErrors.logInfo('Upload', 'Uploading song with genre: $cleanGenre');

      final response = await http.post(
        Uri.parse('${ServerConstant.serverURL}${ServerConstant.songsEndpoint}/'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode(songData),
      ).timeout(Duration(seconds: 30));

      UploadPageErrors.logInfo('Upload', 'Upload response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        UploadPageErrors.logSuccess('Upload', 'Song uploaded successfully');
        UploadPageErrors.showSuccessSnackBar(context, 'Song added to "$cleanGenre" successfully!');

        // Update available genres if new genre was created
        updateGenres([cleanGenre]);

        return true;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        UploadPageErrors.showErrorSnackBar(context, 'Session expired. Please log in again.');
        Navigator.pop(context);
        return false;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      UploadPageErrors.logError('Upload', e);
      final errorMessage = UploadPageErrors.getUploadErrorMessage(e);
      UploadPageErrors.showErrorSnackBar(context, errorMessage);
      return false;
    }
  }

  // Format duration to string
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Validate genre selection
  static bool canUpload(String? selectedGenre) {
    return selectedGenre != null && selectedGenre.trim().isNotEmpty;
  }

  // Clean up resources
  static void dispose() {
    _yt.close();
  }

  // Get current user info
  static Map<String, dynamic>? getCurrentUserInfo() {
    try {
      return AuthService.getCurrentUser();
    } catch (e) {
      UploadPageErrors.logError('User', 'Failed to get user info: $e');
      return null;
    }
  }

  // Navigate back with result
  static void navigateBackWithResult(BuildContext context, bool success) {
    if (success) {
      // Navigate back with success result after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      });
    }
  }

  // Clear form data
  static void clearFormData({
    required Function clearExtractedVideo,
    required Function clearSelectedGenre,
    required Function setCustomGenre,
    required TextEditingController genreController,
  }) {
    clearExtractedVideo();
    clearSelectedGenre();
    setCustomGenre(false);
    genreController.clear();
  }

  // Update available genres list
  static List<String> updateGenresList(List<String> currentGenres, List<String> newGenres) {
    final updatedGenres = List<String>.from(currentGenres);
    
    for (final genre in newGenres) {
      if (!updatedGenres.contains(genre)) {
        updatedGenres.add(genre);
      }
    }
    
    updatedGenres.sort();
    UploadPageErrors.logInfo('Genres', 'Updated genres list with new entries');
    return updatedGenres;
  }

  // Validate form state before upload
  static bool validateFormState({
    required YouTubeVideoInfo? extractedVideo,
    required String? selectedGenre,
    required bool isUploading,
  }) {
    if (isUploading) return false;
    if (extractedVideo == null) return false;
    if (!canUpload(selectedGenre)) return false;
    
    return true;
  }

  // Get suggestion genres
  static List<String> getSuggestionGenres() {
    return List.from(suggestionGenres);
  }

  // Check if genre is in suggestions
  static bool isGenreInSuggestions(String genre) {
    return suggestionGenres.contains(genre);
  }
}