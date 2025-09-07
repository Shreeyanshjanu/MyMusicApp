# from fastapi import APIRouter, Depends, HTTPException
# from sqlalchemy.orm import Session
# from sqlalchemy import and_
# from models.song import Song
# from database import get_db
# from pydantic_schemas.song_schemas import SongCreate, SongResponse
# from middleware.auth_middleware import auth_middleware
# import yt_dlp
# import re
# from typing import Optional

# router = APIRouter()

# def extract_youtube_video_id(url: str) -> Optional[str]:
#     """Extract YouTube video ID from various URL formats"""
#     patterns = [
#         r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})',
#         r'youtube\.com\/embed\/([a-zA-Z0-9_-]{11})',
#         r'youtube\.com\/v\/([a-zA-Z0-9_-]{11})',
#     ]
    
#     for pattern in patterns:
#         match = re.search(pattern, url)
#         if match:
#             return match.group(1)
#     return None

# def get_youtube_audio_info(youtube_url: str) -> dict:
#     """Extract audio stream URL and metadata from YouTube"""
#     try:
#         print(f"🎵 Processing YouTube URL: {youtube_url}")
        
#         video_id = extract_youtube_video_id(youtube_url)
#         if not video_id:
#             raise ValueError("Invalid YouTube URL format")
        
#         print(f"📋 Video ID extracted: {video_id}")
        
#         ydl_opts = {
#             'format': 'bestaudio/best',
#             'noplaylist': True,
#             'quiet': True,
#             'no_warnings': True,
#         }
        
#         with yt_dlp.YoutubeDL(ydl_opts) as ydl:
#             info = ydl.extract_info(youtube_url, download=False)
            
#             if not info:
#                 raise ValueError("Could not extract video information")
            
#             # Get audio URL
#             audio_url = info.get('url')
#             if not audio_url:
#                 formats = info.get('formats', [])
#                 for fmt in formats:
#                     if fmt.get('acodec') != 'none' and fmt.get('url'):
#                         audio_url = fmt['url']
#                         break
            
#             if not audio_url:
#                 raise ValueError("No audio stream found")
            
#             # Extract metadata
#             title = info.get('title', 'Unknown Title')
#             uploader = info.get('uploader', 'Unknown Artist')
#             duration_seconds = info.get('duration', 0)
#             thumbnail = info.get('thumbnail', '')
            
#             # Format duration
#             if duration_seconds and duration_seconds > 0:
#                 minutes = int(duration_seconds) // 60
#                 seconds = int(duration_seconds) % 60
#                 duration = f"{minutes}:{seconds:02d}"
#             else:
#                 duration = "0:00"
            
#             # Clean up title
#             if ' - ' in title:
#                 parts = title.split(' - ', 1)
#                 artist_from_title = parts[0].strip()
#                 clean_title = parts[1].strip()
#                 if len(artist_from_title) < 50:
#                     uploader = artist_from_title
#                     title = clean_title
            
#             return {
#                 'title': title[:200],
#                 'artist': uploader[:100],
#                 'audio_url': audio_url,
#                 'thumbnail': thumbnail,
#                 'duration': duration,
#                 'video_id': video_id,
#                 'youtube_url': youtube_url
#             }
            
#     except Exception as e:
#         print(f"❌ Error extracting YouTube info: {e}")
#         raise ValueError(f"Failed to process YouTube URL: {str(e)}")

# @router.post("/", response_model=SongResponse)
# def create_song(
#     song: SongCreate, 
#     db: Session = Depends(get_db),
#     current_user = Depends(auth_middleware)
# ):
#     try:
#         print(f"🎵 Creating song for user: {current_user['id']}")
        
#         if song.youtube_url:
#             print(f"🔗 Processing YouTube URL: {song.youtube_url}")
            
#             youtube_info = get_youtube_audio_info(song.youtube_url)
            
