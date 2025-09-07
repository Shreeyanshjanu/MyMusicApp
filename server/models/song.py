

from sqlalchemy import Column, Integer, String, Text, ForeignKey
from sqlalchemy.orm import relationship
from models.base import Base

class Song(Base):
    __tablename__ = "songs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    song_name = Column(String(200), nullable=False)
    artist = Column(String(100), nullable=False)
    genre = Column(String(50), nullable=False)
    audio_path = Column(Text, nullable=False)
    video_path = Column(Text, nullable=True)
    thumbnail = Column(Text, nullable=True)
    duration = Column(String(20), nullable=True)
    youtube_url = Column(Text, nullable=True)
    video_id = Column(String(20), nullable=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    user = relationship("User", back_populates="songs")