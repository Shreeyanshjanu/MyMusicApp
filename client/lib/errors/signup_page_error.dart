import 'package:flutter/material.dart';

class SignUpPageErrors {
  // Validation methods - extracted from original
  static String? validateAllFields(String name, String email, String password) {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Please fill in all fields';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (!email.contains('@')) {
      return 'Please enter a valid email address';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null; // No errors
  }

  // Individual validation methods
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Please enter your name';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    if (!email.contains('@')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // SnackBar methods - extracted from original
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Error handling for different scenarios
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('network') || 
        error.toString().contains('connection')) {
      return 'Network error. Please check your connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  // Handle server response errors
  static String handleServerError(Map<String, dynamic> result) {
    return result['message'] ?? 'Registration failed. Please try again.';
  }
}