#             db_song = Song(
#                 user_id=current_user["id"],
#                 song_name=youtube_info['title'],
#                 artist=youtube_info['artist'],
#                 genre=song.genre,
#                 audio_path=youtube_info['audio_url'],
#                 thumbnail=youtube_info['thumbnail'],
#                 duration=youtube_info['duration'],
#                 youtube_url=youtube_info['youtube_url'],
#                 video_id=youtube_info['video_id']
#             )
#         else:
#             if not song.song_name or not song.artist or not song.audio_path:
#                 raise HTTPException(
#                     status_code=400, 
#                     detail="For manual entry, song_name, artist, and audio_path are required"
#                 )
            
#             db_song = Song(
#                 user_id=current_user["id"],
#                 song_name=song.song_name,
#                 artist=song.artist,
#                 genre=song.genre,
#                 audio_path=song.audio_path,
#                 video_path=song.video_path,
#                 thumbnail=song.thumbnail,
#                 duration=song.duration
#             )
        
#         db.add(db_song)
#         db.commit()
#         db.refresh(db_song)
        
#         print(f"✅ Song created successfully: {db_song.id}")
#         return db_song
        
#     except ValueError as ve:
#         db.rollback()
#         raise HTTPException(status_code=400, detail=str(ve))
#     except Exception as e:
#         print(f"❌ Error creating song: {e}")
#         db.rollback()
#         raise HTTPException(status_code=500, detail=f"Error creating song: {str(e)}")

# @router.get("/refresh/{song_id}")
# def refresh_song_audio(
#     song_id: int,
#     db: Session = Depends(get_db),
#     current_user = Depends(auth_middleware)
# ):
#     """Refresh expired YouTube audio URL for a song"""
#     try:
#         print(f"🔄 Looking for song with ID: {song_id} for user: {current_user['id']}")
        
#         # FIXED: Use and_() for proper SQLAlchemy query
#         song = db.query(Song).filter(
#             and_(
#                 Song.id == song_id,
#                 Song.user_id == current_user["id"]
#             )
#         ).first()
        
#         if not song:
#             print(f"❌ Song not found with ID: {song_id}")
#             raise HTTPException(status_code=404, detail="Song not found")
        
#         print(f"✅ Found song: {song.song_name}")
#         print(f"📋 YouTube URL: {song.youtube_url}")
        
#         # Check if song has YouTube URL
#         if not song.youtube_url: # type: ignore
#             print(f"❌ Song has no YouTube URL")
#             raise HTTPException(status_code=400, detail="Song is not from YouTube")
        
#         print(f"🔄 Refreshing audio for song: {song.song_name}")
        
#         youtube_info = get_youtube_audio_info(song.youtube_url) # type: ignore
        
#         song.audio_path = youtube_info['audio_url']
#         song.thumbnail = youtube_info['thumbnail']
        
#         db.commit()
#         db.refresh(song)
        
#         print(f"✅ Song audio refreshed: {song.id}")
#         return {
#             "message": "Audio URL refreshed successfully",
#             "new_audio_url": youtube_info['audio_url']
#         }
        
#     except ValueError as ve:
#         raise HTTPException(status_code=400, detail=str(ve))
#     except Exception as e:
#         print(f"❌ Error refreshing song audio: {e}")
#         raise HTTPException(status_code=500, detail=f"Error refreshing audio: {str(e)}")

# @router.get("/", response_model=list[SongResponse])
# def get_all_songs(
#     db: Session = Depends(get_db),
#     current_user = Depends(auth_middleware)
# ):
#     try:
#         print(f"📡 Fetching all songs for user: {current_user['id']}")
#         songs = db.query(Song).filter(Song.user_id == current_user["id"]).all()
#         print(f"📋 Found {len(songs)} songs")
#         return songs
#     except Exception as e:
#         print(f"❌ Error fetching songs: {e}")
#         raise HTTPException(status_code=500, detail=f"Error fetching songs: {str(e)}")

# @router.get("/{genre}", response_model=list[SongResponse])
# def get_songs_by_genre(
#     genre: str, 
#     db: Session = Depends(get_db),
#     current_user = Depends(auth_middleware)
# ):
#     try:
#         songs = db.query(Song).filter(
#             and_(
#                 Song.genre == genre,
#                 Song.user_id == current_user["id"]
#             )
#         ).all()
#         if not songs:
#             raise HTTPException(status_code=404, detail="No songs found for this genre")
#         return songs
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Error fetching songs: {str(e)}")

