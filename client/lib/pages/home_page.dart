// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
// import '../colors/color_pallete.dart';
// import '../models/song_model.dart';
// import '../services/song_service.dart';
// import '../pages/library_page.dart';
// import '../pages/upload_page.dart';
// import '../pages/settings_page.dart';

// class YouTubeVideoInfo {
//   final String title;
//   final String artist;
//   final String thumbnailUrl;
//   final Duration duration;
//   final String audioUrl;
//   final String videoId;

//   YouTubeVideoInfo({
//     required this.title,
//     required this.artist,
//     required this.thumbnailUrl,
//     required this.duration,
//     required this.audioUrl,
//     required this.videoId,
//   });
// }

// class HomePage extends StatefulWidget {
//   final Song? initialSong;
  
//   const HomePage({super.key, this.initialSong});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final AudioPlayer _player = AudioPlayer();
//   final YoutubeExplode _yt = YoutubeExplode();
//   final SongService _songService = SongService();
  
//   YouTubeVideoInfo? _currentVideo;
//   List<Song> _allSongs = [];
//   List<Song> _shuffledSongs = []; // For shuffle mode
//   int _currentSongIndex = -1;
//   bool _isLoading = false;
//   bool _isFavorite = false;
//   bool _isRetryingUrl = false;
//   bool _isShuffleMode = false; // Track shuffle state
//   bool _isLibraryLoaded = false; // Track if library loaded successfully
//   bool _isDisposed = false; // 🔥 NEW: Track disposal state

//   @override
//   void initState() {
//     super.initState();
//     WidgetsFlutterBinding.ensureInitialized();
//     _initializePlayer();
//     _loadLibraryAndInitialSong();
//   }

//   void _initializePlayer() {
//     // Listen for player state changes
//     _player.playerStateStream.listen((state) {
//       if (_isDisposed) return; // 🔥 CRITICAL: Don't process if disposed
      
//       if (state.processingState == ProcessingState.idle && 
//           _currentVideo != null && 
//           !_isRetryingUrl) {
//         print('🔄 Audio player went idle, might need URL refresh');
//       }
      
//       // Auto-play next song when current song ends
//       if (state.processingState == ProcessingState.completed) {
//         _playNextSong();
//       }
//     });

//     // Listen for errors
//     _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
//       if (_isDisposed) return; // 🔥 CRITICAL: Don't process if disposed
      
//       print('❌ Audio player error: $e');
//       _showSnackBar('Audio playback error: ${e.toString()}');
//     });
//   }

//   // 🔥 CRITICAL FIX: Combined library loading and initial song setup
//   Future<void> _loadLibraryAndInitialSong() async {
//     if (_isDisposed) return;
    
//     setState(() {
//       _isLoading = true;
//     });
    
//     try {
//       print('📚 Loading library...');
//       _allSongs = await _songService.getAllSongs();
//       _shuffledSongs = List.from(_allSongs); // Initialize shuffle list
      
//       if (_isDisposed) return; // Check disposal before setState
      
//       setState(() {
//         _isLibraryLoaded = true;
//         _isLoading = false;
//       });
      
//       print('✅ Library loaded: ${_allSongs.length} songs');
      
//       if (_allSongs.isEmpty) {
//         _showSnackBar('No songs found in library. Upload some songs first!', isSuccess: false);
//         return;
//       }

//       // 🔥 CRITICAL: Handle initial song properly
//       if (widget.initialSong != null) {
//         print('🎵 Loading initial song from navigation: ${widget.initialSong!.songName}');
//         await _loadSongFromLibrary(widget.initialSong!, autoPlay: true);
//       } else {
//         // Auto-load first song but don't auto-play
//         print('🎵 Auto-loading first song: ${_allSongs[0].songName}');
//         await _loadSongFromLibrary(_allSongs[0], autoPlay: false);
//       }
      
//     } catch (e) {
//       print('❌ Error loading library: $e');
//       if (_isDisposed) return;
      
//       setState(() {
//         _isLoading = false;
//         _isLibraryLoaded = false;
//       });
      
