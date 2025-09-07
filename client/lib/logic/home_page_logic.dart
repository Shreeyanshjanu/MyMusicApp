import 'package:client/errors/home_page_error.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:math';
import '../models/song_model.dart';
import '../services/song_service.dart';

// 🔥 FIXED: Public interface for HomePage communication
abstract class HomePageInterface {
  Future<void> loadAndPlaySong(Song song);
  bool get mounted;
}

class HomePageManager {
  static HomePageInterface? _homePageInstance;
  static bool _isHomePageActive = false;
  
  // Check if HomePage is currently active
  static bool get isActive => _isHomePageActive;
  
  // Set HomePage as active/inactive
  static void setActive(bool active) {
    _isHomePageActive = active;
    HomePageErrors.logInfo('Manager', 'HomePage active status changed to: $active');
  }
  
  // 🔥 FIXED: Add missing setHomePageKey method (for compatibility)
  static void setHomePageKey(GlobalKey key) {
    // This method exists for compatibility but we use instance-based approach now
    HomePageErrors.logInfo('Manager', 'setHomePageKey called (compatibility mode)');
  }
  
  // Register HomePage instance using interface
  static void setHomePageInstance(HomePageInterface instance) {
    _homePageInstance = instance;
    HomePageErrors.logInfo('Manager', 'HomePage instance registered');
  }
  
  // Get current HomePage instance
  static HomePageInterface? getCurrentHomePageInstance() {
    try {
      return _homePageInstance;
    } catch (e) {
      HomePageErrors.logWarning('Manager', 'Error getting HomePage instance: $e');
      return null;
    }
  }
  
  // Play song on existing HomePage or create new one
  static Future<void> playSongOnExistingPage(BuildContext context, Song song) async {
    try {
      final currentInstance = getCurrentHomePageInstance();
      
      if (currentInstance != null && _isHomePageActive && currentInstance.mounted) {
        // Use existing HomePage
        HomePageErrors.logInfo('Navigation', 'Using existing HomePage to play: ${song.songName}');
        await currentInstance.loadAndPlaySong(song);
      } else {
        // Navigate to new HomePage
        HomePageErrors.logInfo('Navigation', 'Creating new HomePage for: ${song.songName}');
        
        // Import HomePage dynamically to avoid circular import
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              // We'll import HomePage in the actual usage file
              throw UnimplementedError('HomePage import needed in calling file');
            },
          ),
        );
      }
    } catch (e) {
      HomePageErrors.logError('Navigation', 'Error in playSongOnExistingPage: $e');
      
      // Fallback: Always create new HomePage
      throw UnimplementedError('HomePage navigation fallback needed');
    }
  }
  
  // Clear references when HomePage is disposed
  static void clearReferences() {
    HomePageErrors.logInfo('Manager', 'Clearing HomePage references');
    _homePageInstance = null;
    _isHomePageActive = false;
  }
  
  // Check if HomePage is properly active
  static bool isHomePageProperlyActive() {
    try {
      final instance = getCurrentHomePageInstance();
      return _isHomePageActive && instance != null && instance.mounted;
    } catch (e) {
      return false;
    }
  }
}

class YouTubeVideoInfo {
  final String title;
  final String artist;
  final String thumbnailUrl;
  final Duration duration;
  final String audioUrl;
  final String videoId;

  YouTubeVideoInfo({
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.duration,
    required this.audioUrl,
    required this.videoId,
  });

  YouTubeVideoInfo copyWith({String? audioUrl}) {
    return YouTubeVideoInfo(
      title: title,
      artist: artist,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      audioUrl: audioUrl ?? this.audioUrl,
      videoId: videoId,
    );
  }
}

class HomePageLogic {
  static final SongService _songService = SongService();
  static YoutubeExplode? _yt;

  // Better YouTube Explode management
  static YoutubeExplode _getYouTubeExplode() {
    try {
      if (_yt != null) {
        try {
          _yt!.close();
        } catch (e) {
          // Ignore close errors
        }
      }
      _yt = YoutubeExplode();
      return _yt!;
    } catch (e) {
      HomePageErrors.logError('YouTube', 'Error creating YouTube instance: $e');
      _yt = YoutubeExplode();
      return _yt!;
    }
  }