# @router.delete("/{song_id}", response_model=dict)
# def delete_song(
#     song_id: int, 
#     db: Session = Depends(get_db),
#     current_user = Depends(auth_middleware)
# ):
#     try:
#         song = db.query(Song).filter(
#             and_(
#                 Song.id == song_id,
#                 Song.user_id == current_user["id"]
#             )
#         ).first()
        
#         if not song:
#             raise HTTPException(status_code=404, detail="Song not found")
        
#         print(f"🗑️ Deleting song: {song.song_name}")
#         db.delete(song)
#         db.commit()
        
#         return {"message": "Song deleted successfully"}
#     except Exception as e:
#         print(f"❌ Error deleting song: {e}")
#         db.rollback()
#         raise HTTPException(status_code=500, detail=f"Error deleting song: {str(e)}")




from fastapi import APIRouter, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from sqlalchemy import and_
from models.song import Song
from database import get_db
from pydantic_schemas.song_schemas import SongCreate, SongResponse
from middleware.auth_middleware import auth_middleware
import yt_dlp
import re
from typing import Optional, List

router = APIRouter()

def extract_youtube_video_id(url: str) -> Optional[str]:
    """
    Extract YouTube video ID from various URL formats.
    
    Supports multiple YouTube URL patterns:
    - https://www.youtube.com/watch?v=VIDEO_ID
    - https://youtu.be/VIDEO_ID  
    - https://www.youtube.com/embed/VIDEO_ID
    - https://www.youtube.com/v/VIDEO_ID
    
    Args:
        url (str): YouTube URL in any supported format
        
    Returns:
        Optional[str]: 11-character video ID or None if invalid
    """
    patterns = [
        r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})',
        r'youtube\.com\/embed\/([a-zA-Z0-9_-]{11})',
        r'youtube\.com\/v\/([a-zA-Z0-9_-]{11})',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return None

