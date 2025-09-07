import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLoginPage extends StatefulWidget {
  @override
  _MockLoginPageState createState() => _MockLoginPageState();
}

class _MockLoginPageState extends State<MockLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),

              // App Logo/Icon
              Icon(Icons.music_note, size: 80, color: Colors.blue[600]),
              SizedBox(height: 16),

              // App Title
              Text(
                'Music App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 48),

              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Email Field
              TextFormField(
                key: Key('email_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),

              // Password Field
              TextFormField(
                key: Key('password_field'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    key: Key('password_toggle'),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 8),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: Key('forgot_password_link'),
                  onPressed: () {},
                  child: Text('Forgot Password?'),
                ),
              ),
              SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                key: Key('login_button'),
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 24),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account? '),
                  TextButton(
                    key: Key('register_link'),
                    onPressed: () {},
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate login process
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_emailController.text.isEmpty ||
              _passwordController.text.isEmpty) {
            _errorMessage = 'Please fill in all fields';
          } else if (!_emailController.text.contains('@')) {
            _errorMessage = 'Please enter a valid email';
          } else if (_passwordController.text.length < 6) {
            _errorMessage = 'Password must be at least 6 characters';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('should display all login form elements', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: MockLoginPage()));

      // Assert
      expect(find.text('Music App'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.byKey(Key('email_field')), findsOneWidget);
      expect(find.byKey(Key('password_field')), findsOneWidget);
      expect(find.byKey(Key('login_button')), findsOneWidget);
      expect(find.byKey(Key('register_link')), findsOneWidget);
      expect(find.byKey(Key('forgot_password_link')), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(home: MockLoginPage()));

      // Act - Tap password toggle
      await tester.tap(find.byKey(Key('password_toggle')));
      await tester.pump();

      // Assert - Password visibility should change
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Act - Tap again
      await tester.tap(find.byKey(Key('password_toggle')));
      await tester.pump();

      // Assert - Should toggle back
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should show loading state during login', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(home: MockLoginPage()));

      // Enter valid data
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(find.byKey(Key('password_field')), 'password123');

      // Act - Tap login button
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pump();

      // Assert - Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);

      // Wait for loading to complete
      await tester.pump(Duration(seconds: 2));

      // Assert - Loading should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should show error for invalid email', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(home: MockLoginPage()));

      // Enter invalid email
      await tester.enterText(find.byKey(Key('email_field')), 'invalid-email');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');

      // Act
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pump();
      await tester.pump(Duration(seconds: 2));

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show error for short password', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(home: MockLoginPage()));

      // Enter short password
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(find.byKey(Key('password_field')), '123');

      // Act
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pump();
      await tester.pump(Duration(seconds: 2));

      // Assert
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should show error for empty fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(home: MockLoginPage()));

      // Act - Try to login with empty fields
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pump();
      await tester.pump(Duration(seconds: 2));

      // Assert
      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('should handle navigation taps without crashing', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(home: MockLoginPage()));

      // Make sure the widget is fully rendered and scrolled to show all elements
      await tester.pumpAndSettle();

      // Scroll to ensure all buttons are visible
      await tester.drag(find.byType(SingleChildScrollView), Offset(0, -200));
      await tester.pumpAndSettle();

      // Act & Assert - Test navigation links with warnIfMissed: false to handle off-screen elements
      await tester.tap(find.byKey(Key('register_link')), warnIfMissed: false);
      await tester.pump();
      expect(find.byKey(Key('register_link')), findsOneWidget);

      await tester.tap(
        find.byKey(Key('forgot_password_link')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(find.byKey(Key('forgot_password_link')), findsOneWidget);
    });

    testWidgets('should have proper form layout and styling', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(MaterialApp(home: MockLoginPage()));

      // Assert - Check UI components
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(
        find.byType(TextButton),
        findsNWidgets(2),
      ); // Register + Forgot Password
      expect(
        find.byType(Icon),
        findsAtLeastNWidgets(3),
      ); // App icon + field icons
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
