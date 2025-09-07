import 'package:flutter_test/flutter_test.dart';

// Mock AuthService that mirrors your actual auth logic
class MockAuthService {
  bool _isLoggedIn = false;
  String? _token;
  Map<String, String> _users = {
    'test@example.com': 'password123',
    'user@gmail.com': 'mypassword',
    'admin@musicapp.com': 'admin123',
  };
  
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 100));
    
    if (!validateEmail(email)) {
      return {'success': false, 'error': 'Invalid email format'};
    }
    
    if (!validatePassword(password)) {
      return {'success': false, 'error': 'Password must be at least 6 characters'};
    }
    
    if (_users[email] == password) {
      _isLoggedIn = true;
      _token = 'token_${DateTime.now().millisecondsSinceEpoch}';
      return {'success': true, 'token': _token, 'user': email};
    }
    
    return {'success': false, 'error': 'Invalid credentials'};
  }
  
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 50));
    _isLoggedIn = false;
    _token = null;
  }
  
  Future<Map<String, dynamic>> register(String email, String password, String confirmPassword) async {
    await Future.delayed(Duration(milliseconds: 150));
    
    if (!validateEmail(email)) {
      return {'success': false, 'error': 'Invalid email format'};
    }
    
    if (!validatePassword(password)) {
      return {'success': false, 'error': 'Password must be at least 6 characters'};
    }
    
    if (password != confirmPassword) {
      return {'success': false, 'error': 'Passwords do not match'};
    }
    
    if (_users.containsKey(email)) {
      return {'success': false, 'error': 'Email already registered'};
    }
    
    _users[email] = password;
    return {'success': true, 'message': 'Registration successful'};
  }
  
  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  bool validatePassword(String password) {
    return password.length >= 6;
  }
  
  Future<bool> checkAuthStatus() async {
    await Future.delayed(Duration(milliseconds: 50));
    return _isLoggedIn && _token != null;
  }
  
  Future<void> resetPassword(String email) async {
    await Future.delayed(Duration(milliseconds: 200));
    // Mock password reset logic
  }
}

void main() {
  group('AuthService Tests', () {
    late MockAuthService authService;
    
    setUp(() {
      authService = MockAuthService();
    });
    
    test('should validate email correctly', () {
      // Valid emails
      expect(authService.validateEmail('test@example.com'), isTrue);
      expect(authService.validateEmail('user.name@gmail.com'), isTrue);
      expect(authService.validateEmail('admin@musicapp.co.uk'), isTrue);
      
      // Invalid emails
      expect(authService.validateEmail('invalid-email'), isFalse);
      expect(authService.validateEmail('test@'), isFalse);
      expect(authService.validateEmail('@example.com'), isFalse);
      expect(authService.validateEmail('test.example.com'), isFalse);
      expect(authService.validateEmail(''), isFalse);
    });
    
    test('should validate password correctly', () {
      // Valid passwords
      expect(authService.validatePassword('123456'), isTrue);
      expect(authService.validatePassword('password123'), isTrue);
      expect(authService.validatePassword('StrongPass!@#'), isTrue);
      
      // Invalid passwords
      expect(authService.validatePassword('12345'), isFalse);
      expect(authService.validatePassword('short'), isFalse);
      expect(authService.validatePassword(''), isFalse);
    });
    
    test('should login successfully with valid credentials', () async {
      // Act
      final result = await authService.login('test@example.com', 'password123');
      
      // Assert
      expect(result['success'], isTrue);
      expect(result['token'], isNotNull);
      expect(result['user'], equals('test@example.com'));
      expect(authService.isLoggedIn, isTrue);
      expect(authService.token, isNotNull);
    });
    
    test('should fail login with invalid email format', () async {
      // Act
      final result = await authService.login('invalid-email', 'password123');
      
      // Assert
      expect(result['success'], isFalse);
      expect(result['error'], equals('Invalid email format'));
      expect(authService.isLoggedIn, isFalse);
    });
    
    test('should fail login with short password', () async {
      // Act
      final result = await authService.login('test@example.com', '123');
      
      // Assert
      expect(result['success'], isFalse);
      expect(result['error'], equals('Password must be at least 6 characters'));
      expect(authService.isLoggedIn, isFalse);
    });
    
    test('should fail login with wrong credentials', () async {
      // Act
      final result = await authService.login('test@example.com', 'wrongpassword');
      
      // Assert
      expect(result['success'], isFalse);
      expect(result['error'], equals('Invalid credentials'));
      expect(authService.isLoggedIn, isFalse);
    });
    
    test('should logout successfully', () async {
      // Arrange - Login first
      await authService.login('test@example.com', 'password123');
      expect(authService.isLoggedIn, isTrue);
      
      // Act
      await authService.logout();
      
      // Assert
      expect(authService.isLoggedIn, isFalse);
      expect(authService.token, isNull);
    });
    
    test('should register new user successfully', () async {
      // Act
      final result = await authService.register('newuser@example.com', 'newpassword', 'newpassword');
      
      // Assert
      expect(result['success'], isTrue);
      expect(result['message'], equals('Registration successful'));
    });
    
    test('should fail registration with mismatched passwords', () async {
      // Act
      final result = await authService.register('newuser@example.com', 'password1', 'password2');
      
      // Assert
      expect(result['success'], isFalse);
      expect(result['error'], equals('Passwords do not match'));
    });
    
    test('should fail registration with existing email', () async {
      // Act
      final result = await authService.register('test@example.com', 'newpassword', 'newpassword');
      
      // Assert
      expect(result['success'], isFalse);
      expect(result['error'], equals('Email already registered'));
    });
    
    test('should check auth status correctly', () async {
      // Test when not logged in
      expect(await authService.checkAuthStatus(), isFalse);
      
      // Login and test
      await authService.login('test@example.com', 'password123');
      expect(await authService.checkAuthStatus(), isTrue);
      
      // Logout and test
      await authService.logout();
      expect(await authService.checkAuthStatus(), isFalse);
    });
  });
}