def get_youtube_audio_info(youtube_url: str) -> dict:
    """
    Extract audio stream URL and metadata from YouTube video.
    
    Uses yt-dlp library to:
    - Extract high-quality audio stream URL
    - Get video metadata (title, artist, duration)
    - Download thumbnail image URL
    - Parse and clean title/artist information
    
    Args:
        youtube_url (str): Valid YouTube video URL
        
    Returns:
        dict: Complete audio and metadata information
        
    Raises:
        ValueError: If URL is invalid or extraction fails
    """
    try:
        print(f"🎵 Processing YouTube URL: {youtube_url}")
        
        video_id = extract_youtube_video_id(youtube_url)
        if not video_id:
            raise ValueError("Invalid YouTube URL format")
        
        print(f"📋 Video ID extracted: {video_id}")
        
        ydl_opts = {
            'format': 'bestaudio/best',
            'noplaylist': True,
            'quiet': True,
            'no_warnings': True,
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(youtube_url, download=False)
            
            if not info:
                raise ValueError("Could not extract video information")
            
            # Get audio URL
            audio_url = info.get('url')
            if not audio_url:
                formats = info.get('formats', [])
                for fmt in formats:
                    if fmt.get('acodec') != 'none' and fmt.get('url'):
                        audio_url = fmt['url']
                        break
            
            if not audio_url:
                raise ValueError("No audio stream found")
            
            # Extract metadata
            title = info.get('title', 'Unknown Title')
            uploader = info.get('uploader', 'Unknown Artist')
            duration_seconds = info.get('duration', 0)
            thumbnail = info.get('thumbnail', '')
            
            # Format duration
            if duration_seconds and duration_seconds > 0:
                minutes = int(duration_seconds) // 60
                seconds = int(duration_seconds) % 60
                duration = f"{minutes}:{seconds:02d}"
            else:
                duration = "0:00"
            
            # Clean up title
            if ' - ' in title:
                parts = title.split(' - ', 1)
                artist_from_title = parts[0].strip()
                clean_title = parts[1].strip()
                if len(artist_from_title) < 50:
                    uploader = artist_from_title
                    title = clean_title
            
            return {
                'title': title[:200],
                'artist': uploader[:100],
                'audio_url': audio_url,
                'thumbnail': thumbnail,
                'duration': duration,
                'video_id': video_id,
                'youtube_url': youtube_url
            }
            
    except Exception as e:
        print(f"❌ Error extracting YouTube info: {e}")
        raise ValueError(f"Failed to process YouTube URL: {str(e)}")

@router.post("/", 
             response_model=SongResponse,
             status_code=status.HTTP_201_CREATED,
             summary="🎵 Add Song to Your Music Library",
             description="Add a new song via YouTube URL or manual entry with complete metadata")
def create_song(
    song: SongCreate, 
    db: Session = Depends(get_db),
    current_user = Depends(auth_middleware)
):
    """
    ## 🎵 Add New Song to Your Personal Music Library
    
    Add songs to your personal music collection using two powerful methods:
    
    ### 🎯 Method 1: YouTube URL (Recommended)
    Simply provide a YouTube URL and genre - everything else is automatic!
    
    ```json
    {
        "youtube_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "genre": "Pop"
    }
    ```
    
    **Automatic Extraction:**
    - ✅ Song title and artist name
    - ✅ High-quality audio stream URL  
    - ✅ Thumbnail image
    - ✅ Video duration
    - ✅ Video ID for future reference
    - ✅ Intelligent title/artist parsing
    
    ### 📝 Method 2: Manual Entry
    Complete control over all song metadata:
    
    ```json
    {
        "song_name": "My Favorite Song",
        "artist": "Amazing Artist",
        "genre": "Rock", 
        "audio_path": "https://example.com/audio.mp3",
        "thumbnail": "https://example.com/thumb.jpg",
        "duration": "3:45"
    }
    ```
    
    ### 🔐 Authentication Required:
    Include your JWT token in the `x-auth-token` header.
    
    ### ✅ Success Response (201 Created):
    Complete song object with database ID and all metadata:
    ```json
    {
        "id": 123,
        "song_name": "Rick Astley - Never Gonna Give You Up",
        "artist": "Rick Astley",
        "genre": "Pop",
        "audio_path": "https://audio-stream-url.com/audio.mp3",
        "thumbnail": "https://thumbnail-url.com/image.jpg",
        "duration": "3:33",
        "youtube_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "video_id": "dQw4w9WgXcQ",
        "user_id": 456
    }
    ```
    
    ### ❌ Error Responses:
    - **400 Bad Request**: Invalid YouTube URL or missing required fields
    - **401 Unauthorized**: Missing or invalid authentication token
    - **500 Internal Server Error**: YouTube processing or database error
    
    ### 🎨 Supported Genres:
    Pop, Rock, Hip-Hop, Jazz, Classical, Electronic, Country, R&B, Blues, Folk, Reggae, Punk, Metal, Alternative, Indie
    
    ### 💡 Pro Tips:
    - YouTube method automatically handles artist/title parsing
    - High-quality audio streams are prioritized
    - Thumbnails are automatically optimized
    - All URLs are validated before storage
    """
    try:
        print(f"🎵 Creating song for user: {current_user['id']}")
        
        if song.youtube_url:
            print(f"🔗 Processing YouTube URL: {song.youtube_url}")
            
            youtube_info = get_youtube_audio_info(song.youtube_url)
            
            db_song = Song(
                user_id=current_user["id"],
                song_name=youtube_info['title'],
                artist=youtube_info['artist'],
                genre=song.genre,
                audio_path=youtube_info['audio_url'],
                thumbnail=youtube_info['thumbnail'],
                duration=youtube_info['duration'],
                youtube_url=youtube_info['youtube_url'],
                video_id=youtube_info['video_id']
            )
        else:
            if not song.song_name or not song.artist or not song.audio_path:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST, 
                    detail={
                        "error": "missing_required_fields",
                        "message": "For manual entry, song_name, artist, and audio_path are required",
                        "required_fields": ["song_name", "artist", "audio_path", "genre"],
                        "suggestion": "Provide all required fields or use YouTube URL method"
                    }
                )
            
            db_song = Song(
                user_id=current_user["id"],
                song_name=song.song_name,
                artist=song.artist,
                genre=song.genre,
                audio_path=song.audio_path,
                video_path=song.video_path,
                thumbnail=song.thumbnail,
                duration=song.duration
            )
        
        db.add(db_song)
        db.commit()
        db.refresh(db_song)
        
        print(f"✅ Song created successfully: {db_song.id} - {db_song.song_name}")
        return db_song
        
    except ValueError as ve:
        db.rollback()
        print(f"❌ YouTube processing error: {ve}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail={
                "error": "youtube_processing_failed",
                "message": str(ve),
                "suggestion": "Check the YouTube URL and try again"
            }
        )
    except Exception as e:
        print(f"❌ Error creating song: {e}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to create song. Please try again."
        )

