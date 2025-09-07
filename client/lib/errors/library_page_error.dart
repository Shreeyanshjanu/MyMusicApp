import 'package:flutter/material.dart';
import '../colors/color_pallete.dart';

class LibraryPageErrors {
  // Song validation - matches original Song model structure
  static String? validateSong(dynamic song) {
    if (song == null) {
      return 'Song data is null';
    }
    
    try {
      // Check for required Song model properties (matches your Song.fromJson)
      if (song.id == null) {
        return 'Song ID is missing';
      }
      
      if (song.songName == null || song.songName.isEmpty) {
        return 'Song name is missing';
      }
      
      if (song.artist == null || song.artist.isEmpty) {
        return 'Artist name is missing';
      }
      
      // Ensure audioPath exists for playback
      if (song.audioPath == null || song.audioPath.isEmpty) {
        return 'Audio path is missing';
      }
      
      return null;
    } catch (e) {
      return 'Invalid song data structure: $e';
    }
  }

  // Simple error handling without complex categorization
  static String getLoadingErrorMessage(dynamic error) {
    if (error.toString().contains('401')) {
      return 'Session expired. Please log in again.';
    } else if (error.toString().contains('network') || 
               error.toString().contains('connection')) {
      return 'Connection error. Check your internet and server.';
    } else {
      return 'Error loading library: $error';
    }
  }

  static String getPlaybackErrorMessage(dynamic error) {
    return 'Error playing song: $error';
  }

  // SnackBar methods - exact same as original
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorPalette.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Debug logging
  static void logError(String context, dynamic error) {
    print('❌ Library Error [$context]: $error');
  }

  static void logSuccess(String context, String message) {
    print('✅ Library Success [$context]: $message');
  }

  static void logInfo(String context, String message) {
    print('ℹ️ Library Info [$context]: $message');
  }
  static void logWarning(String category, String message) {  // Add this method
    print('⚠️ [$category] Warning: $message');
  }
}