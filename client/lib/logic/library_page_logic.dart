import 'package:client/errors/library_page_error.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:client/services/auth_services.dart';
import '../core/constants/server_constant.dart';
import '../models/song_model.dart';
import '../logic/home_page_logic.dart'; // 🔥 ADDED: For HomePageManager

class LibraryPageLogic {
  // Hive boxes
  static Box? _favoritesBox;
  static Box? _songsBox;

  // Initialize Hive storage - exact same as original
  static Future<void> initializeHive() async {
    try {
      _favoritesBox = Hive.box('favoritesBox');
      _songsBox = Hive.box('songsBox');
      LibraryPageErrors.logSuccess('Hive', 'Hive storage initialized');
    } catch (e) {
      LibraryPageErrors.logError('Hive', e);
      throw Exception('Error initializing storage: $e');
    }
  }

  // Authentication validation - exact same as original
  static bool validateAuthentication() {
    return AuthService.isLoggedIn();
  }

  // Load all songs from server - exact same as original
  static Future<List<Song>> loadAllSongs() async {
    try {
      if (!AuthService.isLoggedIn()) {
        LibraryPageErrors.logError('Songs', 'User not logged in');
        throw Exception('Please log in to view your library');
      }

      LibraryPageErrors.logInfo('Songs', 'Fetching songs from server');
      
      final response = await http.get(
        Uri.parse('${ServerConstant.serverURL}${ServerConstant.songsEndpoint}/'),
        headers: AuthService.getAuthHeaders(),
      ).timeout(Duration(seconds: 15));

      LibraryPageErrors.logInfo('Songs', 'Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final songs = data.map((json) => Song.fromJson(json)).toList();
        
        LibraryPageErrors.logSuccess('Songs', 'Loaded ${songs.length} songs from server');
        
        if (songs.isNotEmpty) {
          LibraryPageErrors.logInfo('Songs', 'First song: ${songs.first.songName} by ${songs.first.artist}');
        }
        
        return songs;
      } else if (response.statusCode == 401) {
        LibraryPageErrors.logError('Songs', 'Authentication failed');
        await AuthService.logout();
        throw Exception('Session expired. Please log in again.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      LibraryPageErrors.logError('Songs', e);
      rethrow;
    }
  }

  // Load favorite songs from Hive - exact same as original
  static Future<List<Song>> loadFavoriteSongs() async {
    if (_favoritesBox == null) {
      LibraryPageErrors.logWarning('Favorites', 'Favorites box not initialized');
      return [];
    }
    
    try {
      final favoriteKeys = _favoritesBox!.keys.toList();
      List<Song> favorites = [];
      
      for (var key in favoriteKeys) {
        final songData = _favoritesBox!.get(key);
        if (songData != null) {
          try {
            favorites.add(Song.fromJson(Map<String, dynamic>.from(songData)));
          } catch (e) {
            LibraryPageErrors.logError('Favorites', 'Error parsing favorite song: $e');
            // Remove corrupted favorite
            await _favoritesBox!.delete(key);
          }
        }
      }
      
      LibraryPageErrors.logSuccess('Favorites', 'Loaded ${favorites.length} favorite songs');
      return favorites;
    } catch (e) {
      LibraryPageErrors.logError('Favorites', e);
      return [];
    }
  }

  // Load recently played songs from Hive - exact same as original
  static Future<List<Song>> loadRecentlyPlayed() async {
    if (_songsBox == null) {
      LibraryPageErrors.logWarning('Recent', 'Songs box not initialized');
      return [];
    }
    
    try {
      final recentlyPlayedData = _songsBox!.get('recently_played', defaultValue: []);
      List<Song> recent = [];
      
      for (var songData in recentlyPlayedData) {
        try {
          recent.add(Song.fromJson(Map<String, dynamic>.from(songData)));
        } catch (e) {
          LibraryPageErrors.logError('Recent', 'Error parsing recently played song: $e');
        }
      }
      
      final result = recent.reversed.take(10).toList();
      LibraryPageErrors.logSuccess('Recent', 'Loaded ${result.length} recently played songs');
      return result;
    } catch (e) {
      LibraryPageErrors.logError('Recent', e);
      return [];
    }
  }

  // Organize songs by genre - exact same as original
  static Map<String, List<Song>> organizeSongsByGenre(List<Song> allSongs) {
    LibraryPageErrors.logInfo('Genres', 'Organizing songs by genre');
    Map<String, List<Song>> songsByGenre = {};
    
    for (var song in allSongs) {
      final genre = song.genre.trim();
      if (genre.isNotEmpty) {
        if (!songsByGenre.containsKey(genre)) {
          songsByGenre[genre] = [];
        }
        songsByGenre[genre]!.add(song);
      }
    }
    
    // Sort songs within each genre by song name
    for (var genre in songsByGenre.keys) {
      songsByGenre[genre]!.sort((a, b) => a.songName.compareTo(b.songName));
    }
    
    LibraryPageErrors.logSuccess('Genres', 'Songs organized into ${songsByGenre.keys.length} genres');
    return songsByGenre;
  }

  // Update genres list - exact same as original
  static List<String> updateGenresList(Map<String, List<Song>> songsByGenre) {
    // Get all unique genres from songs, sorted alphabetically
    Set<String> uniqueGenres = songsByGenre.keys.toSet();
    List<String> sortedGenres = uniqueGenres.toList()..sort();
    
    // Create new genres list with 'All' first, then sorted genres
    List<String> newGenres = ['All'] + sortedGenres;
    
    LibraryPageErrors.logInfo('Genres', 'Available genres: $newGenres');
    return newGenres;
  }

  // Check if song is favorite - exact same as original
  static bool isSongFavorite(Song song) {
    if (_favoritesBox == null) return false;
    
    final favoriteKey = '${song.genre}_${song.id}';
    return _favoritesBox!.containsKey(favoriteKey);
  }

  // Toggle favorite - simplified to match original logic
  static Future<Map<String, dynamic>> toggleFavorite(Song song) async {
    if (_favoritesBox == null) {
      throw Exception('Favorites storage not available');
    }
    
    final favoriteKey = '${song.genre}_${song.id}';
    
    try {
      if (!_favoritesBox!.containsKey(favoriteKey)) {
        // Song is not favorite, need genre selection
        return {'action': 'select_genre'};
      } else {
        // Song is already favorite, remove it
        await _favoritesBox!.delete(favoriteKey);
        LibraryPageErrors.logSuccess('Favorites', 'Removed from favorites: ${song.songName}');
        return {'action': 'removed', 'message': 'Removed from favorites'};
      }
    } catch (e) {
      LibraryPageErrors.logError('Favorites', e);
      throw Exception('Error removing from favorites: $e');
    }
  }

  // Add song to favorites - exact same as original
  static Future<void> addToFavorites(Song song, String genre) async {
    if (_favoritesBox == null) {
      throw Exception('Favorites storage not available');
    }
    
    try {
      final favoriteKey = '${genre}_${song.id}';
      final songWithGenre = song.copyWith(genre: genre);
      
      await _favoritesBox!.put(favoriteKey, songWithGenre.toJson());
      LibraryPageErrors.logSuccess('Favorites', 'Added to $genre favorites: ${song.songName}');
    } catch (e) {
      LibraryPageErrors.logError('Favorites', e);
      throw Exception('Error adding to favorites: $e');
    }
  }

  // Add song to recently played - exact same as original
  static Future<void> addToRecentlyPlayed(Song song) async {
    if (_songsBox == null) {
      LibraryPageErrors.logWarning('Recent', 'Songs box not available');
      return;
    }
    
    try {
      List<dynamic> recentlyPlayedData = _songsBox!.get('recently_played', defaultValue: []);
      
      // Remove if already exists
      recentlyPlayedData.removeWhere((item) => 
          item is Map && item['id'] == song.id);
      
      // Add to front
      recentlyPlayedData.insert(0, song.toJson());
      
      // Keep only last 50
      if (recentlyPlayedData.length > 50) {
        recentlyPlayedData = recentlyPlayedData.take(50).toList();
      }
      
      await _songsBox!.put('recently_played', recentlyPlayedData);
      LibraryPageErrors.logSuccess('Recent', 'Added ${song.songName} to recently played');
    } catch (e) {
      LibraryPageErrors.logError('Recent', 'Failed to add to recently played: $e');
    }
  }

  // 🔥 UPDATED: Use singleton HomePage management
  static Future<void> playSong(BuildContext context, Song song, List<Song> playlist) async {
    try {
      await addToRecentlyPlayed(song);
      
      LibraryPageErrors.logSuccess('Playback', 'Playing: ${song.songName} by ${song.artist}');
      
      // 🔥 CRITICAL: Use singleton HomePage instead of creating new instance
      await HomePageManager.playSongOnExistingPage(context, song);
      
    } catch (e) {
      LibraryPageErrors.logError('Playback', e);
      throw Exception('Error playing song: $e');
    }
  }

  // Prepare playlist for playback - exact same as original
  static List<Song> preparePlaylist(List<Song> songs, bool isShuffleMode) {
    if (songs.isEmpty) return [];
    
    List<Song> playList = List.from(songs);
    
    if (isShuffleMode) {
      playList.shuffle(Random());
      LibraryPageErrors.logInfo('Playback', 'Playlist shuffled with ${playList.length} songs');
    } else {
      LibraryPageErrors.logInfo('Playback', 'Playing ${playList.length} songs in order');
    }
    
    return playList;
  }

  // Get current user info
  static Map<String, dynamic>? getCurrentUserInfo() {
    try {
      return AuthService.getCurrentUser();
    } catch (e) {
      LibraryPageErrors.logError('User', 'Failed to get user info: $e');
      return null;
    }
  }

  // Helper method to compare lists - exact same as original
  static bool areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}