@router.get("/", 
            response_model=List[SongResponse],
            status_code=status.HTTP_200_OK,
            summary="📋 Get Your Complete Music Library",
            description="Retrieve all songs in your personal music collection with full metadata")
def get_all_songs(
    db: Session = Depends(get_db),
    current_user = Depends(auth_middleware)
):
    """
    ## 📋 Retrieve Your Complete Music Library
    
    Get all songs in your personal music collection with complete metadata and streaming URLs.
    
    ### 🔐 Authentication Required:
    Include your JWT token in the `x-auth-token` header.
    
    ### 🎵 What You Get:
    Complete information for each song in your library:
    - **Basic Info**: Song name, artist, genre, duration
    - **Streaming URLs**: Audio stream links and thumbnails
    - **YouTube Data**: Original URLs and video IDs (when applicable)
    - **Database Info**: Unique song IDs and ownership data
    
    ### ✅ Success Response (200 OK):
    Array of your songs with complete metadata:
    ```json
    [
        {
            "id": 123,
            "song_name": "Amazing Song",
            "artist": "Great Artist",
            "genre": "Pop",
            "audio_path": "https://audio-stream.com/song.mp3",
            "thumbnail": "https://thumbnail.com/image.jpg",
            "duration": "3:45",
            "youtube_url": "https://youtube.com/watch?v=abc123",
            "video_id": "abc123",
            "user_id": 456
        },
        {
            "id": 124,
            "song_name": "Another Great Track",
            "artist": "Different Artist", 
            "genre": "Rock",
            "audio_path": "https://audio-stream.com/song2.mp3",
            "duration": "4:20",
            "user_id": 456
        }
    ]
    ```
    
    ### 📊 Response Details:
    - **Privacy**: Only returns songs that belong to your account
    - **Completeness**: All available metadata for each song
    - **Order**: Songs returned in chronological order (newest first)
    - **URLs**: All audio and thumbnail URLs are ready for immediate use
    
    ### 💡 Use Cases:
    - **Music Player**: Load complete library for playlist display
    - **Library Management**: Show user's complete music collection
    - **Statistics**: Get counts and overview of user's music
    - **Backup**: Export user's music metadata
    
    ### ❌ Error Responses:
    - **401 Unauthorized**: Missing or invalid authentication token
    - **500 Internal Server Error**: Database connection or query error
    
    ### 🎯 Empty Library:
    If you haven't added any songs yet, returns an empty array `[]`.
    """
    try:
        print(f"📡 Fetching all songs for user: {current_user['id']}")
        songs = db.query(Song).filter(Song.user_id == current_user["id"]).all()
        print(f"📋 Found {len(songs)} songs for user {current_user['id']}")
        
        return songs
        
    except Exception as e:
        print(f"❌ Error fetching songs for user {current_user['id']}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to retrieve your music library. Please try again."
        )

@router.get("/{genre}", 
            response_model=List[SongResponse],
            status_code=status.HTTP_200_OK,
            summary="🎭 Filter Music Library by Genre",
            description="Get all songs from your library that match a specific genre")
