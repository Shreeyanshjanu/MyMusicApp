
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/server_constant.dart';

class AuthService {
  // Hive box for auth storage
  static Box? _authBox;
  
  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _lastLoginKey = 'last_login_time';
  
  // In-memory cache
  static String? _authToken;
  static Map<String, dynamic>? _userData;
  static bool _isInitialized = false;
  
  // Initialize service - loads saved auth data
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('🔐 Initializing AuthService with HIVE PERSISTENT STORAGE...');
      print('📱 App process started fresh - checking for saved auth data...');
      
      // Ensure Hive is initialized
      if (!Hive.isAdapterRegistered(0)) {
        print('📦 Hive is ready');
      }
      
      // Open auth box with error handling
      try {
        _authBox = await Hive.openBox('authBox');
        print('✅ Auth box opened successfully');
      } catch (e) {
        print('❌ Error opening auth box: $e');
        // Try to recover by deleting corrupted box
        try {
          await Hive.deleteBoxFromDisk('authBox');
          _authBox = await Hive.openBox('authBox');
          print('🔧 Recovered auth box after corruption');
        } catch (e2) {
          print('❌ Failed to recover auth box: $e2');
          _isInitialized = true;
          return;
        }
      }
      
      // Check what's actually stored
      print('🔍 Checking stored data...');
      final allKeys = _authBox?.keys.toList() ?? [];
      print('📋 Auth box keys: $allKeys');
      
      // Load saved token and user data
      _authToken = _authBox?.get(_tokenKey);
      final userDataStored = _authBox?.get(_userDataKey);
      final lastLoginTime = _authBox?.get(_lastLoginKey);
      
      print('🔑 Raw stored token: ${_authToken ?? 'null'}');
      print('👤 Raw stored user data: ${userDataStored ?? 'null'}');
      print('⏰ Last login time: ${lastLoginTime ?? 'null'}');
      
      if (userDataStored != null) {
        try {
          if (userDataStored is Map) {
            _userData = Map<String, dynamic>.from(userDataStored);
          } else {
            _userData = Map<String, dynamic>.from(jsonDecode(userDataStored.toString()));
          }
          print('✅ User data parsed successfully: $_userData');
        } catch (e) {
          print('❌ Error parsing saved user data: $e');
          // Clear corrupted data
          await _authBox?.delete(_userDataKey);
          _userData = null;
        }
      }
      
      _isInitialized = true;
      
