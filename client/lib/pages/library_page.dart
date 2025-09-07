
import 'package:client/colors/color_pallete.dart';
import 'package:client/errors/library_page_error.dart';
import 'package:client/logic/home_page_logic.dart';
import 'package:client/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/song_model.dart';
import '../logic/library_page_logic.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> 
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  Box? _favoritesBox;
  Box? _songsBox;
  
  List<Song> allSongs = [];
  List<Song> favoriteSongs = [];
  List<Song> recentlyPlayed = [];
  Map<String, List<Song>> songsByGenre = {};
  bool isLoading = true;
  String selectedGenre = 'All';
  bool isShuffleMode = false;
  
  List<String> genres = ['All'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: genres.length, vsync: this);
    _initializeHive();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed - refreshing library');
      _refreshLibrary();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isLoading && mounted) {
      print('🔄 Page dependencies changed - refreshing library');
      _refreshLibrary();
    }
  }

  Future<void> _initializeHive() async {
    try {
      await LibraryPageLogic.initializeHive();
      _favoritesBox = Hive.box('favoritesBox');
      _songsBox = Hive.box('songsBox');
      await _loadLibraryData();
    } catch (e) {
      print('❌ Error initializing Hive: $e');
      setState(() => isLoading = false);
      _showSnackBar('Error initializing storage: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  // Load library data - delegate to logic but handle UI state
  Future<void> _loadLibraryData() async {
    print('📚 Loading library data...');
    setState(() => isLoading = true);
    
    try {
      // Load all data using logic layer
      final loadedSongs = await LibraryPageLogic.loadAllSongs();
      final loadedFavorites = await LibraryPageLogic.loadFavoriteSongs();
      final loadedRecent = await LibraryPageLogic.loadRecentlyPlayed();
      
      // Organize data
      final organizedByGenre = LibraryPageLogic.organizeSongsByGenre(loadedSongs);
      final updatedGenres = LibraryPageLogic.updateGenresList(organizedByGenre);
      
      setState(() {
        allSongs = loadedSongs;
        favoriteSongs = loadedFavorites;
        recentlyPlayed = loadedRecent;
        songsByGenre = organizedByGenre;
        _updateGenresAndTabs(updatedGenres);
        isLoading = false;
      });
      
      print('✅ Library data loaded successfully');
    } catch (e) {
      print('❌ Error loading library: $e');
      setState(() => isLoading = false);
      _showSnackBar('Error loading library: $e');
    }
  }

  // Update genres and tabs - exact same as original
  void _updateGenresAndTabs(List<String> newGenres) {
    if (!LibraryPageLogic.areListsEqual(genres, newGenres)) {
      final oldSelectedGenre = selectedGenre;
      
      // Dispose old tab controller
      _tabController.dispose();
      
      setState(() {
        genres = newGenres;
        
        // Create new tab controller
        _tabController = TabController(length: genres.length, vsync: this);
        
        // Maintain selected genre if it still exists
        if (genres.contains(oldSelectedGenre)) {
          selectedGenre = oldSelectedGenre;
          final newIndex = genres.indexOf(selectedGenre);
          _tabController.index = newIndex;
        } else {
          selectedGenre = 'All';
          _tabController.index = 0;
        }
      });
      
      print('✅ Updated genres list with ${genres.length} genres');
    }
  }

  Future<void> _refreshLibrary() async {
    print('🔄 Refreshing library...');
    await _loadLibraryData();
    if (mounted) {
      _showSnackBar('Library refreshed successfully!', isSuccess: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if user is logged in
    if (!LibraryPageLogic.validateAuthentication()) {
      return Scaffold(
        backgroundColor: ColorPalette.backgroundColor,
        body: Center(
          child: Container(
            margin: EdgeInsets.all(screenWidth * 0.08),
            padding: EdgeInsets.all(screenWidth * 0.08),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(ColorPalette.darkShadowOpacity),
                  offset: const Offset(6, 6),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(ColorPalette.lightShadowOpacity),
                  offset: const Offset(-6, -6),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: screenWidth * 0.2,
                  color: ColorPalette.hintTextColor,
                ),
                SizedBox(height: 20),
                Text(
                  'Please log in to view your library',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: ColorPalette.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                _buildNeumorphicButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Go to Login',
                    style: TextStyle(
                      color: ColorPalette.primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Library',
          style: TextStyle(
            color: ColorPalette.primaryTextColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ColorPalette.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorPalette.primaryTextColor),
        actions: [
          // Shuffle Button
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: isShuffleMode ? [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(0.7),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ] : [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(ColorPalette.darkShadowOpacity),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(ColorPalette.lightShadowOpacity),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isShuffleMode ? Icons.shuffle : Icons.shuffle_outlined,
                color: isShuffleMode ? ColorPalette.accentColor : ColorPalette.primaryTextColor,
              ),
              onPressed: () {
                setState(() {
                  isShuffleMode = !isShuffleMode;
                });
                _showSnackBar(
                  isShuffleMode 
                    ? 'Shuffle mode enabled for $selectedGenre' 
                    : 'Shuffle mode disabled',
                  isSuccess: true,
                );
              },
            ),
          ),
          
          // Refresh Button
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorPalette.darkShadowColor.withOpacity(ColorPalette.darkShadowOpacity),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: ColorPalette.lightShadowColor.withOpacity(ColorPalette.lightShadowOpacity),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: ColorPalette.primaryTextColor),
              onPressed: () {
                print('🔄 Manual refresh triggered');
                _refreshLibrary();
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingScreen()
          : Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorPalette.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ColorPalette.darkShadowColor.withOpacity(ColorPalette.darkShadowOpacity),
                      offset: const Offset(6, 6),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: ColorPalette.lightShadowColor.withOpacity(ColorPalette.lightShadowOpacity),
                      offset: const Offset(-6, -6),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildGenreTabs(screenWidth),
                    Expanded(
                      child: _buildSongsList(screenWidth, screenHeight),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ColorPalette.accentColor),
          SizedBox(height: 16),
          Text(
            'Loading your music library...',
            style: TextStyle(
              color: ColorPalette.hintTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreTabs(double screenWidth) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: ColorPalette.lightShadowColor.withOpacity(0.7),
            offset: const Offset(-2, -2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: ColorPalette.accentColor,
        unselectedLabelColor: ColorPalette.hintTextColor,
        indicatorColor: ColorPalette.accentColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.normal,
        ),
        onTap: (index) {
          setState(() {
            selectedGenre = genres[index];
          });
          print('📋 Selected genre: $selectedGenre');
        },
        tabs: genres.map((genre) {
          int count = 0;
          if (genre == 'All') {
            count = allSongs.length;
          } else {
            count = songsByGenre[genre]?.length ?? 0;
          }
          
          return Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(genre),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ColorPalette.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.025,
                        color: ColorPalette.accentColor,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSongsList(double screenWidth, double screenHeight) {
    List<Song> currentSongs = [];
    
    if (selectedGenre == 'All') {
      currentSongs = allSongs;
    } else {
      currentSongs = songsByGenre[selectedGenre] ?? [];
    }

    if (currentSongs.isEmpty) {
      return _buildEmptyState(screenWidth, screenHeight);
    }

    return RefreshIndicator(
      onRefresh: _refreshLibrary,
      color: ColorPalette.accentColor,
      child: Column(
        children: [
          // Play All Button
          if (currentSongs.isNotEmpty)
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(screenWidth * 0.04),
              child: _buildNeumorphicButton(
                onPressed: () => _playAllSongs(currentSongs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isShuffleMode ? Icons.shuffle : Icons.play_arrow,
                      color: ColorPalette.primaryTextColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isShuffleMode ? 'Shuffle All' : 'Play All',
                      style: TextStyle(
                        color: ColorPalette.primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Songs List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
              ),
              itemCount: currentSongs.length,
              itemBuilder: (context, index) {
                return _buildSongCard(currentSongs[index], screenWidth, index, currentSongs);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                color: ColorPalette.backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.darkShadowColor.withOpacity(0.3),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: ColorPalette.lightShadowColor.withOpacity(0.7),
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                selectedGenre == 'All' ? Icons.library_music : Icons.music_note,
                size: screenWidth * 0.12,
                color: ColorPalette.hintTextColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              selectedGenre == 'All' 
                  ? 'No songs in your library yet' 
                  : 'No $selectedGenre songs found',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: ColorPalette.primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              selectedGenre == 'All'
                  ? 'Add some songs from the Upload tab!'
                  : 'Try uploading some $selectedGenre music!',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: ColorPalette.hintTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildNeumorphicButton(
              onPressed: _refreshLibrary,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: ColorPalette.primaryTextColor),
                  SizedBox(width: 8),
                  Text(
                    'Refresh Library',
                    style: TextStyle(
                      color: ColorPalette.primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCard(Song song, double screenWidth, int index, List<Song> currentSongs) {
    final bool isFavorite = LibraryPageLogic.isSongFavorite(song);
    
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: ColorPalette.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(ColorPalette.darkShadowOpacity),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: ColorPalette.lightShadowColor.withOpacity(ColorPalette.lightShadowOpacity),
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorPalette.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.darkShadowColor.withOpacity(0.3),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: ColorPalette.lightShadowColor.withOpacity(0.7),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: song.thumbnail != null && song.thumbnail!.isNotEmpty
                    ? Image.network(
                        song.thumbnail!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildDefaultThumbnail(screenWidth);
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultThumbnail(screenWidth);
                        },
                      )
                    : _buildDefaultThumbnail(screenWidth),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.songName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: ColorPalette.primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    song.artist,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: ColorPalette.hintTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.005),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenWidth * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: ColorPalette.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          song.genre,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: ColorPalette.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (song.duration != null) ...[
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          song.duration!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: ColorPalette.hintTextColor,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          color: ColorPalette.hintTextColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? ColorPalette.romanticColor : ColorPalette.hintTextColor,
                  onPressed: () => _toggleFavorite(song),
                  screenWidth: screenWidth,
                ),
                SizedBox(width: screenWidth * 0.02),
                _buildActionButton(
                  icon: Icons.play_arrow,
                  color: ColorPalette.accentColor,
                  onPressed: () => _playSong(song, currentSongs),
                  screenWidth: screenWidth,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnail(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.music_note,
        color: ColorPalette.hintTextColor,
        size: screenWidth * 0.06,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: screenWidth * 0.08,
        height: screenWidth * 0.08,
        decoration: BoxDecoration(
          color: ColorPalette.backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ColorPalette.darkShadowColor.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: ColorPalette.lightShadowColor.withOpacity(0.7),
              offset: const Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: screenWidth * 0.04,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNeumorphicButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: ColorPalette.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null ? [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(ColorPalette.darkShadowOpacity),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: ColorPalette.lightShadowColor.withOpacity(ColorPalette.lightShadowOpacity),
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ] : [
          BoxShadow(
            color: ColorPalette.darkShadowColor.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }

  // Event handlers - delegate to logic layer
  Future<void> _toggleFavorite(Song song) async {
    try {
      final result = await LibraryPageLogic.toggleFavorite(song);
      
      if (result['action'] == 'select_genre') {
        await _showGenreSelectionDialog(song);
      } else if (result['action'] == 'removed') {
        setState(() {
          // Update UI to reflect favorite change
        });
        _showSnackBar(result['message']);
      }
    } catch (e) {
      _showSnackBar('Error removing from favorites: $e');
    }
  }

  Future<void> _showGenreSelectionDialog(Song song) async {
    // Get available genres (excluding 'All')
    List<String> availableGenres = genres.where((g) => g != 'All').toList();
    
    String? selectedGenreForFav = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorPalette.backgroundColor,
          title: Text(
            'Add to Favorites',
            style: TextStyle(color: ColorPalette.primaryTextColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select genre for "${song.songName}":',
                style: TextStyle(color: ColorPalette.primaryTextColor),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                width: double.maxFinite,
                child: availableGenres.isEmpty
                    ? Center(
                        child: Text(
                          'No genres available',
                          style: TextStyle(color: ColorPalette.hintTextColor),
                        ),
                      )
                    : ListView.builder(
                        itemCount: availableGenres.length,
                        itemBuilder: (context, index) {
                          final genre = availableGenres[index];
                          return ListTile(
                            title: Text(
                              genre,
                              style: TextStyle(color: ColorPalette.primaryTextColor),
                            ),
                            trailing: song.genre == genre 
                                ? Icon(Icons.star, color: ColorPalette.accentColor) 
                                : null,
                            onTap: () {
                              Navigator.of(context).pop(genre);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: ColorPalette.primaryTextColor),
              ),
            ),
          ],
        );
      },
    );

    if (selectedGenreForFav != null) {
      try {
        await LibraryPageLogic.addToFavorites(song, selectedGenreForFav);
        setState(() {
          // Update UI to reflect favorite change
        });
        _showSnackBar('Added to $selectedGenreForFav favorites!', isSuccess: true);
      } catch (e) {
        _showSnackBar('Error adding to favorites: $e');
      }
    }
  }

  void _playAllSongs(List<Song> songs) {
    if (songs.isEmpty) return;
    
    List<Song> playList = LibraryPageLogic.preparePlaylist(songs, isShuffleMode);
    
    _showSnackBar(
      isShuffleMode 
        ? 'Playing all $selectedGenre songs in shuffle mode' 
        : 'Playing all $selectedGenre songs',
      isSuccess: true,
    );
    
    _playSong(playList.first, playList);
  }

  Future<void> _playSong(Song song, List<Song> playlist) async {
    try {
      await LibraryPageLogic.addToRecentlyPlayed(song);
      
      // 🔥 CRITICAL: Use singleton HomePage instead of creating new instance
      await HomePageManager.playSongOnExistingPage(context, song);
      
    } catch (e) {
      LibraryPageErrors.showErrorSnackBar(context, e.toString());
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? ColorPalette.successColor : Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}