//       // More specific error message
//       String errorMessage = 'Failed to load library';
//       if (e.toString().contains('422')) {
//         errorMessage = 'Authentication error. Please login again.';
//       } else if (e.toString().contains('network') || e.toString().contains('connection')) {
//         errorMessage = 'Network error. Check your connection.';
//       } else {
//         errorMessage = 'Error loading library: ${e.toString()}';
//       }
      
//       _showSnackBar(errorMessage);
//     }
//   }

//   @override
//   void dispose() {
//     // 🔥 CRITICAL: Proper disposal sequence
//     print('🛑 Disposing HomePage - stopping and disposing audio player');
//     _isDisposed = true; // Set disposal flag first
    
//     // Stop audio player immediately
//     _player.stop().catchError((e) {
//       print('❌ Error stopping player during disposal: $e');
//     });
    
//     // Dispose audio player
//     _player.dispose().catchError((e) {
//       print('❌ Error disposing player: $e');
//     });
    
//     // Close YouTube explode
//     _yt.close();
    
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     return Scaffold(
//       backgroundColor: ColorPalette.backgroundColor,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: screenWidth * 0.05,
//             vertical: screenHeight * 0.02,
//           ),
//           child: Column(
//             children: [
//               // Loading indicator for library
//               if (_isLoading)
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(
//                         color: ColorPalette.accentColor,
//                         strokeWidth: 2,
//                       ),
//                       SizedBox(width: 12),
//                       Text(
//                         'Loading library...',
//                         style: TextStyle(
//                           color: ColorPalette.hintTextColor,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//               // Main content area
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Large album art with neumorphic design
//                     _buildAlbumArt(screenWidth),
                    
//                     SizedBox(height: screenHeight * 0.04),
                    
//                     // Song name with neumorphic container
//                     _buildSongTitle(screenWidth),
                    
//                     SizedBox(height: screenHeight * 0.03),
                    
//                     // Progress bar
//                     _buildProgressBar(screenWidth),
                    
//                     SizedBox(height: screenHeight * 0.04),
                    
//                     // Control buttons with neumorphic design
//                     _buildControlButtons(screenWidth),
                    
//                     // Error/Loading indicator
//                     if (_isRetryingUrl)
//                       Padding(
//                         padding: EdgeInsets.only(top: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: ColorPalette.accentColor,
//                               ),
//                             ),

import 'package:client/errors/home_page_error.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../colors/color_pallete.dart';
import '../models/song_model.dart';
import '../pages/library_page.dart';
import '../pages/upload_page.dart';
import '../pages/settings_page.dart';
import '../logic/home_page_logic.dart';

class HomePage extends StatefulWidget {
  final Song? initialSong;
  
  const HomePage({super.key, this.initialSong});

  @override
  State<HomePage> createState() => _HomePageState();
}

// 🔥 FIXED: Implement HomePageInterface
class _HomePageState extends State<HomePage> implements HomePageInterface {
  final AudioPlayer _player = AudioPlayer();
  
  YouTubeVideoInfo? _currentVideo;
  List<Song> _allSongs = [];
  List<Song> _shuffledSongs = [];
  int _currentSongIndex = -1;
  bool _isLoading = false;
  bool _isFavorite = false;
  bool _isRetryingUrl = false;
  bool _isShuffleMode = false;
  bool _isLibraryLoaded = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    
    // 🔥 CRITICAL: Register this HomePage instance
    HomePageManager.setHomePageInstance(this);
    HomePageManager.setActive(true);
    
    _initializePlayer();
    _loadLibraryAndInitialSong();
  }

  // 🔥 FIXED: Implement the interface method
  @override
  Future<void> loadAndPlaySong(Song song) async {
    if (_isDisposed) return;
    
    HomePageErrors.logInfo('External', 'Loading external song: ${song.songName}');
    
    // 🔥 CRITICAL: Stop current playback immediately
    try {
      await _player.stop();
      HomePageErrors.logInfo('External', 'Stopped current playback');
    } catch (e) {
      HomePageErrors.logWarning('External', 'Error stopping current playback: $e');
    }
    
    // Load the new song
    await _loadSongFromLibrary(song, autoPlay: true);
  }

  void _initializePlayer() {
    HomePageLogic.initializePlayer(_player, _checkDisposal);
    
    // Auto-play next song when current song ends
    _player.playerStateStream.listen((state) {
      if (_isDisposed) return;
      
      if (state.processingState == ProcessingState.completed) {
        _playNextSong();
      }
    });

    // 🔥 ENHANCED: Silent error handling - don't show recoverable errors
    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      if (_isDisposed) return;
      
      // Only show critical errors to user
      if (HomePageLogic.shouldShowErrorToUser(e)) {
        HomePageErrors.showErrorSnackBar(context, HomePageErrors.getCriticalErrorMessage(e));
      }
      // Otherwise, let silent auto-refresh handle it
    });
  }

  bool _checkDisposal(bool shouldReturn) {
    if (_isDisposed && shouldReturn) return false;
    return !_isDisposed;
  }

  Future<void> _loadLibraryAndInitialSong() async {
    if (_isDisposed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      HomePageErrors.logInfo('Init', 'Loading library and initial song');
      
      _allSongs = await HomePageLogic.loadLibrary();
      _shuffledSongs = List.from(_allSongs);
      
      if (_isDisposed) return;
      
      setState(() {
        _isLibraryLoaded = true;
        _isLoading = false;
      });
      
      if (_allSongs.isEmpty) {
        HomePageErrors.showErrorSnackBar(context, 'No songs found in library. Upload some songs first!');
        return;
      }

      // Handle initial song
      if (widget.initialSong != null) {
        HomePageErrors.logInfo('Init', 'Loading initial song: ${widget.initialSong!.songName}');
        await _loadSongFromLibrary(widget.initialSong!, autoPlay: true);
      } else {
        HomePageErrors.logInfo('Init', 'Auto-loading first song: ${_allSongs[0].songName}');
        await _loadSongFromLibrary(_allSongs[0], autoPlay: false);
      }
      
    } catch (e) {
      HomePageErrors.logError('Init', e);
      if (_isDisposed) return;
      
      setState(() {
        _isLoading = false;
        _isLibraryLoaded = false;
      });
      
      HomePageErrors.showErrorSnackBar(context, e.toString());
    }
  }

  @override
  void dispose() {
    HomePageErrors.logInfo('Disposal', 'Disposing HomePage');
    _isDisposed = true;
    
    // 🔥 CRITICAL: Mark HomePage as inactive
    HomePageManager.setActive(false);
    HomePageManager.clearReferences();
    
    // Dispose resources using logic layer
    HomePageLogic.disposeResources(_player);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              // Loading indicator for library
              if (_isLoading)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: ColorPalette.accentColor,
                        strokeWidth: 2,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Loading library...',
                        style: TextStyle(
                          color: ColorPalette.hintTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              // Main content area
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large album art with neumorphic design
                    _buildAlbumArt(screenWidth),
                    
                    SizedBox(height: screenHeight * 0.04),
                    
                    // Song name with neumorphic container
                    _buildSongTitle(screenWidth),
                    
                    SizedBox(height: screenHeight * 0.03),
                    
                    // Progress bar
                    _buildProgressBar(screenWidth),
                    
                    SizedBox(height: screenHeight * 0.04),
                    
                    // Control buttons with neumorphic design
                    _buildControlButtons(screenWidth),
                    
                    // 🔥 ENHANCED: Minimal retry indicator (only for manual refresh)
                    if (_isRetryingUrl)
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorPalette.accentColor,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Refreshing...',
                              style: TextStyle(
                                color: ColorPalette.hintTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Library status indicator
                    if (!_isLibraryLoaded && !_isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.library_music_outlined,
                              color: ColorPalette.hintTextColor,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No library loaded',
                              style: TextStyle(
                                color: ColorPalette.hintTextColor,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadLibraryAndInitialSong,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorPalette.accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Retry Loading',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Bottom navigation with neumorphic design
              _buildBottomNavigation(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt(double screenWidth) {
    final albumSize = screenWidth * 0.75;
    
    return Container(
      width: albumSize,
      height: albumSize,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorPalette.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(ColorPalette.darkShadowOpacity),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(8, 8),
          ),
          BoxShadow(
            color: ColorPalette.lightShadowColor.withOpacity(ColorPalette.lightShadowOpacity),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(-8, -8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ColorPalette.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorPalette.borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorPalette.darkShadowColor.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
            BoxShadow(
              color: ColorPalette.lightShadowColor.withOpacity(0.8),
              blurRadius: 4,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _currentVideo?.thumbnailUrl != null && _currentVideo!.thumbnailUrl.isNotEmpty
              ? Image.network(
                  _currentVideo!.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAlbumArt(screenWidth);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: ColorPalette.accentColor,
                        strokeWidth: 2,
                      ),
                    );
                  },
                )
              : _buildDefaultAlbumArt(screenWidth),
        ),
      ),
    );
  }

  Widget _buildDefaultAlbumArt(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(4, 4),
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(0.6),
                  blurRadius: 8,
                  offset: Offset(-4, -4),
                ),
              ],
            ),
            child: Icon(
              Icons.music_note,
              size: screenWidth * 0.12,
              color: ColorPalette.accentColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            _currentVideo != null ? 'No Album Art' : 'No Song Selected',
            style: TextStyle(
              color: ColorPalette.hintTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTitle(double screenWidth) {
    return Container(
      width: screenWidth * 0.8,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: ColorPalette.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorPalette.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(4, 4),
          ),
          BoxShadow(
            color: ColorPalette.lightShadowColor.withOpacity(0.6),
            blurRadius: 8,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _currentVideo?.title ?? 'No Song Selected',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: ColorPalette.primaryTextColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (_currentVideo?.artist != null && _currentVideo!.artist.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              _currentVideo!.artist,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: ColorPalette.hintTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // Show shuffle indicator
          if (_isShuffleMode && _currentVideo != null) ...[
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shuffle,
                  color: ColorPalette.accentColor,
                  size: 12,
                ),
                SizedBox(width: 4),
                Text(
                  'Shuffle Mode',
                  style: TextStyle(
                    fontSize: 10,
                    color: ColorPalette.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          // Show current position in playlist
          if (_currentSongIndex != -1 && _allSongs.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              '${_currentSongIndex + 1} of ${_allSongs.length}',
              style: TextStyle(
                fontSize: 10,
                color: ColorPalette.hintTextColor.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(double screenWidth) {
    return Container(
      width: screenWidth * 0.85,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: ColorPalette.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorPalette.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
          BoxShadow(
            color: ColorPalette.lightShadowColor.withOpacity(0.7),
            blurRadius: 4,
            offset: Offset(-2, -2),
          ),
        ],
      ),
      child: StreamBuilder<Duration>(
        stream: _player.positionStream,
        builder: (context, snapshot) {
          return ProgressBar(
            progress: snapshot.data ?? Duration.zero,
            buffered: _player.bufferedPosition,
            total: _player.duration ?? Duration.zero,
            onSeek: (duration) {
              if (!_isDisposed) {
                _player.seek(duration);
              }
            },
            progressBarColor: ColorPalette.accentColor,
            baseBarColor: ColorPalette.borderColor,
            bufferedBarColor: ColorPalette.hintTextColor.withOpacity(0.3),
            thumbColor: ColorPalette.accentColor,
            barHeight: 4.0,
            thumbRadius: 8.0,
            timeLabelTextStyle: TextStyle(
              color: ColorPalette.hintTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButtons(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: ColorPalette.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorPalette.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(4, 4),
          ),
          BoxShadow(
            color: ColorPalette.lightShadowColor.withOpacity(0.6),
            blurRadius: 8,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle button
          _buildControlButton(
            icon: Icons.shuffle,
            size: screenWidth * 0.06,
            color: _isShuffleMode ? ColorPalette.accentColor : ColorPalette.primaryTextColor,
            onPressed: _toggleShuffle,
          ),
          
          // Previous button
          _buildControlButton(
            icon: Icons.skip_previous,
            size: screenWidth * 0.08,
            onPressed: (_allSongs.isNotEmpty && _currentSongIndex != -1) ? _playPreviousSong : null,
          ),
          
          // 🔥 ENHANCED: Play/Pause button with better state handling
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final processingState = snapshot.data?.processingState;
              final playing = snapshot.data?.playing;

              // Determine button icon and color based on state
              IconData buttonIcon;
              Color buttonColor = ColorPalette.lightShadowColor;
              
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                buttonIcon = Icons.hourglass_empty;
              } else if (processingState == ProcessingState.idle && _currentVideo != null) {
                buttonIcon = Icons.refresh;
                buttonColor = ColorPalette.warningColor;
              } else if (playing == true) {
                buttonIcon = Icons.pause;
              } else {
                buttonIcon = Icons.play_arrow;
              }

              return Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: ColorPalette.accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorPalette.borderColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorPalette.darkShadowColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(4, 4),
                    ),
                    BoxShadow(
                      color: ColorPalette.lightShadowColor.withOpacity(0.6),
                      blurRadius: 8,
                      offset: Offset(-4, -4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _handlePlayPause(processingState, playing),
                  icon: Icon(
                    buttonIcon,
                    size: screenWidth * 0.07,
                    color: buttonColor,
                  ),
                ),
              );
            },
          ),
          
          // Next button
          _buildControlButton(
            icon: Icons.skip_next,
            size: screenWidth * 0.08,
            onPressed: (_allSongs.isNotEmpty && _currentSongIndex != -1) ? _playNextSong : null,
          ),
          
          // Favorite button
          _buildControlButton(
            icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
            size: screenWidth * 0.06,
            color: _isFavorite ? ColorPalette.romanticColor : ColorPalette.primaryTextColor,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    bool isDisabled = onPressed == null;
    
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: isDisabled ? ColorPalette.cardColor : ColorPalette.backgroundColor,
        shape: BoxShape.circle,
        boxShadow: isDisabled 
            ? []
            : [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(0.6),
                  blurRadius: 4,
                  offset: Offset(-2, -2),
                ),
              ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: size,
          color: isDisabled 
              ? ColorPalette.hintTextColor.withOpacity(0.5)
              : (color ?? ColorPalette.primaryTextColor),
        ),
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        style: IconButton.styleFrom(shape: CircleBorder()),
      ),
    );
  }

  Widget _buildBottomNavigation(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: ColorPalette.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorPalette.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(ColorPalette.darkShadowOpacity),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(6, 6),
          ),
          BoxShadow(
            color: ColorPalette.lightShadowColor.withOpacity(ColorPalette.lightShadowOpacity),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(-6, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home button (active)
          _buildNavButton(
            icon: Icons.home,
            isActive: true,
            onTap: () {},
            screenWidth: screenWidth,
          ),
          
          // Upload button
          _buildNavButton(
            icon: Icons.upload,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadPage()),
              );
            },
            screenWidth: screenWidth,
          ),
          
          // Library button
          _buildNavButton(
            icon: Icons.library_music,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LibraryPage()),
              );
            },
            screenWidth: screenWidth,
          ),
          
          // Settings button
          _buildNavButton(
            icon: Icons.settings,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.12,
        height: screenWidth * 0.12,
        decoration: BoxDecoration(
          color: isActive ? ColorPalette.cardColor : ColorPalette.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorPalette.borderColor,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: ColorPalette.darkShadowColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                  BoxShadow(
                    color: ColorPalette.lightShadowColor.withOpacity(0.7),
                    blurRadius: 4,
                    offset: Offset(-2, -2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: ColorPalette.darkShadowColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                  BoxShadow(
                    color: ColorPalette.lightShadowColor.withOpacity(0.6),
                    blurRadius: 4,
                    offset: Offset(-2, -2),
                  ),
                ],
        ),
        child: Icon(
          icon,
          size: screenWidth * 0.055,
          color: isActive ? ColorPalette.accentColor : ColorPalette.primaryTextColor,
        ),
      ),
    );
  }

  // ============== EVENT HANDLERS ==============

  // 🔥 ENHANCED: Stop previous playback before loading new song
  Future<void> _loadSongFromLibrary(Song song, {bool autoPlay = true}) async {
    if (_isDisposed) return;
    
    try {
      // 🔥 CRITICAL: Always stop current playback first
      try {
        await _player.stop();
        HomePageErrors.logInfo('Load', 'Stopped current playback before loading new song');
      } catch (e) {
        HomePageErrors.logWarning('Load', 'Error stopping current playback: $e');
      }
      
      // Ensure library is loaded
      if (_allSongs.isEmpty) {
        await _loadLibraryAndInitialSong();
        if (_allSongs.isEmpty || _isDisposed) {
          HomePageErrors.showErrorSnackBar(context, 'No songs available. Load library first.');
          return;
        }
      }

      // Find song index
      _currentSongIndex = HomePageLogic.findSongIndex(_allSongs, song);
      
      if (_currentSongIndex == -1) {
        HomePageErrors.showErrorSnackBar(context, 'Song not found in current library');
        return;
      }
      
      if (_isDisposed) return;
      
      // Update current video info
      setState(() {
        _currentVideo = HomePageLogic.songToVideoInfo(song);
      });
      
      // Setup with silent auto-refresh
      await HomePageLogic.setupAudioPlayer(
        _player, 
        song.audioPath, 
        autoPlay: autoPlay,
        onDisposalCheck: _checkDisposal,
        onUrlExpired: () => _silentRefreshAudioUrl(),
      );
      
      // Only show success for user-initiated actions
      if (autoPlay) {
        HomePageErrors.showSuccessSnackBar(context, 'Now playing: ${song.songName}');
      }
      
    } catch (e) {
      if (_isDisposed) return;
      
      // Only show critical errors
      if (HomePageLogic.shouldShowErrorToUser(e)) {
        HomePageErrors.showErrorSnackBar(context, HomePageErrors.getCriticalErrorMessage(e));
      }
    }
  }

  // 🔥 NEW: Silent refresh method (no UI feedback unless it fails completely)
  Future<void> _silentRefreshAudioUrl() async {
    if (_isDisposed || _currentVideo == null) return;

    try {
      String songId = '';
      if (_currentSongIndex != -1 && _allSongs.isNotEmpty) {
        final currentSong = _isShuffleMode ? _shuffledSongs[_currentSongIndex] : _allSongs[_currentSongIndex];
        songId = currentSong.id.toString();
      }

      // Silent refresh - no UI indicators
      final freshUrl = await HomePageLogic.getFreshAudioUrl(_currentVideo!, songId, silent: true);
      
      if (_isDisposed) return;
      
      // Update current video with fresh URL
      _currentVideo = _currentVideo!.copyWith(audioUrl: freshUrl);
      
      // Setup player again with fresh URL (silent)
      await HomePageLogic.setupAudioPlayer(
        _player, 
        freshUrl, 
        autoPlay: true,
        onDisposalCheck: _checkDisposal,
        isRetry: true, // Mark as retry to prevent error messages
      );
      
      // No success message - keep it silent
      
    } catch (e) {
      if (_isDisposed) return;
      
      // Only show error if it's a critical failure and user needs to know
      if (HomePageLogic.shouldShowErrorToUser(e)) {
        HomePageErrors.showErrorSnackBar(context, 'Unable to refresh audio. Try playing another song.');
      }
    }
  }

  // Manual refresh method (for user-initiated refresh with UI feedback)
  // ignore: unused_element
  Future<void> _refreshAudioUrl() async {
    if (_isDisposed || _currentVideo == null) {
      HomePageErrors.showErrorSnackBar(context, 'Cannot refresh audio URL');
      return;
    }

    // Show loading only for manual refresh
    setState(() {
      _isRetryingUrl = true;
    });

    try {
      String songId = '';
      if (_currentSongIndex != -1 && _allSongs.isNotEmpty) {
        final currentSong = _isShuffleMode ? _shuffledSongs[_currentSongIndex] : _allSongs[_currentSongIndex];
        songId = currentSong.id.toString();
      }

      final freshUrl = await HomePageLogic.getFreshAudioUrl(_currentVideo!, songId, silent: false);
      
      if (_isDisposed) return;
      
      _currentVideo = _currentVideo!.copyWith(audioUrl: freshUrl);
      
      await HomePageLogic.setupAudioPlayer(
        _player, 
        freshUrl, 
        autoPlay: true,
        onDisposalCheck: _checkDisposal,
        onUrlExpired: () => _silentRefreshAudioUrl(),
      );
      
      HomePageErrors.showSuccessSnackBar(context, 'Audio refreshed successfully!');
      
    } catch (e) {
      if (_isDisposed) return;
      HomePageErrors.showErrorSnackBar(context, HomePageErrors.getCriticalErrorMessage(e));
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isRetryingUrl = false;
        });
      }
    }
  }

  void _toggleShuffle() {
    if (_isDisposed) return;
    
    setState(() {
      _isShuffleMode = !_isShuffleMode;
    });
    
    if (_isShuffleMode) {
      // Create shuffled playlist
      Song? currentSong = _currentSongIndex != -1 && _currentSongIndex < _allSongs.length 
          ? _allSongs[_currentSongIndex] 
          : null;
      
      _shuffledSongs = HomePageLogic.createShuffledPlaylist(_allSongs, currentSong);
      _currentSongIndex = 0; // Current song is now at index 0
      
      HomePageErrors.showSuccessSnackBar(context, 'Shuffle mode ON 🔀');
    } else {
      // Return to normal order
      if (_currentVideo != null && _allSongs.isNotEmpty) {
        _currentSongIndex = _allSongs.indexWhere((song) => 
          song.songName == _currentVideo!.title && song.artist == _currentVideo!.artist
        );
      }
      
      HomePageErrors.showSuccessSnackBar(context, 'Shuffle mode OFF');
    }
  }

  void _playPreviousSong() {
    if (!HomePageLogic.canPerformPlaybackOperation(_allSongs, _currentSongIndex)) {
      HomePageErrors.showErrorSnackBar(context, 'No songs available or no current song');
      return;
    }
    
    List<Song> playlist = _isShuffleMode ? _shuffledSongs : _allSongs;
    int previousIndex = HomePageLogic.getPreviousSongIndex(_currentSongIndex, playlist.length);
    
    _currentSongIndex = previousIndex;
    _loadSongFromLibrary(playlist[previousIndex], autoPlay: true);
    
    HomePageErrors.logInfo('Navigation', 'Playing previous song: ${playlist[previousIndex].songName}');
  }

  void _playNextSong() {
    if (!HomePageLogic.canPerformPlaybackOperation(_allSongs, _currentSongIndex)) {
      HomePageErrors.showErrorSnackBar(context, 'No songs available or no current song');
      return;
    }
    
    List<Song> playlist = _isShuffleMode ? _shuffledSongs : _allSongs;
    int nextIndex = HomePageLogic.getNextSongIndex(_currentSongIndex, playlist.length);
    
    _currentSongIndex = nextIndex;
    _loadSongFromLibrary(playlist[nextIndex], autoPlay: true);
    
    HomePageErrors.logInfo('Navigation', 'Playing next song: ${playlist[nextIndex].songName}');
  }

  Future<void> _handlePlayPause(ProcessingState? processingState, bool? playing) async {
    if (_isDisposed) return;
    
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return; // Silent ignore
    }
    
    if (_currentVideo == null) {
      HomePageErrors.showErrorSnackBar(context, 'No song loaded');
      return;
    }
    
    await HomePageLogic.handlePlayPause(
      _player, 
      playing == true,
      processingState == ProcessingState.loading || processingState == ProcessingState.buffering,
      processingState,
      () => _silentRefreshAudioUrl(), // Use silent refresh
      _checkDisposal
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // Show brief feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(_isFavorite ? 'Added to favorites ❤️' : 'Removed from favorites'),
          ],
        ),
        backgroundColor: _isFavorite ? ColorPalette.romanticColor : ColorPalette.hintTextColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }
}