      if (_authToken != null && _authToken!.isNotEmpty) {
        print('🎉 FOUND SAVED AUTHENTICATION!');
        print('👤 Auto-logging in as: ${_userData?['name'] ?? 'Unknown User'}');
        print('📧 Email: ${_userData?['email'] ?? 'Unknown Email'}');
        print('🔑 Token preview: ${_authToken!.length > 20 ? _authToken!.substring(0, 20) + '...' : _authToken}');
        
        // Check if token is still valid (optional)
        if (lastLoginTime != null) {
          final loginTime = DateTime.tryParse(lastLoginTime.toString());
          if (loginTime != null) {
            final daysSinceLogin = DateTime.now().difference(loginTime).inDays;
            print('📅 Last login: $daysSinceLogin days ago');
            
            // Optional: invalidate very old tokens (e.g., 30 days)
            if (daysSinceLogin > 30) {
              print('⚠️ Token is very old, might need refresh');
            }
          }
        }
      } else {
        print('📝 No saved authentication found - user needs to login');
      }
      
    } catch (e) {
      print('❌ AuthService initialization error: $e');
      print('🔧 Continuing with fallback initialization...');
      _isInitialized = true; // Continue anyway
    }
  }
  
  // Save auth data persistently with enhanced logging
  static Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    try {
      print('💾 Saving auth data to persistent storage...');
      
      _authToken = token;
      _userData = userData;
      
      // Save to Hive with current timestamp
      final currentTime = DateTime.now().toIso8601String();
      
      await _authBox?.put(_tokenKey, token);
      await _authBox?.put(_userDataKey, userData);
      await _authBox?.put(_lastLoginKey, currentTime);
      
      // Verify the save was successful
      final savedToken = _authBox?.get(_tokenKey);
      final savedUser = _authBox?.get(_userDataKey);
      final savedTime = _authBox?.get(_lastLoginKey);
      
      print('✅ Auth data saved to HIVE PERSISTENT STORAGE');
      print('👤 User: ${userData['name']} (ID: ${userData['id']})');
      print('📧 Email: ${userData['email']}');
      print('🔑 Token preview: ${token.length > 20 ? token.substring(0, 20) + '...' : token}');
      print('⏰ Save time: $currentTime');
      
      // Verify save
      if (savedToken == token && savedUser != null && savedTime == currentTime) {
        print('✅ VERIFICATION: Data successfully persisted');
      } else {
        print('⚠️ VERIFICATION: Data might not be properly saved');
        print('   Saved token matches: ${savedToken == token}');
        print('   Saved user exists: ${savedUser != null}');
        print('   Saved time matches: ${savedTime == currentTime}');
      }
      
    } catch (e) {
      print('❌ Error saving auth data: $e');
      // Try alternative save method
      try {
        print('🔧 Attempting alternative save method...');
        await _authBox?.clear();
        await _authBox?.put(_tokenKey, token);
        await _authBox?.put(_userDataKey, userData);
        print('✅ Alternative save successful');
      } catch (e2) {
        print('❌ Alternative save also failed: $e2');
      }
    }
  }
  
  // Enhanced debug method
  static Future<void> debugStorage() async {
    try {
      print('🔍 === AUTH STORAGE DEBUG ===');
      print('🏠 Hive directory: ${Hive.isBoxOpen('authBox') ? 'Box is open' : 'Box is closed'}');
      
      final token = _authBox?.get(_tokenKey);
      final userData = _authBox?.get(_userDataKey);
      final lastLogin = _authBox?.get(_lastLoginKey);
      final allKeys = _authBox?.keys.toList() ?? [];
      
      print('📋 All stored keys: $allKeys');
      print('🔑 Stored token: ${token?.toString().substring(0, 20) ?? 'null'}...');
      print('👤 Stored user: ${userData ?? 'null'}');
      print('⏰ Last login: ${lastLogin ?? 'null'}');
      print('💭 In-memory token: ${_authToken?.substring(0, 20) ?? 'null'}...');
      print('💭 In-memory user: $_userData');
      print('✅ Is initialized: $_isInitialized');
      print('🔓 Is logged in: ${isLoggedIn()}');
      print('=== END DEBUG ===');
      
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }
  
  // Force refresh from storage (for testing)
  static Future<void> forceRefreshFromStorage() async {
    try {
      print('🔄 Force refreshing from storage...');
      
      _authToken = null;
      _userData = null;
      _isInitialized = false;
      
      await initialize();
      
    } catch (e) {
      print('❌ Force refresh error: $e');
    }
  }
  
  // Get auth headers for API calls
  static Map<String, String> getAuthHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      if (_authToken != null && _authToken!.isNotEmpty) 'x-auth-token': _authToken!,
    };
    return headers;
  }
  
  // Check if user is logged in
  static bool isLoggedIn() {
    final loggedIn = _authToken != null && _authToken!.isNotEmpty;
    return loggedIn;
  }
  
  // Get current user data
  static Map<String, dynamic>? getCurrentUser() {
    return _userData;
  }
  
  // Get auth token
  static String? getAuthToken() {
    return _authToken;
  }
  
  // Logout - clear all stored data
  static Future<void> logout() async {
    try {
      print('🚪 Logging out user: ${_userData?['name']}');
      
      _authToken = null;
      _userData = null;
      
      // Clear Hive storage
      await _authBox?.delete(_tokenKey);
      await _authBox?.delete(_userDataKey);
      await _authBox?.delete(_lastLoginKey);
      
      // Verify logout
      final tokenAfterLogout = _authBox?.get(_tokenKey);
      final userAfterLogout = _authBox?.get(_userDataKey);
      
      print('✅ User logged out - all data cleared from persistent storage');
      print('🔍 Verification - Token after logout: ${tokenAfterLogout ?? 'null'}');
      print('🔍 Verification - User after logout: ${userAfterLogout ?? 'null'}');
      
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  // Signup method
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting signup with: $name, $email');
      
      final response = await http.post(
        Uri.parse('${ServerConstant.serverURL}${ServerConstant.signupEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: 15));

      print('📡 Signup response status: ${response.statusCode}');
      print('📡 Signup response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'User created successfully',
          'data': responseData,
        };
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      print('❌ Signup error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Enhanced login method
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login with: $email');
      
      final response = await http.post(
        Uri.parse('${ServerConstant.serverURL}${ServerConstant.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: 15));

      print('📡 Login response status: ${response.statusCode}');
      print('📡 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Save auth data persistently
        await _saveAuthData(responseData['token'], responseData['user']);
        
        return {
          'success': true,
          'message': 'Login successful',
          'token': responseData['token'],
          'user': responseData['user'],
        };
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}