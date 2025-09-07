import 'package:client/errors/login_page_error.dart';
import 'package:flutter/material.dart';
import 'package:client/services/auth_services.dart';
import 'package:client/pages/home_page.dart';
import 'package:client/pages/signup_page.dart';
import 'package:client/pages/transition_page.dart';

class LoginPageLogic {
  // Main login handler - extracted from original _handleLogin method
  static Future<void> handleLogin({
    required BuildContext context,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
  }) async {
    // Validation - exactly as in original
    final validationError = LoginPageErrors.validateAllFields(
      emailController.text,
      passwordController.text,
    );

    if (validationError != null) {
      LoginPageErrors.showErrorSnackBar(context, validationError);
      return;
    }

    // Set loading state
    setLoading(true);

    try {
      // Call AuthService - exactly as in original
      final result = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Reset loading state
      setLoading(false);

      // Handle result - exactly as in original
      if (result['success'] == true) {
        LoginPageErrors.showSuccessSnackBar(context, 'Login successful! Welcome back!');

        // Navigate to transition page - exactly as in original
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TransitionPage(
                  durationInSeconds: 3, // 3 seconds as in your original code
                  destinationPage: const HomePage(),
                  title: "Welcome Back!",
                  description: "Setting up your music experience. Please wait a moment.",
                ),
              ),
            );
          }
        });
      } else {
        final errorMessage = LoginPageErrors.handleServerError(result);
        LoginPageErrors.showErrorSnackBar(context, errorMessage);
      }
    } catch (e) {
      // Reset loading state on error
      setLoading(false);
      
      // Handle exception - exactly as in original
      final errorMessage = LoginPageErrors.getErrorMessage(e);
      LoginPageErrors.showErrorSnackBar(context, errorMessage);
      print('Login exception: $e');
    }
  }

  // Navigation helper to signup page
  static void navigateToSignUp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      ),
    );
  }

  // Navigation helper to home page (direct)
  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  // Navigation helper with transition page
  static void navigateToHomeWithTransition(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransitionPage(
          durationInSeconds: 3,
          destinationPage: const HomePage(),
          title: "Welcome Back!",
          description: "Setting up your music experience. Please wait a moment.",
        ),
      ),
    );
  }

  // Input sanitization helper
  static Map<String, String> sanitizeInputs({
    required String email,
    required String password,
  }) {
    return {
      'email': email.trim().toLowerCase(),
      'password': password, // Don't trim password
    };
  }

  // Check if form has any data
  static bool hasFormData({
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    return emailController.text.isNotEmpty ||
           passwordController.text.isNotEmpty;
  }

  // Clear all form fields
  static void clearForm({
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    emailController.clear();
    passwordController.clear();
  }

  // Validate credentials before attempting login
  static bool validateCredentials({
    required String email,
    required String password,
  }) {
    return LoginPageErrors.hasValidCredentials(email, password);
  }

  // Quick validation check
  static bool isFormValid({
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) {
    return LoginPageErrors.validateAllFields(
      emailController.text,
      passwordController.text,
    ) == null;
  }

  // Auto-login check (for app startup)
  static Future<bool> checkAutoLogin() async {
    try {
      // Check if user is already logged in
      await AuthService.initialize();
      return AuthService.isLoggedIn();
    } catch (e) {
      print('Auto-login check failed: $e');
      return false;
    }
  }

  // Handle remember me functionality (if needed in future)
  static Future<void> saveCredentials({
    required String email,
    String? password,
  }) async {
    // This could be implemented if you want to add "Remember Me" functionality
    // For now, it's just a placeholder
    print('Credentials save requested for: $email');
  }

  // Debug method to test form validation
  static void debugValidation({
    required String email,
    required String password,
  }) {
    print('🔍 === LOGIN VALIDATION DEBUG ===');
    print('Input email: "$email"');
    print('Input password length: ${password.length}');
    
    final sanitized = sanitizeInputs(email: email, password: password);
    print('Sanitized email: "${sanitized['email']}"');
    
    final emailError = LoginPageErrors.validateEmail(sanitized['email']!);
    final passwordError = LoginPageErrors.validatePassword(sanitized['password']!);
    
    print('Email validation: ${emailError ?? 'PASS'}');
    print('Password validation: ${passwordError ?? 'PASS'}');
    print('=== END DEBUG ===');
  }
}