  // Initialize audio player with minimal error reporting
  static void initializePlayer(AudioPlayer player, Function(bool) onDisposalCheck) {
    player.playerStateStream.listen((state) {
      if (!onDisposalCheck(false)) return;
      
      if (state.processingState == ProcessingState.completed) {
        HomePageErrors.logInfo('Player', 'Song completed - ready for next');
      }
    });

    player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      if (!onDisposalCheck(false)) return;
      
      String errorString = e.toString().toLowerCase();
      
      if (errorString.contains('403') || 
          errorString.contains('forbidden') || 
          errorString.contains('source error')) {
        HomePageErrors.logInfo('Player', 'Recoverable audio error detected - will auto-refresh');
      } else {
        HomePageErrors.logError('Player', 'Non-recoverable audio error: $e');
      }
    });
  }

  // Load library from server
  static Future<List<Song>> loadLibrary() async {
    try {
      HomePageErrors.logInfo('Library', 'Loading library from server');
      
      final songs = await _songService.getAllSongs();
      
      final libraryError = HomePageErrors.validateLibrary(songs);
      if (libraryError != null) {
        throw Exception(libraryError);
      }
      
      HomePageErrors.logSuccess('Library', 'Loaded ${songs.length} songs');
      return songs;
    } catch (e) {
      HomePageErrors.logError('Library', e);
      final errorMessage = HomePageErrors.getLibraryLoadErrorMessage(e);
      throw Exception(errorMessage);
    }
  }

  // Convert Song to YouTubeVideoInfo
  static YouTubeVideoInfo songToVideoInfo(Song song) {
    return YouTubeVideoInfo(
      title: song.songName,
      artist: song.artist,
      thumbnailUrl: song.thumbnail ?? '',
      duration: HomePageErrors.parseDuration(song.duration ?? '0:00') ?? Duration.zero,
      audioUrl: song.audioPath,
      videoId: song.videoId ?? '',
    );
  }

  // Find song index in library
  static int findSongIndex(List<Song> songs, Song targetSong) {
    int index = songs.indexWhere((s) => s.id == targetSong.id);
    
    if (index == -1) {
      index = songs.indexWhere((s) => 
        s.songName.toLowerCase().trim() == targetSong.songName.toLowerCase().trim() && 
        s.artist.toLowerCase().trim() == targetSong.artist.toLowerCase().trim()
      );
    }
    
    HomePageErrors.logInfo('Search', 'Found song at index: $index for ${targetSong.songName}');
    return index;
  }

  // Smart audio setup with better error handling
  static Future<void> setupAudioPlayer(
    AudioPlayer player, 
    String audioUrl, 
    {bool autoPlay = true, 
    required Function(bool) onDisposalCheck,
    Function()? onUrlExpired,
    bool isRetry = false}
  ) async {
    if (!onDisposalCheck(false)) return;
    
    try {
      if (!isRetry) {
        HomePageErrors.logInfo('Player', 'Setting up audio player (autoPlay: $autoPlay)');
      }
      
      final urlError = HomePageErrors.validateAudioUrl(audioUrl);
      if (urlError != null) {
        throw Exception(urlError);
      }
      
      try {
        await player.stop();
        await Future.delayed(Duration(milliseconds: 150));
      } catch (e) {
        HomePageErrors.logWarning('Player', 'Error stopping player: $e');
      }
      
      if (!onDisposalCheck(false)) return;
      
      final uri = Uri.parse(audioUrl);
      
      await player.setAudioSource(
        AudioSource.uri(
          uri,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'identity',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'Referer': 'https://www.youtube.com/',
            'Origin': 'https://www.youtube.com',
            'Sec-Fetch-Dest': 'empty',
            'Sec-Fetch-Mode': 'cors',
            'Sec-Fetch-Site': 'cross-site',
          },
        ),
      );
      
      if (!onDisposalCheck(false)) return;
      
      if (!isRetry) {
        HomePageErrors.logSuccess('Player', 'Audio source set successfully');
      }
      
      if (autoPlay && onDisposalCheck(false)) {
        await player.play();
        if (!isRetry) {
          HomePageErrors.logSuccess('Player', 'Playback started successfully');
        }
      }
      
    } catch (e) {
      if (!onDisposalCheck(false)) return;
      
      String errorString = e.toString().toLowerCase();
      
      if (!isRetry && onUrlExpired != null && 
          (errorString.contains('403') || 
           errorString.contains('forbidden') || 
           errorString.contains('source error') ||
           errorString.contains('network error'))) {
        
        HomePageErrors.logInfo('Player', 'URL expired/network error - attempting silent refresh');
        onUrlExpired();
        return;
      }
      
      if (!isRetry) {
        HomePageErrors.logError('Player', 'Audio setup failed: $e');
        final errorMessage = HomePageErrors.getAudioPlayerErrorMessage(e);
        throw Exception(errorMessage);
      }
    }
  }

  // YouTube URL refresh with better error handling
  static Future<String> refreshYouTubeUrl(String videoId, {bool silent = true}) async {
    YoutubeExplode? yt;
    
    try {
      if (!silent) {
        HomePageErrors.logInfo('Refresh', 'Refreshing YouTube URL for video: $videoId');
      }
      
      if (videoId.isEmpty) {
        throw Exception('Video ID is empty');
      }
      
      yt = _getYouTubeExplode();
      await Future.delayed(Duration(milliseconds: 200));
      
      var video = await yt.videos.get(videoId);
      var manifest = await yt.videos.streamsClient.getManifest(videoId);
      var audioStream = manifest.audioOnly.withHighestBitrate();
      
      if (audioStream == null) {
        var audioStreams = manifest.audioOnly;
        if (audioStreams.isNotEmpty) {
          audioStream = audioStreams.where((s) => s.bitrate.bitsPerSecond > 0).firstOrNull ??
                       audioStreams.first;
        }
      }
      
      if (audioStream == null) {
        throw Exception('No audio stream available for video: $videoId');
      }
      
      String freshUrl = audioStream.url.toString();
      
      if (!silent) {
        HomePageErrors.logSuccess('Refresh', 'Got fresh YouTube URL (${audioStream.bitrate})');
      }
      
      return freshUrl;
      
    } catch (e) {
      if (!silent) {
        HomePageErrors.logError('Refresh', 'YouTube refresh failed: $e');
      }
      rethrow;
    } finally {
      try {
        yt?.close();
      } catch (e) {
        // Ignore close errors
      }
    }
  }

  // Server URL refresh
  static Future<String> refreshServerUrl(String songId, {bool silent = true}) async {
    try {
      if (!silent) {
        HomePageErrors.logInfo('Refresh', 'Refreshing via server for song: $songId');
      }
      
      if (songId.isEmpty) {
        throw Exception('Song ID is empty');
      }
      
      final freshUrl = await _songService.getFreshAudioUrl(songId);
      
      if (freshUrl.isEmpty) {
        throw Exception('Server returned empty URL');
      }
      
      if (!silent) {
        HomePageErrors.logSuccess('Refresh', 'Got fresh URL from server');
      }
      return freshUrl;
      
    } catch (e) {
      if (!silent) {
        HomePageErrors.logError('Refresh', 'Server refresh failed: $e');
      }
      rethrow;
    }
  }

  // Handle shuffle mode
  static List<Song> createShuffledPlaylist(List<Song> originalSongs, Song? currentSong) {
    List<Song> shuffledSongs = List.from(originalSongs);
    shuffledSongs.shuffle(Random());
    
    if (currentSong != null) {
      shuffledSongs.removeWhere((s) => s.id == currentSong.id);
      shuffledSongs.insert(0, currentSong);
    }
    
    HomePageErrors.logInfo('Shuffle', 'Created shuffled playlist with ${shuffledSongs.length} songs');
    return shuffledSongs;
  }

  // Get next song index
  static int getNextSongIndex(int currentIndex, int playlistLength) {
    if (playlistLength == 0) return -1;
    
    int nextIndex = currentIndex + 1;
    if (nextIndex >= playlistLength) {
      nextIndex = 0;
    }
    return nextIndex;
  }

  // Get previous song index
  static int getPreviousSongIndex(int currentIndex, int playlistLength) {
    if (playlistLength == 0) return -1;
    
    int previousIndex = currentIndex - 1;
    if (previousIndex < 0) {
      previousIndex = playlistLength - 1;
    }
    return previousIndex;
  }

  // Validate playback operation
  static bool canPerformPlaybackOperation(List<Song> songs, int currentIndex) {
    bool canPerform = songs.isNotEmpty && 
                     currentIndex != -1 && 
                     currentIndex >= 0 && 
                     currentIndex < songs.length;
    
    if (!canPerform) {
      HomePageErrors.logWarning('Playback', 'Cannot perform playback - songs: ${songs.length}, index: $currentIndex');
    }
    
    return canPerform;
  }

  // Better play/pause handling
  static Future<void> handlePlayPause(
    AudioPlayer player, 
    bool isPlaying, 
    bool isLoading,
    ProcessingState? processingState,
    Function refreshCallback,
    Function(bool) onDisposalCheck
  ) async {
    if (!onDisposalCheck(false)) return;
    
    HomePageErrors.logInfo('Controls', 'Play/Pause - Playing: $isPlaying, Loading: $isLoading, State: $processingState');
    
    if (isLoading) {
      HomePageErrors.logInfo('Controls', 'Player is loading - ignoring tap');
      return;
    }
    
    try {
      if (isPlaying) {
        HomePageErrors.logInfo('Controls', 'Pausing playback');
        await player.pause();
      } else {
        if (processingState == ProcessingState.idle) {
          HomePageErrors.logInfo('Controls', 'Player is idle - refreshing before play');
          await refreshCallback();
        } else {
          HomePageErrors.logInfo('Controls', 'Starting playback');
          await player.play();
        }
      }
    } catch (e) {
      HomePageErrors.logError('Controls', 'Play/Pause error: $e');
      await refreshCallback();
    }
  }

  // Enhanced dispose with better cleanup
  static Future<void> disposeResources(AudioPlayer player) async {
    try {
      HomePageErrors.logInfo('Disposal', 'Starting resource cleanup');
      
      await player.stop().catchError((e) {
        HomePageErrors.logWarning('Disposal', 'Error stopping player: $e');
        return null;
      });
      
      await player.dispose().catchError((e) {
        HomePageErrors.logWarning('Disposal', 'Error disposing player: $e');
        return null;
      });
      
      try {
        _yt?.close();
      } catch (e) {
        HomePageErrors.logWarning('Disposal', 'Error closing YouTube instance: $e');
      }
      _yt = null;
      
      HomePageErrors.logSuccess('Disposal', 'Resources disposed successfully');
      
    } catch (e) {
      HomePageErrors.logError('Disposal', 'Error during disposal: $e');
    }
  }

  // Smart URL refresh with multiple strategies
  static Future<String> getFreshAudioUrl(YouTubeVideoInfo videoInfo, String songId, {bool silent = true}) async {
    if (!silent) {
      HomePageErrors.logInfo('Refresh', 'Starting smart URL refresh for: ${videoInfo.title}');
    }
    
    Exception? lastError;
    
    // Strategy 1: Try YouTube Explode first
    if (videoInfo.videoId.isNotEmpty) {
      try {
        if (!silent) HomePageErrors.logInfo('Refresh', 'Trying YouTube Explode refresh');
        return await refreshYouTubeUrl(videoInfo.videoId, silent: silent);
      } catch (e) {
        HomePageErrors.logInfo('Refresh', 'YouTube Explode failed: ${e.toString().substring(0, 100)}...');
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }
    
    // Strategy 2: Try server refresh as fallback
    if (songId.isNotEmpty) {
      try {
        if (!silent) HomePageErrors.logInfo('Refresh', 'Trying server refresh as fallback');
        return await refreshServerUrl(songId, silent: silent);
      } catch (e) {
        HomePageErrors.logInfo('Refresh', 'Server refresh failed: ${e.toString().substring(0, 100)}...');
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }
    
    // Strategy 3: Last resort
    if (videoInfo.videoId.isNotEmpty) {
      try {
        if (!silent) HomePageErrors.logInfo('Refresh', 'Trying last resort refresh');
        
        await Future.delayed(Duration(seconds: 1));
        
        final yt = YoutubeExplode();
        
        try {
          var video = await yt.videos.get(videoInfo.videoId);
          var manifest = await yt.videos.streamsClient.getManifest(videoInfo.videoId);
          var audioStreams = manifest.audioOnly;
          
          if (audioStreams.isNotEmpty) {
            var bestStream = audioStreams.where((s) => s.bitrate.bitsPerSecond > 0).firstOrNull ??
                            audioStreams.first;
            
            String freshUrl = bestStream.url.toString();
            HomePageErrors.logSuccess('Refresh', 'Got URL from last resort attempt');
            return freshUrl;
          }
        } finally {
          yt.close();
        }
      } catch (e) {
        HomePageErrors.logError('Refresh', 'Last resort attempt failed: $e');
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }
    
    // All strategies failed
    HomePageErrors.logError('Refresh', 'All refresh strategies failed');
    throw lastError ?? Exception('Unable to refresh audio URL - no strategies available');
  }

  // Validate current state before operations
  static bool validateCurrentState(YouTubeVideoInfo? currentVideo, List<Song> allSongs, int currentIndex) {
    bool isValid = currentVideo != null && 
                   allSongs.isNotEmpty && 
                   currentIndex != -1 && 
                   currentIndex < allSongs.length;
    
    if (!isValid) {
      HomePageErrors.logWarning('State', 'Invalid state - Video: ${currentVideo != null}, Songs: ${allSongs.length}, Index: $currentIndex');
    }
    
    return isValid;
  }

  // Check if error should be shown to user
  static bool shouldShowErrorToUser(dynamic error) {
    String errorString = error.toString().toLowerCase();
    
    List<String> recoverableErrors = [
      '403',
      'forbidden',
      'source error',
      'httpclientclosedexception',
      'url expired',
      'network error',
      'connection closed',
      'timeout'
    ];
    
    for (String recoverableError in recoverableErrors) {
      if (errorString.contains(recoverableError)) {
        return false;
      }
    }
    
    return true;
  }

  // Get user-friendly message for common issues
  static String getUserFriendlyErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();
    
    if (errorString.contains('no songs') || errorString.contains('library')) {
      return 'No songs available. Please add some songs first.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('video not found') || errorString.contains('404')) {
      return 'This song is no longer available. Try another song.';
    } else if (errorString.contains('private') || errorString.contains('restricted')) {
      return 'This song is private or restricted. Try another song.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}