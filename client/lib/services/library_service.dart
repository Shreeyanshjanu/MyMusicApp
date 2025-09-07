import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';

class LibraryService {
  static const String _libraryKey = 'song_library';
  static LibraryService? _instance;
  List<Song> _songs = [];

  LibraryService._();

  static LibraryService get instance {
    _instance ??= LibraryService._();
    return _instance!;
  }

  List<Song> get songs => List.unmodifiable(_songs);

  Future<void> loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final libraryJson = prefs.getString(_libraryKey);
    if (libraryJson != null) {
      final List<dynamic> libraryList = json.decode(libraryJson);
      _songs = libraryList.map((json) => Song.fromJson(json)).toList();
    }
  }

  Future<void> addSong(Song song) async {
    _songs.add(song);
    await _saveLibrary();
  }

  Future<void> removeSong(String songId) async {
    _songs.removeWhere((song) => song.id == songId);
    await _saveLibrary();
  }

  List<Song> getSongsByGenre(String genre) {
    return _songs.where((song) => song.genre == genre).toList();
  }

  Future<void> _saveLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final libraryJson = json.encode(_songs.map((song) => song.toJson()).toList());
    await prefs.setString(_libraryKey, libraryJson);
  }
}