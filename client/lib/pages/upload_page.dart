
import 'package:client/colors/color_pallete.dart';
import 'package:client/errors/upload_page_error.dart';
import 'package:flutter/material.dart';
import '../logic/upload_page_logic.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  
  YouTubeVideoInfo? _extractedVideo;
  String? selectedGenre;
  bool _isExtracting = false;
  bool _isUploading = false;
  bool _isCustomGenre = false;
  bool _isLoadingGenres = true;
  
  List<String> availableGenres = [];

  @override
  void initState() {
    super.initState();
    
    // Check authentication and load genres
    if (!UploadPageLogic.validateAuthentication(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    } else {
      _loadExistingGenres();
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _genreController.dispose();
    UploadPageLogic.dispose();
    super.dispose();
  }

  // Load existing genres from server
  Future<void> _loadExistingGenres() async {
    try {
      final genres = await UploadPageLogic.loadExistingGenres();
      setState(() {
        availableGenres = genres;
        _isLoadingGenres = false;
        
        // Set default genre if genres exist
        if (availableGenres.isNotEmpty) {
          selectedGenre = availableGenres.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingGenres = false;
        availableGenres = [];
      });
    }
  }

  // Update genres list (callback for logic layer)
  void _updateGenres(List<String> newGenres) {
    setState(() {
      availableGenres = UploadPageLogic.updateGenresList(availableGenres, newGenres);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Add Song',
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
          // Show user info
          if (UploadPageLogic.getCurrentUserInfo() != null)
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.04),
              child: Center(
                child: Text(
                  'Hi, ${UploadPageLogic.getCurrentUserInfo()!['name']}',
                  style: TextStyle(
                    color: ColorPalette.hintTextColor,
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Container(
                width: double.infinity,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // URL Input Section
                    _buildUrlInputSection(screenWidth, screenHeight),
                    
                    SizedBox(height: screenHeight * 0.03),
                    
                    // Show extracted video info and genre selection
                    if (_extractedVideo != null) ...[
                      _buildExtractedVideoInfo(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.03),
                      _buildGenreSelection(screenWidth),
                      SizedBox(height: screenHeight * 0.04),
                      _buildUploadButton(screenWidth),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlInputSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paste YouTube Link',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: ColorPalette.primaryTextColor,
          ),
        ),
        SizedBox(height: screenHeight * 0.025),
        
        Container(
          decoration: BoxDecoration(
            color: ColorPalette.backgroundColor,
            borderRadius: BorderRadius.circular(12),
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
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'Paste YouTube URL here',
              hintStyle: TextStyle(
                color: ColorPalette.hintTextColor.withOpacity(ColorPalette.hintTextOpacity),
                fontSize: screenWidth * 0.035,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.035,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.content_paste,
                  color: ColorPalette.hintTextColor,
                  size: screenWidth * 0.05,
                ),
                onPressed: _pasteFromClipboard,
              ),
            ),
            style: TextStyle(
              color: ColorPalette.primaryTextColor,
              fontSize: screenWidth * 0.035,
            ),
            maxLines: 2,
            minLines: 1,
          ),
        ),
        
        SizedBox(height: screenHeight * 0.025),
        
        _buildNeumorphicButton(
          onPressed: _isExtracting ? null : _extractSongInfo,
          child: _isExtracting
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorPalette.primaryTextColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Extracting...',
                      style: TextStyle(
                        color: ColorPalette.primaryTextColor,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_fix_high,
                      color: ColorPalette.primaryTextColor,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Extract Song Info',
                      style: TextStyle(
                        color: ColorPalette.primaryTextColor,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildExtractedVideoInfo(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Container(
          width: screenWidth * 0.5,
          height: screenWidth * 0.28,
          decoration: BoxDecoration(
            color: ColorPalette.backgroundColor,
            borderRadius: BorderRadius.circular(12),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _extractedVideo!.thumbnailUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: ColorPalette.primaryTextColor,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: ColorPalette.backgroundColor,
                  child: Icon(
                    Icons.music_note,
                    size: 60,
                    color: ColorPalette.hintTextColor,
                  ),
                );
              },
            ),
          ),
        ),
        
        SizedBox(height: screenHeight * 0.02),
        
        Text(
          _extractedVideo!.title,
          style: TextStyle(
            fontSize: screenWidth * 0.042,
            fontWeight: FontWeight.w600,
            color: ColorPalette.primaryTextColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: screenHeight * 0.01),
        
        Text(
          _extractedVideo!.artist,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: ColorPalette.hintTextColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: screenHeight * 0.005),
        
        Text(
          UploadPageLogic.formatDuration(_extractedVideo!.duration),
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: ColorPalette.hintTextColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGenreSelection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select or Create Genre',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: ColorPalette.primaryTextColor,
          ),
        ),
        SizedBox(height: 15),
        
        if (_isLoadingGenres)
          Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: ColorPalette.accentColor,
                strokeWidth: 2,
              ),
            ),
          )
        else ...[
          // Toggle between existing and custom genre
          Row(
            children: [
              Expanded(
                child: _buildGenreToggleButton(
                  text: 'Existing Genres',
                  isSelected: !_isCustomGenre,
                  onTap: () {
                    setState(() {
                      _isCustomGenre = false;
                      if (availableGenres.isNotEmpty) {
                        selectedGenre = availableGenres.first;
                      }
                    });
                  },
                  screenWidth: screenWidth,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildGenreToggleButton(
                  text: 'Create New',
                  isSelected: _isCustomGenre,
                  onTap: () {
                    setState(() {
                      _isCustomGenre = true;
                      selectedGenre = null;
                      _genreController.clear();
                    });
                  },
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 15),
          
          // Genre selection based on mode
          if (!_isCustomGenre) ...[
            // Existing genres dropdown
            if (availableGenres.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: ColorPalette.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
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
                child: DropdownButtonFormField<String>(
                  value: selectedGenre,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  dropdownColor: ColorPalette.backgroundColor,
                  items: availableGenres.map((genre) {
                    return DropdownMenuItem(
                      value: genre,
                      child: Text(
                        genre,
                        style: TextStyle(
                          color: ColorPalette.primaryTextColor,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGenre = value!;
                    });
                  },
                  style: TextStyle(
                    color: ColorPalette.primaryTextColor,
                    fontSize: screenWidth * 0.04,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: ColorPalette.hintTextColor,
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorPalette.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
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
                child: Text(
                  'No existing genres found. Create a new one!',
                  style: TextStyle(
                    color: ColorPalette.hintTextColor,
                    fontSize: screenWidth * 0.035,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ] else ...[
            // Custom genre input
            Container(
              decoration: BoxDecoration(
                color: ColorPalette.backgroundColor,
                borderRadius: BorderRadius.circular(12),
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
              child: TextField(
                controller: _genreController,
                decoration: InputDecoration(
                  hintText: 'Enter genre name (e.g., "Pop", "Jazz")',
                  hintStyle: TextStyle(
                    color: ColorPalette.hintTextColor.withOpacity(0.7),
                    fontSize: screenWidth * 0.035,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.035,
                  ),
                  suffixIcon: Icon(
                    Icons.music_note,
                    color: ColorPalette.hintTextColor,
                    size: screenWidth * 0.05,
                  ),
                ),
                style: TextStyle(
                  color: ColorPalette.primaryTextColor,
                  fontSize: screenWidth * 0.04,
                ),
                onChanged: (value) {
                  setState(() {
                    selectedGenre = value.trim();
                  });
                },
                textCapitalization: TextCapitalization.words,
              ),
            ),
            
            // Genre suggestions
            SizedBox(height: 10),
            Text(
              'Suggestions:',
              style: TextStyle(
                color: ColorPalette.hintTextColor,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UploadPageLogic.getSuggestionGenres().take(12).map((genre) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _genreController.text = genre;
                      selectedGenre = genre;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ColorPalette.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: ColorPalette.accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        color: ColorPalette.accentColor,
                        fontSize: screenWidth * 0.028,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildGenreToggleButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.accentColor.withOpacity(0.2) : ColorPalette.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? ColorPalette.accentColor : ColorPalette.hintTextColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: ColorPalette.accentColor.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
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
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? ColorPalette.accentColor : ColorPalette.primaryTextColor,
            fontSize: screenWidth * 0.035,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildUploadButton(double screenWidth) {
    bool canUpload = UploadPageLogic.validateFormState(
      extractedVideo: _extractedVideo,
      selectedGenre: selectedGenre,
      isUploading: _isUploading,
    );
    
    return _buildNeumorphicButton(
      onPressed: canUpload ? _uploadSong : null,
      child: _isUploading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorPalette.primaryTextColor,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Adding to Library...',
                  style: TextStyle(
                    color: ColorPalette.primaryTextColor,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.library_add,
                  color: canUpload ? ColorPalette.primaryTextColor : ColorPalette.hintTextColor,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: 8),
                Text(
                  canUpload ? 'Add Song to Library' : 'Select Genre to Continue',
                  style: TextStyle(
                    color: canUpload ? ColorPalette.primaryTextColor : ColorPalette.hintTextColor,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNeumorphicButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return Container(
      height: 55,
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

  // UI Event Handlers - delegate to logic layer
  Future<void> _pasteFromClipboard() async {
    final pastedText = await UploadPageLogic.pasteFromClipboard(context);
    if (pastedText != null) {
      setState(() {
        _urlController.text = pastedText;
      });
    }
  }

  Future<void> _extractSongInfo() async {
    setState(() {
      _isExtracting = true;
    });

    try {
      final videoInfo = await UploadPageLogic.extractSongInfo(context, _urlController.text.trim());
      setState(() {
        _extractedVideo = videoInfo;
        _urlController.clear();
      });
    } catch (e) {
      UploadPageErrors.showErrorSnackBar(context, e.toString());
    } finally {
      setState(() {
        _isExtracting = false;
      });
    }
  }

  Future<void> _uploadSong() async {
    setState(() => _isUploading = true);

    try {
      final success = await UploadPageLogic.uploadSong(
        context: context,
        extractedVideo: _extractedVideo!,
        selectedGenre: selectedGenre!,
        updateGenres: _updateGenres,
      );

      if (success) {
        // Clear form data
        UploadPageLogic.clearFormData(
          clearExtractedVideo: () => _extractedVideo = null,
          clearSelectedGenre: () => selectedGenre = null,
          setCustomGenre: (value) => _isCustomGenre = value,
          genreController: _genreController,
        );
        
        setState(() {});
        
        // Navigate back with result
        UploadPageLogic.navigateBackWithResult(context, true);
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }
}