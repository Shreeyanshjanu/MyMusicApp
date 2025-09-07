import 'package:flutter/material.dart';
import '../colors/color_pallete.dart';

class SettingsPageErrors {
  // Error handling for logout process
  static String getLogoutErrorMessage(dynamic error) {
    if (error.toString().contains('network') || 
        error.toString().contains('connection')) {
      return 'Network error during logout. Check your connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Logout request timeout. Please try again.';
    } else if (error.toString().contains('auth') || 
               error.toString().contains('token')) {
      return 'Authentication error during logout.';
    } else {
      return 'Error during logout: ${error.toString()}';
    }
  }

  // Error handling for QR code download
  static String getDownloadErrorMessage(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'Permission denied. Please allow storage access.';
    } else if (error.toString().contains('storage') || 
               error.toString().contains('space')) {
      return 'Insufficient storage space. Please free up some space.';
    } else if (error.toString().contains('network') || 
               error.toString().contains('connection')) {
      return 'Network error. Check your internet connection.';
    } else if (error.toString().contains('not found') || 
               error.toString().contains('asset')) {
      return 'QR code image not found. Please contact support.';
    } else {
      return 'Failed to download QR code. Please try again.';
    }
  }

  // Success/Error SnackBar methods
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: ColorPalette.lightShadowColor,
              size: 20,
            ),
            SizedBox(width: 12),
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
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: ColorPalette.lightShadowColor,
              size: 20,
            ),
            SizedBox(width: 12),
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
        duration: duration ?? Duration(seconds: 3),
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
                color: ColorPalette.lightShadowColor,
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
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message, {Duration? duration}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.thumb_up,
              color: ColorPalette.lightShadowColor,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: ColorPalette.accentColor,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static void showSupportSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.favorite,
              color: ColorPalette.lightShadowColor,
              size: 18,
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
        duration: Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Validation methods
  static bool validateLogoutAttempt() {
    // Add any pre-logout validation if needed
    return true;
  }

  static bool validateDownloadAttempt() {
    // Add any pre-download validation if needed
    return true;
  }

  // Debug logging methods
  static void logError(String context, dynamic error) {
    print('❌ Settings Error [$context]: $error');
  }

  static void logSuccess(String context, String message) {
    print('✅ Settings Success [$context]: $message');
  }

  static void logInfo(String context, String message) {
    print('ℹ️ Settings Info [$context]: $message');
  }

  // Handle asset loading errors
  static String getAssetErrorMessage(String assetPath, dynamic error) {
    if (error.toString().contains('not found')) {
      return 'Asset not found: $assetPath';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied accessing asset: $assetPath';
    } else {
      return 'Error loading asset: $assetPath - $error';
    }
  }
}