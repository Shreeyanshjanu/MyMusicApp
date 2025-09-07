import 'package:client/colors/color_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/settings_page_logic.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Settings Title
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryTextColor,
                ),
              ),
              SizedBox(height: screenWidth * 0.06),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // User Info Card (if logged in)
                      if (SettingsPageLogic.getCurrentUserInfo() != null) ...[
                        _buildUserInfoCard(context, screenWidth),
                        SizedBox(height: screenWidth * 0.04),
                      ],

                      // Settings Container - Login Page Style
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        decoration: BoxDecoration(
                          color: ColorPalette.backgroundColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: ColorPalette.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.darkShadowColor.withOpacity(
                                ColorPalette.darkShadowOpacity,
                              ),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: Offset(8, 8),
                            ),
                            BoxShadow(
                              color: ColorPalette.lightShadowColor.withOpacity(
                                ColorPalette.lightShadowOpacity,
                              ),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: Offset(-8, -8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Logout Button
                            _buildCompactSettingsItem(
                              context: context,
                              screenWidth: screenWidth,
                              icon: Icons.logout,
                              title: 'Logout',
                              iconColor: ColorPalette.romanticColor,
                              onTap: () => _showLogoutDialog(context),
                            ),

                            SizedBox(height: screenWidth * 0.04),

                            // Notifications Button
                            _buildCompactSettingsItem(
                              context: context,
                              screenWidth: screenWidth,
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              onTap: () => _showComingSoonDialog(
                                context,
                                'Notifications',
                              ),
                              enabled: false,
                            ),

                            SizedBox(height: screenWidth * 0.04),

                            // About Button
                            _buildCompactSettingsItem(
                              context: context,
                              screenWidth: screenWidth,
                              icon: Icons.info_outline,
                              title: 'About',
                              onTap: () => _showAboutDialog(context),
                            ),

                            SizedBox(height: screenWidth * 0.04),

                            // Support Developer Button
                            _buildCompactSettingsItem(
                              context: context,
                              screenWidth: screenWidth,
                              icon: Icons.favorite,
                              title: 'Support Developer',
                              iconColor: ColorPalette.romanticColor,
                              onTap: () =>
                                  _showSupportDialog(context, screenWidth),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenWidth * 0.08),

                      // App Version at bottom
                      Text(
                        SettingsPageLogic.getAppVersion(),
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: ColorPalette.hintTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, double screenWidth) {
    final user = SettingsPageLogic.getCurrentUserInfo()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: ColorPalette.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorPalette.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(
              ColorPalette.darkShadowOpacity,
            ),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(6, 6),
          ),
          BoxShadow(
            color: ColorPalette.lightShadowColor.withOpacity(
              ColorPalette.lightShadowOpacity,
            ),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(-6, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: ColorPalette.cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: ColorPalette.borderColor, width: 1),
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
              color: ColorPalette.accentColor,
              size: screenWidth * 0.06,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Unknown User',
                  style: TextStyle(
                    fontSize: screenWidth * 0.042,
                    fontWeight: FontWeight.w600,
                    color: ColorPalette.primaryTextColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  user['email'] ?? 'No email',
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: ColorPalette.hintTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSettingsItem({
    required BuildContext context,
    required double screenWidth,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool enabled = true,
  }) {
    return Container(
      width: double.infinity,
      height: screenWidth * 0.12,
      decoration: BoxDecoration(
        color: ColorPalette.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.borderColor, width: 1),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? () {
            SettingsPageLogic.handleSettingsItemTap(title, onTap: onTap);
          } : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Row(
              children: [
                // Icon
                Icon(
                  icon,
                  color: enabled
                      ? (iconColor ?? ColorPalette.accentColor)
                      : ColorPalette.hintTextColor.withOpacity(0.5),
                  size: screenWidth * 0.055,
                ),
                SizedBox(width: screenWidth * 0.04),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: enabled
                          ? ColorPalette.primaryTextColor
                          : ColorPalette.hintTextColor.withOpacity(0.5),
                    ),
                  ),
                ),

                // Arrow or lock icon
                Icon(
                  enabled ? Icons.chevron_right : Icons.lock_outline,
                  color: enabled
                      ? ColorPalette.hintTextColor
                      : ColorPalette.hintTextColor.withOpacity(0.5),
                  size: screenWidth * 0.045,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    print('🚪 Logout dialog opened');

    showDialog(
      context: context,
      barrierColor: ColorPalette.darkShadowColor.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth * 0.85,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ColorPalette.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(
                    ColorPalette.darkShadowOpacity,
                  ),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(8, 8),
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(
                    ColorPalette.lightShadowOpacity,
                  ),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(-8, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Logout Icon
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorPalette.cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorPalette.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.darkShadowColor.withOpacity(
                                ColorPalette.darkShadowOpacity,
                              ),
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                            BoxShadow(
                              color: ColorPalette.lightShadowColor.withOpacity(
                                ColorPalette.lightShadowOpacity,
                              ),
                              blurRadius: 8,
                              offset: Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.logout,
                          color: ColorPalette.romanticColor,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: ColorPalette.primaryTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8),

                // Message Container
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: ColorPalette.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorPalette.borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.darkShadowColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(3, 3),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(0.5),
                        blurRadius: 6,
                        offset: Offset(-3, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(
                          color: ColorPalette.primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You will need to login again to access your music.',
                        style: TextStyle(
                          color: ColorPalette.hintTextColor,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: ColorPalette.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColorPalette.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.darkShadowColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                            BoxShadow(
                              color: ColorPalette.lightShadowColor.withOpacity(0.6),
                              blurRadius: 8,
                              offset: Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            print('❌ Logout cancelled');
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: ColorPalette.hintTextColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // Logout Button
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: ColorPalette.romanticColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColorPalette.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.darkShadowColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                            BoxShadow(
                              color: ColorPalette.lightShadowColor.withOpacity(0.6),
                              blurRadius: 8,
                              offset: Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            print('🚪 Logout confirmed');
                            Navigator.of(context).pop(); // Close dialog
                            await SettingsPageLogic.handleLogout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: ColorPalette.lightShadowColor,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                size: 16,
                                color: ColorPalette.lightShadowColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: ColorPalette.lightShadowColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    SettingsPageLogic.handleComingSoonFeature(context, feature);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorPalette.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.construction, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Coming Soon',
                style: TextStyle(color: ColorPalette.primaryTextColor),
              ),
            ],
          ),
          content: Text(
            '$feature feature is coming in a future update!',
            style: TextStyle(color: ColorPalette.primaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: ColorPalette.accentColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    print('ℹ️ About Dialog opened');

    showDialog(
      context: context,
      barrierColor: ColorPalette.darkShadowColor.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth * 0.85,
            height: screenHeight * 0.85,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ColorPalette.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(
                    ColorPalette.darkShadowOpacity,
                  ),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(8, 8),
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(
                    ColorPalette.lightShadowOpacity,
                  ),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(-8, -8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Developer Image Container
                  Container(
                    width: screenWidth * 0.55,
                    height: screenWidth * 0.55,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorPalette.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ColorPalette.borderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorPalette.darkShadowColor.withOpacity(
                            ColorPalette.darkShadowOpacity,
                          ),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: Offset(8, 8),
                        ),
                        BoxShadow(
                          color: ColorPalette.lightShadowColor.withOpacity(
                            ColorPalette.lightShadowOpacity,
                          ),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: Offset(-8, -8),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ColorPalette.borderColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorPalette.darkShadowColor.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                          BoxShadow(
                            color: ColorPalette.lightShadowColor.withOpacity(0.8),
                            blurRadius: 4,
                            offset: Offset(-2, -2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/my_image.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                                if (frame == null) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: ColorPalette.cardColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: CircularProgressIndicator(
                                            color: ColorPalette.accentColor,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Loading...',
                                          style: TextStyle(
                                            color: ColorPalette.hintTextColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                print('✅ Developer image loaded successfully!');
                                return child;
                              },
                          errorBuilder: (context, error, stackTrace) {
                            return SettingsPageLogic.handleAssetError(
                              'assets/images/my_image.jpg', 
                              error, 
                              screenWidth
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // About Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorPalette.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ColorPalette.borderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorPalette.darkShadowColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(3, 3),
                        ),
                        BoxShadow(
                          color: ColorPalette.lightShadowColor.withOpacity(0.5),
                          blurRadius: 6,
                          offset: Offset(-3, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // About Heading
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info,
                              color: ColorPalette.accentColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'About',
                              style: TextStyle(
                                color: ColorPalette.primaryTextColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // App Details
                        Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              color: ColorPalette.accentColor,
                              size: 18,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Music Streaming App',
                              style: TextStyle(
                                color: ColorPalette.primaryTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: ColorPalette.accentColor,
                              size: 18,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                color: ColorPalette.hintTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: ColorPalette.accentColor,
                              size: 18,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Shreeyansh Janu',
                              style: TextStyle(
                                color: ColorPalette.primaryTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              color: ColorPalette.accentColor,
                              size: 18,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'arthurmorgan5984@gmail.com',
                                style: TextStyle(
                                  color: ColorPalette.hintTextColor,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Divider
                        Container(
                          height: 1,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                ColorPalette.borderColor,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 12),

                        // Description
                        Text(
                          "A full-stack music streaming application built with Flutter (frontend), FastAPI (backend), and PostgreSQL (database). "
                          "It features YouTube integration, a modern neumorphic UI design, and simple functionality—just copy a link, paste it, and save the video instantly.\n\n"
                          "I'm open to collaboration and contributions. "
                          "If you'd like to work together, feel free to reach out via email.",
                          style: TextStyle(
                            color: ColorPalette.hintTextColor,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Close Button
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: ColorPalette.accentColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorPalette.borderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorPalette.darkShadowColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(4, 4),
                        ),
                        BoxShadow(
                          color: ColorPalette.lightShadowColor.withOpacity(0.6),
                          blurRadius: 8,
                          offset: Offset(-4, -4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print('✅ About dialog closed');
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: ColorPalette.lightShadowColor,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check,
                            size: 16,
                            color: ColorPalette.lightShadowColor,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Got it!',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: ColorPalette.lightShadowColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSupportDialog(BuildContext context, double screenWidth) {
    print('🎯 Support Developer dialog opened');

    showDialog(
      context: context,
      barrierColor: ColorPalette.darkShadowColor.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth * 0.85,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ColorPalette.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(
                    ColorPalette.darkShadowOpacity,
                  ),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(8, 8),
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(
                    ColorPalette.lightShadowOpacity,
                  ),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(-8, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Heart Icon
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColorPalette.cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorPalette.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.darkShadowColor.withOpacity(
                                ColorPalette.darkShadowOpacity,
                              ),
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                            BoxShadow(
                              color: ColorPalette.lightShadowColor.withOpacity(
                                ColorPalette.lightShadowOpacity,
                              ),
                              blurRadius: 8,
                              offset: Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: ColorPalette.romanticColor,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Support Developer',
                        style: TextStyle(
                          color: ColorPalette.primaryTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8),

                // Description Text
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: ColorPalette.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorPalette.borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.darkShadowColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(3, 3),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(0.5),
                        blurRadius: 6,
                        offset: Offset(-3, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Love using this app? ❤️',
                        style: TextStyle(
                          color: ColorPalette.primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your support helps me create amazing features and keep this app free!',
                        style: TextStyle(
                          color: ColorPalette.hintTextColor,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // QR Code Container with Download Button
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: screenWidth * 0.55,
                      height: screenWidth * 0.55,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorPalette.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorPalette.borderColor,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorPalette.darkShadowColor.withOpacity(
                              ColorPalette.darkShadowOpacity,
                            ),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: Offset(8, 8),
                          ),
                          BoxShadow(
                            color: ColorPalette.lightShadowColor.withOpacity(
                              ColorPalette.lightShadowOpacity,
                            ),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: Offset(-8, -8),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorPalette.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ColorPalette.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.darkShadowColor.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                            BoxShadow(
                              color: ColorPalette.lightShadowColor.withOpacity(0.8),
                              blurRadius: 4,
                              offset: Offset(-2, -2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/images/qr_code.jpg',
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            frameBuilder:
                                (context, child, frame, wasSynchronouslyLoaded) {
                                  if (frame == null) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: ColorPalette.cardColor,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(
                                              color: ColorPalette.accentColor,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Loading...',
                                            style: TextStyle(
                                              color: ColorPalette.hintTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  print('✅ QR Code loaded successfully!');
                                  return child;
                                },
                            errorBuilder: (context, error, stackTrace) {
                              return SettingsPageLogic.handleAssetError(
                                'assets/images/qr_code.jpg',
                                error,
                                screenWidth
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Download Button - Positioned at top-right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ColorPalette.backgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorPalette.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.darkShadowColor.withOpacity(0.4),
                              blurRadius: 6,
                              offset: Offset(3, 3),
                            ),
                            BoxShadow(
                              color: ColorPalette.lightShadowColor.withOpacity(0.6),
                              blurRadius: 6,
                              offset: Offset(-3, -3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => SettingsPageLogic.downloadQRCode(context),
                          icon: Icon(
                            Icons.file_download_outlined,
                            color: ColorPalette.accentColor,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          style: IconButton.styleFrom(shape: CircleBorder()),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Download hint text
                Text(
                  'Tap download button to save QR code 📱',
                  style: TextStyle(
                    color: ColorPalette.hintTextColor,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20),

                // Coffee Message
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: ColorPalette.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorPalette.borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorPalette.darkShadowColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(3, 3),
                      ),
                      BoxShadow(
                        color: ColorPalette.lightShadowColor.withOpacity(0.5),
                        blurRadius: 6,
                        offset: Offset(-3, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.coffee,
                        color: ColorPalette.warningColor,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Buy me a coffee!',
                        style: TextStyle(
                          color: ColorPalette.primaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Buttons Row - Neumorphism Style
                Row(
                  children: [
                    // Maybe Later Button
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: ColorPalette.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColorPalette.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.darkShadowColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                            BoxShadow(
                              color: ColorPalette.lightShadowColor.withOpacity(0.6),
                              blurRadius: 8,
                              offset: Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            SettingsPageLogic.handleMaybeLaterInteraction(context);
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Maybe Later',
                            style: TextStyle(
                              color: ColorPalette.hintTextColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // Support Button
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: ColorPalette.accentColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColorPalette.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.darkShadowColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                            BoxShadow(
                              color: ColorPalette.lightShadowColor.withOpacity(0.6),
                              blurRadius: 8,
                              offset: Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            SettingsPageLogic.handleSupportInteraction(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: ColorPalette.lightShadowColor,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 16,
                                color: ColorPalette.lightShadowColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Support',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: ColorPalette.lightShadowColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