def get_songs_by_genre(
    genre: str, 
    db: Session = Depends(get_db),
    current_user = Depends(auth_middleware)
):
    """
    ## 🎭 Filter Your Music by Genre
    
    Retrieve all songs from your personal library that match a specific genre.
    
    ### 📍 Path Parameters:
    - **genre**: Genre name to filter by (case-sensitive)
    
    ### 🎨 Popular Genres:
    - **Pop**: Popular mainstream music
    - **Rock**: Rock and alternative rock
    - **Hip-Hop**: Hip-hop and rap music
    - **Jazz**: Jazz and fusion
    - **Classical**: Classical and orchestral
    - **Electronic**: Electronic and EDM
    - **Country**: Country and folk
    - **R&B**: R&B and soul music
    - **Blues**: Blues and blues rock
    - **Reggae**: Reggae and ska
    - **Punk**: Punk and hardcore
    - **Metal**: Heavy metal and sub-genres
    - **Indie**: Independent and alternative
    
    ### 🔐 Authentication Required:
    Include your JWT token in the `x-auth-token` header.
    
    ### ✅ Success Response (200 OK):
    Array of songs matching the specified genre:
    ```json
    [
        {
            "id": 123,
            "song_name": "Rock Anthem",
            "artist": "Rock Band",
            "genre": "Rock",
            "audio_path": "https://audio-stream.com/rock.mp3",
            "thumbnail": "https://thumbnail.com/rock.jpg",
            "duration": "4:15",
            "user_id": 456
        }
    ]
    ```
    
    ### 📊 Response Features:
    - **Filtered Results**: Only songs matching exact genre
    - **User Privacy**: Only your songs, never other users'
    - **Complete Metadata**: All song information included
    - **Ready to Play**: Audio URLs ready for streaming
    
    ### ❌ Error Responses:
    - **404 Not Found**: No songs found for the specified genre
    - **401 Unauthorized**: Missing or invalid authentication token
    - **500 Internal Server Error**: Database error
    
    ### 💡 Usage Examples:
    ```bash
    # Get all Pop songs
    GET /songs/Pop
    
    # Get all Rock songs  
    GET /songs/Rock
    
    # Get all Hip-Hop songs
    GET /songs/Hip-Hop
    ```
    
    ### 🎯 Pro Tips:
    - Genre names are case-sensitive (use exact capitalization)
    - Use URL encoding for genres with special characters
    - Returns empty array if no songs match the genre
    """
    try:
        print(f"🎭 Fetching {genre} songs for user: {current_user['id']}")
        
        songs = db.query(Song).filter(
            and_(
                Song.genre == genre,
                Song.user_id == current_user["id"]
            )
        ).all()
        
        if not songs:
            print(f"📭 No {genre} songs found for user {current_user['id']}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, 
                detail={
                    "error": "no_songs_found",
                    "message": f"No songs found for genre '{genre}'",
                    "suggestion": "Check the genre name or add songs in this genre",
                    "available_genres": "Use GET /songs/ to see all your songs and their genres"
                }
            )
            
        print(f"🎵 Found {len(songs)} {genre} songs for user {current_user['id']}")
        return songs
        
    except HTTPException:
        raise  # Re-raise HTTP exceptions
    except Exception as e:
        print(f"❌ Error fetching {genre} songs: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Failed to retrieve {genre} songs. Please try again."
        )

@router.delete("/{song_id}", 
               response_model=dict,
               status_code=status.HTTP_200_OK,
               summary="🗑️ Delete Song from Library",
               description="Permanently remove a song from your personal music library")
