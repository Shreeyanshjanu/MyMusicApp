from pydantic import BaseModel
from typing import Optional

class SongBase(BaseModel):
    song_name: str
    artist: str
    genre: str
    audio_path: str
    video_path: Optional[str] = None
    thumbnail: Optional[str] = None
    duration: Optional[str] = None

class SongCreate(BaseModel):
    """Schema for creating songs - supports both manual entry and YouTube URLs"""
    # For manual song creation
    song_name: Optional[str] = None
    artist: Optional[str] = None
    genre: str  # Genre is required
    audio_path: Optional[str] = None
    video_path: Optional[str] = None
    thumbnail: Optional[str] = None
    duration: Optional[str] = None
    
    # For YouTube URL processing
    youtube_url: Optional[str] = None
    video_id: Optional[str] = None

class SongResponse(SongBase):
    id: int
    user_id: int
    youtube_url: Optional[str] = None  # Include YouTube URL in response
    video_id: Optional[str] = None     # Include video ID in response

    class Config:
        from_attributes = True