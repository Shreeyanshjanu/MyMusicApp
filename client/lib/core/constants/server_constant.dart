class ServerConstant {
  // Different server URLs for different environments
  static const String _localhost = 'http://localhost:8000';
  static const String _emulator = 'http://10.0.2.2:8000';
  static const String _physicalDevice = 'http://192.168.1.XXX:8000'; // Replace XXX with your IP
  static const String _production = 'https://your-production-server.com';
  
  // Current server URL - change this based on your testing environment
  static const String serverURL = _emulator; // Change this line only
  
  // API endpoints
  static const String authEndpoint = '/auth';
  static const String signupEndpoint = '$authEndpoint/signup';
  static const String loginEndpoint = '$authEndpoint/login';
  
  // Songs endpoints
  static const String songsEndpoint = '/songs';
  
  // Future endpoints you might add
  static const String userEndpoint = '/user';
  static const String musicEndpoint = '/music';
  static const String playlistEndpoint = '/playlist';
  
  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$serverURL$endpoint';
  }
}