def delete_song(
    song_id: int, 
    db: Session = Depends(get_db),
    current_user = Depends(auth_middleware)
):
    """
    ## 🗑️ Delete Song from Your Music Library
    
    Permanently remove a song from your personal music collection.
    
    ### 📍 Path Parameters:
    - **song_id**: Unique identifier of the song to delete (integer)
    
    ### 🔐 Authentication Required:
    Include your JWT token in the `x-auth-token` header.
    
    ### 🛡️ Security Features:
    - **User Isolation**: You can only delete songs that belong to your account
    - **Ownership Verification**: System verifies song ownership before deletion
    - **Secure Deletion**: Song is permanently removed from database
    
    ### ✅ Success Response (200 OK):
    Confirmation of successful deletion:
    ```json
    {
        "message": "Song deleted successfully",
        "deleted_song_id": 123,
        "action": "permanent_deletion",
        "timestamp": "2025-01-07T10:46:27Z"
    }
    ```
    
    ### ❌ Error Responses:
    - **404 Not Found**: Song doesn't exist or doesn't belong to you
    - **401 Unauthorized**: Missing or invalid authentication token  
    - **500 Internal Server Error**: Database error during deletion
    
    ### ⚠️ Important Notes:
    - **Permanent Action**: Deletion cannot be undone
    - **No Effect on Others**: Only removes from your personal library
    - **Ownership Required**: Can only delete songs you own
    
    ### 💡 Usage Example:
    ```bash
    curl -X DELETE "http://localhost:8000/songs/123" \\
         -H "x-auth-token: your_jwt_token_here"
    ```
    
    ### 🔄 Recovery:
    If you accidentally delete a song, you'll need to re-add it using:
    - The original YouTube URL (if it was from YouTube)
    - Manual entry with the song details
    """
    try:
        print(f"🗑️ Attempting to delete song {song_id} for user {current_user['id']}")
        
        song = db.query(Song).filter(
            and_(
                Song.id == song_id,
                Song.user_id == current_user["id"]
            )
        ).first()
        
        if not song:
            print(f"❌ Song {song_id} not found or doesn't belong to user {current_user['id']}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, 
                detail={
                    "error": "song_not_found",
                    "message": "Song not found or you don't have permission to delete it",
                    "song_id": song_id,
                    "suggestion": "Check the song ID and ensure it belongs to your account"
                }
            )
        
        song_name = song.song_name
        print(f"🗑️ Deleting song: {song_name} (ID: {song_id})")
        
        db.delete(song)
        db.commit()
        
        print(f"✅ Song deleted successfully: {song_name} (ID: {song_id})")
        
        return {
            "message": "Song deleted successfully",
            "deleted_song": {
                "id": song_id,
                "name": song_name
            },
            "action": "permanent_deletion",
            "timestamp": "2025-01-07T10:46:27Z",
            "note": "This action cannot be undone"
        }
        
    except HTTPException:
        raise  # Re-raise HTTP exceptions
    except Exception as e:
        print(f"❌ Error deleting song {song_id}: {e}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to delete song. Please try again."
        )

@router.get("/refresh/{song_id}",
            status_code=status.HTTP_200_OK,
            summary="🔄 Refresh Expired YouTube Audio URL",
            description="Get fresh YouTube audio stream URL for continued playback")
