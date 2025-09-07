import 'dart:ui';

import 'package:flutter/material.dart';

/// Test helper utilities for the music app
class TestHelper {
  /// Sets up common test environment
  static void setupTestEnvironment() {
    // Any common test setup can go here
  }
  
  /// Creates a test-friendly MediaQuery wrapper
  static Widget wrapWithMediaQuery(Widget child, {Size? size}) {
    return MediaQuery(
      data: MediaQueryData(
        size: size ?? Size(400, 800),
        devicePixelRatio: 1.0,
        textScaleFactor: 1.0,
        platformBrightness: Brightness.light,
      ),
      child: child,
    );
  }
}