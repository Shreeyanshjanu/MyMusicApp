import 'package:flutter/material.dart';
import '../colors/color_pallete.dart';

class UploadPageErrors {
  // URL validation methods
  static String? validateUrl(String url) {
    if (url.trim().isEmpty) {
      return 'Please paste a YouTube URL first';
    }
    
    if (!isValidYouTubeUrl(url)) {
      return 'Invalid YouTube URL format';
    }
    
    return null;
  }

  static bool isValidYouTubeUrl(String url) {
    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)'),
      RegExp(r'youtube\.com\/embed\/([^&\n?#]+)'),
      RegExp(r'youtube\.com\/v\/([^&\n?#]+)'),
      RegExp(r'youtube\.com\/shorts\/([^&\n?#]+)'),
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(url)) {
        return true;
      }
    }
    return false;
  }

  // Genre validation methods
  static String? validateGenre(String? genre) {
    if (genre == null || genre.trim().isEmpty) {
      return 'Please select or create a genre';
    }
    
    final cleanGenre = genre.trim();
    
    if (cleanGenre.length < 2) {
      return 'Genre name must be at least 2 characters';
    }
    
    if (cleanGenre.length > 50) {
      return 'Genre name must be less than 50 characters';
    }
    
    // Check for valid characters (letters, numbers, spaces, hyphens)
    if (!RegExp(r"^[a-zA-Z0-9\s\-&]+$").hasMatch(cleanGenre)) {
      return 'Genre can only contain letters, numbers, spaces, and hyphens';
    }
    
    return null;
  }

  // Upload validation
  static String? validateUploadData({
    required dynamic extractedVideo,
    required String? selectedGenre,
  }) {
    if (extractedVideo == null) {
      return 'Please extract song information first';
    }
    
    final genreError = validateGenre(selectedGenre);
    if (genreError != null) {
      return genreError;
    }
    
    return null;
  }

  // Error message handlers
  static String getExtractionErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid youtube url') || 
        errorString.contains('video id')) {
      return 'Invalid YouTube URL. Please check the link and try again.';
    } else if (errorString.contains('no audio stream')) {
      return 'No audio available for this video. Try a different video.';
    } else if (errorString.contains('network') || 
               errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout. The video might be too long or unavailable.';
    } else if (errorString.contains('private') || 
               errorString.contains('unavailable')) {
      return 'This video is private or unavailable. Try a different video.';
    } else if (errorString.contains('age restricted') || 
               errorString.contains('restricted')) {
      return 'This video is age-restricted and cannot be processed.';
    } else {
      return 'Error extracting video: ${error.toString()}';
    }
  }

  static String getUploadErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('401') || 
        errorString.contains('unauthorized') ||
        errorString.contains('session expired')) {
      return 'Session expired. Please log in again.';
    } else if (errorString.contains('403') || 
               errorString.contains('forbidden')) {
      return 'Access denied. Please check your permissions.';
    } else if (errorString.contains('duplicate') || 
               errorString.contains('already exists')) {
      return 'This song already exists in your library.';
    } else if (errorString.contains('network') || 
               errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Upload timeout. Please try again.';
    } else if (errorString.contains('server error') || 
               errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Error adding song: ${error.toString()}';
    }
  }

  static String getGenreLoadErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('401') || 
        errorString.contains('unauthorized')) {
      return 'Authentication error loading genres.';
    } else if (errorString.contains('network') || 
               errorString.contains('connection')) {
      return 'Network error loading genres.';
    } else if (errorString.contains('timeout')) {
      return 'Timeout loading genres.';
    } else {
      return 'Error loading genres: ${error.toString()}';
    }
  }

  // SnackBar methods
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorPalette.successColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static void showLoadingSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: ColorPalette.accentColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Clipboard error handling
  static String getClipboardErrorMessage(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'Permission denied accessing clipboard.';
    } else if (error.toString().contains('empty')) {
      return 'Clipboard is empty';
    } else {
      return 'Error accessing clipboard: ${error.toString()}';
    }
  }

  // Authentication validation
  static bool validateAuthentication() {
    // This should be imported from AuthService but we'll keep it simple
    // return AuthService.isLoggedIn();
    return true; // Placeholder - actual validation handled in logic layer
  }

  // Debug logging methods
  static void logError(String context, dynamic error) {
    print('❌ Upload Error [$context]: $error');
  }

  static void logSuccess(String context, String message) {
    print('✅ Upload Success [$context]: $message');
  }

  static void logInfo(String context, String message) {
    print('ℹ️ Upload Info [$context]: $message');
  }

  // Validation for extracted video data
  static bool isValidExtractedVideo(dynamic extractedVideo) {
    if (extractedVideo == null) return false;
    
    try {
      // Check if required fields exist (assuming YouTubeVideoInfo structure)
      return extractedVideo.title != null && 
             extractedVideo.title.isNotEmpty &&
             extractedVideo.audioUrl != null && 
             extractedVideo.audioUrl.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Common genre suggestions for validation
  static bool isCommonGenre(String genre) {
    const commonGenres = [
      'Pop', 'Rock', 'Hip Hop', 'Electronic', 'Jazz', 'Classical', 
      'Country', 'R&B', 'Reggae', 'Blues', 'Folk', 'Alternative',
      'Indie', 'Metal', 'Punk', 'Disco', 'Funk', 'Soul', 'Gospel',
      'Latin', 'World Music', 'Ambient', 'Techno', 'House', 'Dubstep',
      'Romantic', 'Love', 'Motivational', 'Oldies', 'Chill', 'Lofi'
    ];
    
    return commonGenres.contains(genre);
  }

  // Clean genre name
  static String cleanGenreName(String genre) {
    return genre.trim()
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' 
            : '')
        .join(' ');
  }
}