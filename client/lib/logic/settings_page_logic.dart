import 'package:client/colors/color_pallete.dart';
import 'package:client/errors/settings_page_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/services/auth_services.dart';
import 'package:client/pages/login_page.dart';
import 'package:gal/gal.dart';

class SettingsPageLogic {
  // Logout handling - extracted from original
  static Future<void> handleLogout(BuildContext context) async {
    try {
      SettingsPageErrors.logInfo('Logout', 'Starting logout process');
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: ColorPalette.backgroundColor,
            content: Row(
              children: [
                CircularProgressIndicator(color: ColorPalette.accentColor),
                SizedBox(width: 16),
                Text(
                  'Logging out...',
                  style: TextStyle(color: ColorPalette.primaryTextColor),
                ),
              ],
            ),
          );
        },
      );

      // Perform logout
      await AuthService.logout();
      SettingsPageErrors.logSuccess('Logout', 'User logged out successfully');

      // Hide loading dialog
      Navigator.of(context).pop();

      // Show success message
      SettingsPageErrors.showSuccessSnackBar(context, 'Logged out successfully!');

      // Navigate to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
      
    } catch (e) {
      SettingsPageErrors.logError('Logout', e);
      
      // Hide loading dialog if it's showing
      try {
        Navigator.of(context).pop();
      } catch (popError) {
        // Dialog might not be showing
      }

      final errorMessage = SettingsPageErrors.getLogoutErrorMessage(e);
      SettingsPageErrors.showErrorSnackBar(context, errorMessage);
    }
  }

  // QR Code download handling - extracted from original
  static Future<void> downloadQRCode(BuildContext context) async {
    try {
      SettingsPageErrors.logInfo('Download', 'Starting QR code download');

      // Validate download attempt
      if (!SettingsPageErrors.validateDownloadAttempt()) {
        SettingsPageErrors.showErrorSnackBar(context, 'Download not available right now');
        return;
      }

      // Show loading indicator
      SettingsPageErrors.showLoadingSnackBar(context, 'Downloading QR code...');

      // Load the asset as bytes
      final ByteData data = await rootBundle.load('assets/images/qr_code.jpg');
      final Uint8List bytes = data.buffer.asUint8List();

      // Save to gallery using Gal
      await Gal.putImageBytes(
        bytes,
        name: "support_qr_code_${DateTime.now().millisecondsSinceEpoch}",
      );

      SettingsPageErrors.logSuccess('Download', 'QR code saved successfully');

      // Show success message
      SettingsPageErrors.showSuccessSnackBar(
        context, 
        'QR code saved to gallery! 📱✨',
        duration: Duration(seconds: 3),
      );
      
    } catch (e) {
      SettingsPageErrors.logError('Download', e);
      
      final errorMessage = SettingsPageErrors.getDownloadErrorMessage(e);
      SettingsPageErrors.showErrorSnackBar(context, errorMessage);
    }
  }

  // Handle support button interaction
  static void handleSupportInteraction(BuildContext context) {
    SettingsPageErrors.logInfo('Support', 'Support button tapped');
    Navigator.of(context).pop();
    SettingsPageErrors.showSupportSuccessSnackBar(
      context,
      'Thank you! ❤️ Your support means everything!',
    );
  }

  // Handle maybe later interaction
  static void handleMaybeLaterInteraction(BuildContext context) {
    SettingsPageErrors.logInfo('Support', 'Maybe Later tapped');
    Navigator.of(context).pop();
    SettingsPageErrors.showInfoSnackBar(
      context,
      'Thank you for considering! 🙏',
    );
  }

  // Handle coming soon features
  static void handleComingSoonFeature(BuildContext context, String feature) {
    SettingsPageErrors.logInfo('Feature', '$feature feature requested (coming soon)');
    // This is handled by the UI layer with a dialog
  }

  // Get current user information
  static Map<String, dynamic>? getCurrentUserInfo() {
    try {
      final user = AuthService.getCurrentUser();
      SettingsPageErrors.logInfo('User', 'Retrieved user info: ${user?['name']}');
      return user;
    } catch (e) {
      SettingsPageErrors.logError('User', 'Failed to get user info: $e');
      return null;
    }
  }

  // Validate user session
  static bool validateUserSession() {
    try {
      final isLoggedIn = AuthService.isLoggedIn();
      final user = AuthService.getCurrentUser();
      
      if (!isLoggedIn || user == null) {
        SettingsPageErrors.logError('Session', 'Invalid user session detected');
        return false;
      }
      
      SettingsPageErrors.logInfo('Session', 'User session is valid');
      return true;
    } catch (e) {
      SettingsPageErrors.logError('Session', 'Session validation failed: $e');
      return false;
    }
  }

  // Handle navigation back to previous page
  static void handleBackNavigation(BuildContext context) {
    SettingsPageErrors.logInfo('Navigation', 'Back navigation requested');
    Navigator.of(context).pop();
  }

  // Get app version information
  static String getAppVersion() {
    return 'Music App v1.0.0';
  }

  // Handle settings item tap
  static void handleSettingsItemTap(String itemName, {VoidCallback? onTap}) {
    SettingsPageErrors.logInfo('Settings', '$itemName item tapped');
    if (onTap != null) {
      onTap();
    }
  }

  // Validate QR code asset existence
  static Future<bool> validateQRCodeAsset() async {
    try {
      await rootBundle.load('assets/images/qr_code.jpg');
      SettingsPageErrors.logSuccess('Asset', 'QR code asset validation passed');
      return true;
    } catch (e) {
      SettingsPageErrors.logError('Asset', 'QR code asset validation failed: $e');
      return false;
    }
  }

  // Validate developer image asset existence
  static Future<bool> validateDeveloperImageAsset() async {
    try {
      await rootBundle.load('assets/images/my_image.jpg');
      SettingsPageErrors.logSuccess('Asset', 'Developer image asset validation passed');
      return true;
    } catch (e) {
      SettingsPageErrors.logError('Asset', 'Developer image asset validation failed: $e');
      return false;
    }
  }

  // Handle asset loading errors
  static Widget handleAssetError(String assetPath, dynamic error, double screenWidth) {
    SettingsPageErrors.logError('Asset', SettingsPageErrors.getAssetErrorMessage(assetPath, error));
    
    // Return fallback UI based on asset type
    if (assetPath.contains('my_image')) {
      return _buildDeveloperFallback(screenWidth);
    } else if (assetPath.contains('qr_code')) {
      return _buildQRCodeFallback(screenWidth);
    } else {
      return _buildGenericFallback();
    }
  }

  // Fallback UI builders
  static Widget _buildDeveloperFallback(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorPalette.borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(0.6),
                  blurRadius: 4,
                  offset: Offset(-2, -2),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: screenWidth * 0.12,
              color: ColorPalette.accentColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Shreeyansh Janu',
            style: TextStyle(
              color: ColorPalette.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Developer 👨‍💻',
            style: TextStyle(
              color: ColorPalette.hintTextColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildQRCodeFallback(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorPalette.borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(0.6),
                  blurRadius: 4,
                  offset: Offset(-2, -2),
                ),
              ],
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: screenWidth * 0.12,
              color: ColorPalette.accentColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Support QR Code',
            style: TextStyle(
              color: ColorPalette.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Scan to support! 💜',
            style: TextStyle(
              color: ColorPalette.hintTextColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildGenericFallback() {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: ColorPalette.hintTextColor,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(
              color: ColorPalette.hintTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Check if user can perform logout
  static bool canPerformLogout() {
    return SettingsPageErrors.validateLogoutAttempt() && validateUserSession();
  }

  // Check if user can download QR code
  static bool canDownloadQRCode() {
    return SettingsPageErrors.validateDownloadAttempt();
  }
}