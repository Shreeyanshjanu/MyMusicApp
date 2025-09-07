import 'package:flutter/material.dart';

class ColorPalette {
  // Primary background color
  static const Color backgroundColor = Color.fromARGB(255, 226, 227, 237);
  
  // Text colors
  static const Color primaryTextColor = Color(0xFF6B7280);
  static const Color hintTextColor = Color(0xFF9CA3AF);
  
  // Shadow colors
  static const Color darkShadowColor = Color.fromARGB(255, 188, 190, 195);
  static const Color lightShadowColor = Colors.white;
  
  // Shadow opacity values
  static const double darkShadowOpacity = 0.5;
  static const double lightShadowOpacity = 0.7;
  static const double hintTextOpacity = 0.8;
  
  // Additional colors for the music app
  static const Color cardColor = Color.fromARGB(255, 240, 241, 248); // Slightly lighter than background
  static const Color secondaryTextColor = Color(0xFF9CA3AF); // Same as hintTextColor for consistency
  static const Color accentColor = Color(0xFF6366F1); // Indigo accent for buttons and highlights
  static const Color inactiveColor = Color.fromARGB(255, 200, 202, 210); // For disabled elements
  static const Color borderColor = Color.fromARGB(255, 210, 212, 220); // For borders and dividers
  
  // Special colors
  static const Color romanticColor = Colors.red; // Only for romantic heart icon
  static const Color successColor = Color(0xFF10B981); // For success messages
  static const Color warningColor = Color(0xFFF59E0B); // For warnings
}