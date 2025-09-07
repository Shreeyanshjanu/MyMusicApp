import 'package:flutter/material.dart';

class LoginPageErrors {
  // Validation methods - extracted from original
  static String? validateAllFields(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill in all fields';
    }

    if (!email.contains('@')) {
      return 'Please enter a valid email address';
    }

    return null; // No errors
  }

  // Individual validation methods
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
    return null;
  }

  // SnackBar methods - extracted from original
  static void showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Error handling for different scenarios
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('network') || 
        error.toString().contains('connection')) {
      return 'Network error. Please check your connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (error.toString().contains('401') || 
               error.toString().contains('unauthorized')) {
      return 'Invalid email or password. Please try again.';
    } else if (error.toString().contains('403') || 
               error.toString().contains('forbidden')) {
      return 'Access denied. Please check your credentials.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  // Handle server response errors
  static String handleServerError(Map<String, dynamic> result) {
    return result['message'] ?? 'Login failed';
  }

  // Additional validation helpers
  static bool isValidEmail(String email) {
    return email.isNotEmpty && email.contains('@');
  }

  static bool isValidPassword(String password) {
    return password.isNotEmpty;
  }

  static bool hasValidCredentials(String email, String password) {
    return isValidEmail(email) && isValidPassword(password);
  }

  // Enhanced email validation (optional)
  static String? validateEmailFormat(String email) {
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    
    if (!email.contains('@')) {
      return 'Please enter a valid email address';
    }
    
    // More comprehensive email validation if needed
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email format';
    }
    
    return null;
  }

  // Log validation for debugging
  static void logValidation(String field, String value, String? error) {
    if (error != null) {
      print('❌ Login validation failed for $field: $error');
    } else {
      print('✅ Login validation passed for $field');
    }
  }
}