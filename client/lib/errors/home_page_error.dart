import 'package:flutter/material.dart';
import '../colors/color_pallete.dart';

class HomePageErrors {
  // Audio player validation
  static String? validateAudioUrl(String? audioUrl) {
    if (audioUrl == null || audioUrl.isEmpty) {
      return 'Audio URL is empty';
    }
    
    try {
      final uri = Uri.parse(audioUrl);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return 'Invalid audio URL scheme: ${uri.scheme}';
      }
      return null;
    } catch (e) {
      return 'Invalid audio URL format: $e';
    }
  }

  // Library validation
  static String? validateLibrary(List<dynamic>? songs) {
    if (songs == null) {
      return 'Library data is null';
    }
    
    if (songs.isEmpty) {
      return 'No songs found in library';
    }
    
    return null;
  }

  // 🔥 FIXED: Add the missing getAudioPlayerErrorMessage method
  static String getAudioPlayerErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || 
        errorString.contains('connection')) {
      return 'Network error during playback. Check your connection.';
    } else if (errorString.contains('timeout')) {
      return 'Audio loading timeout. Try refreshing the song.';
    } else if (errorString.contains('format') || 
               errorString.contains('codec')) {
      return 'Unsupported audio format. Try another song.';
    } else if (errorString.contains('403') || 
               errorString.contains('forbidden')) {
      return 'Audio access denied. URL may have expired.';
    } else if (errorString.contains('404') || 
               errorString.contains('not found')) {
      return 'Audio not found. Try refreshing the song.';
    } else if (errorString.contains('source error')) {
      return 'Audio source error. Refreshing...';
    } else {
      return 'Audio playback error. Please try again.';
    }
  }

  // Library loading error messages
  static String getLibraryLoadErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('422')) {
      return 'Authentication error. Please login again.';
    } else if (errorString.contains('network') || 
               errorString.contains('connection')) {
      return 'Network error. Check your connection.';
    } else if (errorString.contains('401') || 
               errorString.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else {
      return 'Error loading library. Please try again.';
    }
  }

  // Critical error messages for user display
  static String getCriticalErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('video not found') || 
        errorString.contains('404')) {
      return 'This song is no longer available. Try playing another song.';
    } else if (errorString.contains('private') || 
               errorString.contains('restricted')) {
      return 'This song is private or restricted. Try playing another song.';
    } else if (errorString.contains('network') && 
               !errorString.contains('youtube')) {
      return 'Network error. Check your connection.';
    } else if (errorString.contains('httpclientclosedexception')) {
      return 'Connection closed. Refreshing...';
    } else {
      return 'Unable to play this song. Try playing another song.';
    }
  }

  // URL refresh error messages
  static String getUrlRefreshErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('video not found') || 
        errorString.contains('404')) {
      return 'Video not found. It may have been deleted.';
    } else if (errorString.contains('private') || 
               errorString.contains('restricted')) {
      return 'Video is private or restricted.';
    } else if (errorString.contains('network')) {
      return 'Network error refreshing audio. Check connection.';
    } else if (errorString.contains('httpclientclosedexception')) {
      return 'Connection closed during refresh. Retrying...';
    } else {
      return 'Failed to refresh audio. Try playing another song.';
    }
  }

  // SnackBar methods
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: ColorPalette.romanticColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: ColorPalette.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void showLoadingInfo(BuildContext context, String message) {
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Debug logging methods
  static void logError(String context, dynamic error) {
    print('❌ Home Error [$context]: $error');
  }

  static void logSuccess(String context, String message) {
    print('✅ Home Success [$context]: $message');
  }

  static void logInfo(String context, String message) {
    print('ℹ️ Home Info [$context]: $message');
  }

  static void logWarning(String context, String message) {
    print('⚠️ Home Warning [$context]: $message');
  }

  // Duration parsing
  static Duration? parseDuration(String durationString) {
    try {
      final parts = durationString.split(':');
      if (parts.length == 2) {
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return Duration(minutes: minutes, seconds: seconds);
      } else if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return Duration(hours: hours, minutes: minutes, seconds: seconds);
      }
    } catch (e) {
      logError('Duration', 'Error parsing duration "$durationString": $e');
    }
    return Duration.zero;
  }

  // Check disposal state
  static bool checkDisposalState(bool isDisposed, String operation) {
    if (isDisposed) {
      logWarning('Disposal', 'Attempted $operation on disposed object');
      return false;
    }
    return true;
  }
}