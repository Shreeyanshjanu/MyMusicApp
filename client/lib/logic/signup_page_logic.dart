import 'package:client/errors/signup_page_error.dart';
import 'package:flutter/material.dart';
import 'package:client/services/auth_services.dart';
import 'package:client/pages/login_page.dart';

class SignUpPageLogic {
  // Main signup handler - extracted from original _handleSignUp method
  static Future<void> handleSignUp({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
  }) async {
    // Validation - exactly as in original
    final validationError = SignUpPageErrors.validateAllFields(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    if (validationError != null) {
      SignUpPageErrors.showErrorSnackBar(context, validationError);
      return;
    }

    // Set loading state
    setLoading(true);

    try {
      // Call AuthService - exactly as in original
      final result = await AuthService.signup(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Reset loading state
      setLoading(false);

      // Handle result - exactly as in original
      if (result['success']) {
        SignUpPageErrors.showSuccessSnackBar(
          context,
          'Account created successfully! Please login with your credentials.',
        );

        // Navigate back to login page after 2 seconds - exactly as in original
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        });
      } else {
        final errorMessage = SignUpPageErrors.handleServerError(result);
        SignUpPageErrors.showErrorSnackBar(context, errorMessage);
      }
    } catch (e) {
      // Reset loading state on error
      setLoading(false);
      
      // Handle exception - exactly as in original
      final errorMessage = SignUpPageErrors.getErrorMessage(e);
      SignUpPageErrors.showErrorSnackBar(context, errorMessage);
    }
  }

  // Navigation helper
  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  // Input sanitization helper
  static Map<String, String> sanitizeInputs({
    required String name,
    required String email,
    required String password,
  }) {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'password': password, // Don't trim password
    };
  }

  // Check if form has any data
  static bool hasFormData({
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    return nameController.text.isNotEmpty ||
           emailController.text.isNotEmpty ||
           passwordController.text.isNotEmpty;
  }

  // Clear all form fields
  static void clearForm({
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }
}