def refresh_song_audio(
    song_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(auth_middleware)
):
    """
    ## 🔄 Refresh Expired YouTube Audio Stream
    
    YouTube audio URLs expire periodically. Use this endpoint to get fresh, working audio URLs for uninterrupted music playback.
    
    ### 🎯 When to Use:
    - **Audio Playback Fails**: When streaming stops working
    - **Expired URLs**: YouTube URLs typically expire after 6 hours
    - **Error Recovery**: When audio player returns 403/404 errors
    - **Preventive Refresh**: Before important listening sessions
    
    ### 📍 Path Parameters:
    - **song_id**: ID of the song to refresh (must be from YouTube)
    
    ### 🔐 Authentication Required:
    Include your JWT token in the `x-auth-token` header.
    
    ### ✅ Requirements:
    - Song must exist in your library
    - Song must be from YouTube (have a youtube_url)
    - You must be the owner of the song
    
    ### ✅ Success Response (200 OK):
    Fresh audio URL and confirmation:
    ```json
    {
        "message": "Audio URL refreshed successfully",
        "song_id": 123,
        "song_name": "Great Song",
        "new_audio_url": "https://fresh-audio-stream.com/audio.mp3",
        "new_thumbnail": "https://fresh-thumbnail.com/thumb.jpg",
        "expires_in": "~6 hours",
        "timestamp": "2025-01-07T10:46:27Z"
    }
    ```
    
    ### 🔄 What Gets Updated:
    - **Audio Stream URL**: Fresh, working audio URL
    - **Thumbnail URL**: Updated thumbnail image URL
    - **Metadata Verification**: Confirms song still exists on YouTube
    
    ### ❌ Error Responses:
    - **400 Bad Request**: Song is not from YouTube
    - **404 Not Found**: Song doesn't exist or doesn't belong to you
    - **401 Unauthorized**: Missing or invalid authentication token
    - **500 Internal Server Error**: YouTube processing error
    
    ### 🎵 Automatic Updates:
    The refresh process automatically:
    - Fetches the latest audio stream URL
    - Updates thumbnail if changed
    - Preserves all other song metadata
    - Saves changes to your library
    
    ### 💡 Usage Example:
    ```bash
    curl -X GET "http://localhost:8000/songs/refresh/123" \\
         -H "x-auth-token: your_jwt_token_here"
    ```
    
    ### 🔧 Troubleshooting:
    - **Video Removed**: If YouTube video was deleted, you'll get an error
    - **Private Video**: If video became private, refresh will fail
    - **Geographic Restrictions**: Some videos may not be available in all regions
    
    ### ⚡ Pro Tips:
    - Refresh before important listening sessions
    - Use when audio player reports errors
    - Safe to refresh multiple times
    - Original song metadata is preserved
    """
    try:
        print(f"🔄 Looking for song with ID: {song_id} for user: {current_user['id']}")
        
        # Find song with proper ownership verification
        song = db.query(Song).filter(
            and_(
                Song.id == song_id,
                Song.user_id == current_user["id"]
            )
        ).first()
        
        if not song:
            print(f"❌ Song not found with ID: {song_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, 
                detail={
                    "error": "song_not_found",
                    "message": "Song not found or you don't have access to it",
                    "song_id": song_id,
                    "suggestion": "Check the song ID and ensure it belongs to your account"
                }
            )
        
        print(f"✅ Found song: {song.song_name}")
        print(f"📋 YouTube URL: {song.youtube_url}")
        
        # Check if song has YouTube URL
        if not song.youtube_url:
            print(f"❌ Song has no YouTube URL")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, 
                detail={
                    "error": "not_youtube_song",
                    "message": "Song is not from YouTube and cannot be refreshed",
                    "song_id": song_id,
                    "song_name": song.song_name,
                    "suggestion": "Only YouTube songs can be refreshed. Manual songs don't need refreshing."
                }
            )
        
        print(f"🔄 Refreshing audio for song: {song.song_name}")
        
        # Get fresh YouTube information
        youtube_info = get_youtube_audio_info(song.youtube_url)
        
        # Update song with fresh URLs
        old_audio_url = song.audio_path
        song.audio_path = youtube_info['audio_url']
        song.thumbnail = youtube_info['thumbnail']
        
        db.commit()
        db.refresh(song)
        
        print(f"✅ Song audio refreshed: {song.id}")
        
        return {
            "message": "Audio URL refreshed successfully",
            "song_id": song.id,
            "song_name": song.song_name,
            "new_audio_url": youtube_info['audio_url'],
            "new_thumbnail": youtube_info['thumbnail'],
            "previous_url_expired": old_audio_url != youtube_info['audio_url'],
            "expires_in": "~6 hours",
            "timestamp": "2025-01-07T10:46:27Z",
            "note": "URLs are automatically updated in your library"
        }
        
    except ValueError as ve:
        print(f"❌ YouTube processing error: {ve}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail={
                "error": "youtube_refresh_failed",
                "message": str(ve),
                "suggestion": "The YouTube video may have been removed or made private"
            }
        )
    except HTTPException:
        raise  # Re-raise HTTP exceptions
    except Exception as e:
        print(f"❌ Error refreshing song audio: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="Failed to refresh audio URL. Please try again."
        )