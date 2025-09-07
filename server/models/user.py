from sqlalchemy import Column, Text, VARCHAR, Integer
from sqlalchemy.orm import relationship
from models.base import Base

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(VARCHAR(50))
    email = Column(VARCHAR(50), unique=True)
    password = Column(Text)
    
    # Add relationship to songs
    songs = relationship("Song", back_populates="user")