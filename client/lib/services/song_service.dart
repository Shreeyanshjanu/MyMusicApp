// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../core/constants/server_constant.dart';
// import '../models/song_model.dart';

// class SongService {
//   static const String baseUrl = ServerConstant.serverURL;

//   // Get all songs
//   Future<List<Song>> getAllSongs() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/songs/'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => Song.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load songs: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching songs: $e');
//     }
//   }

//   // Get songs by genre
//   Future<List<Song>> getSongsByGenre(String genre) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/songs/$genre'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => Song.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load songs for genre $genre: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching songs by genre: $e');
//     }
//   }

//   // Create a new song
//   Future<Song> createSong(Map<String, dynamic> songData) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/songs/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(songData),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         return Song.fromJson(data);
//       } else {
//         throw Exception('Failed to create song: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error creating song: $e');
//     }
//   }

//   // Delete a song
//   Future<void> deleteSong(int songId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/songs/$songId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode != 200 && response.statusCode != 204) {
//         throw Exception('Failed to delete song: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error deleting song: $e');
//     }
//   }

//   // Update a song
//   Future<Song> updateSong(int songId, Map<String, dynamic> songData) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/songs/$songId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(songData),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return Song.fromJson(data);
//       } else {
//         throw Exception('Failed to update song: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error updating song: $e');
//     }
//   }

//   // Get a specific song by ID
//   Future<Song> getSongById(int songId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/songs/$songId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return Song.fromJson(data);
//       } else {
//         throw Exception('Failed to load song: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching song: $e');
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/server_constant.dart';
import '../models/song_model.dart';
import 'auth_services.dart';

class SongService {
  static const String baseUrl = ServerConstant.serverURL;

  // Get all songs WITH proper auth
  Future<List<Song>> getAllSongs() async {
    try {
      print('🎵 Fetching all songs from server...');
      
      final headers = AuthService.getAuthHeaders();
      print('🔑 Using auth headers: ${headers.keys.toList()}');
      
      final response = await http.get(
        Uri.parse('$baseUrl/songs/'),
        headers: headers,
      ).timeout(Duration(seconds: 15));

      print('📡 Songs response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final songs = data.map((json) => Song.fromJson(json)).toList();
        print('✅ Successfully loaded ${songs.length} songs from server');
        
        // Debug: Print first song's audio path
        if (songs.isNotEmpty) {
          print('🔗 First song audio URL: ${songs[0].audioPath}');
        }
        
        return songs;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching songs: $e');
      
      if (e.toString().contains('Authentication') || 
          e.toString().contains('401') || 
          e.toString().contains('403')) {
        throw Exception('Authentication failed. Please login again.');
      }
      throw Exception('Network error: $e');
    }
  }

  // FIXED: Use correct server endpoint for fresh audio URL
  Future<String> getFreshAudioUrl(String songId) async {
    try {
      print('🔄 Getting fresh audio URL for song: $songId');
      
      final headers = AuthService.getAuthHeaders();
      
      // CRITICAL FIX: Use your actual server endpoint
      final response = await http.get(
        Uri.parse('$baseUrl/songs/refresh/$songId'),
        headers: headers,
      ).timeout(Duration(seconds: 15));

      print('📡 Fresh URL response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final freshUrl = data['new_audio_url'] as String;
        print('✅ Got fresh audio URL: ${freshUrl.substring(0, 50)}...');
        return freshUrl;
      } else if (response.statusCode == 404) {
        throw Exception('Song not found or not from YouTube');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Song is not from YouTube');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to get fresh URL: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting fresh URL: $e');
      throw Exception('Failed to refresh audio URL: $e');
    }
  }

  // Create a new song
  Future<Song> createSong(Map<String, dynamic> songData) async {
    try {
      print('🎵 Creating song: ${songData}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/songs/'),
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode(songData),
      ).timeout(Duration(seconds: 30)); // Longer timeout for YouTube processing

      print('📡 Create song response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Song.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Invalid song data');
      } else {
        throw Exception('Failed to create song: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating song: $e');
      throw Exception('Error creating song: $e');
    }
  }

  // Delete a song
  Future<void> deleteSong(int songId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/songs/$songId'),
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 401) {
          throw Exception('Authentication failed. Please login again.');
        } else if (response.statusCode == 404) {
          throw Exception('Song not found');
        } else {
          throw Exception('Failed to delete song: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error deleting song: $e');
    }
  }

  // Get songs by genre
  Future<List<Song>> getSongsByGenre(String genre) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/songs/$genre'),
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('No songs found for genre: $genre');
      } else {
        throw Exception('Failed to load songs for genre $genre: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching songs by genre: $e');
    }
  }
}