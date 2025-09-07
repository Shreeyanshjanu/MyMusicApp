
import 'package:client/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🚀 === APP STARTUP ===');
    print('📱 Fresh app process started');
    
    // Initialize Hive first
    print('📦 Initializing Hive...');
    await Hive.initFlutter();
    
    // Open Hive boxes
    print('📂 Opening Hive boxes...');
    await Hive.openBox('favoritesBox');
    await Hive.openBox('songsBox');
    await Hive.openBox('authBox');
    print('✅ All boxes opened');
    
    // Initialize Auth Service
    print('🔐 Initializing Auth Service...');
    await AuthService.initialize();
    
    // Debug storage status immediately
    await AuthService.debugStorage();
    
    print('✅ App initialization complete');
    runApp(const MyApp());
    
  } catch (e) {
    print('❌ Error during app initialization: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingAuth = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      print('🔍 === AUTH CHECK STARTED ===');
      
      // Ensure AuthService is initialized
      await AuthService.initialize();
      
      // Debug current state
      await AuthService.debugStorage();
      
      // Check if user is logged in
      final isLoggedIn = AuthService.isLoggedIn();
      
      print('🎯 Final login status: $isLoggedIn');
      
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isCheckingAuth = false;
      });
      
      if (isLoggedIn) {
        final user = AuthService.getCurrentUser();
        print('🎉 AUTO-LOGIN SUCCESSFUL!');
        print('👤 Welcome back: ${user?['name']}');
        print('📧 Email: ${user?['email']}');
      } else {
        print('📝 No valid authentication - user needs to login');
      }
      
    } catch (e) {
      print('❌ Auth check error: $e');
      setState(() {
        _isLoggedIn = false;
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Checking saved login...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              // Debug buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService.debugStorage();
                    },
                    child: Text('Debug'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService.forceRefreshFromStorage();
                      _checkAuthStatus();
                    },
                    child: Text('Refresh'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const HomePage() : const LoginPage();
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('App initialization failed'),
              SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}