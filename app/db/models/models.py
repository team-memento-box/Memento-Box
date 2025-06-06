from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey, Table
from sqlalchemy.orm import relationship
from datetime import datetime
from ..database import Base, metadata

def get_table(name, *args, **kwargs):
    if name in metadata.tables:
        return metadata.tables[name]
    return Table(name, metadata, *args, **kwargs)

class User(Base):
    __table__ = get_table(
        "users",
        Column("id", Integer, primary_key=True, index=True),
        Column("username", String, unique=True, index=True),
        Column("email", String, unique=True, index=True),
        Column("full_name", String),
        Column("created_at", DateTime, default=datetime.utcnow),
        extend_existing=True
    )
    tests = relationship("DementiaTest", back_populates="user")
    photos = relationship("Photo", back_populates="user")

class Photo(Base):
    __table__ = get_table(
        "photos",
        Column("id", Integer, primary_key=True, index=True),
        Column("user_id", Integer, ForeignKey("users.id")),
        Column("filename", String),
        Column("filepath", String),
        Column("created_at", DateTime, default=datetime.utcnow),
        extend_existing=True
    )
    user = relationship("User", back_populates="photos")

class DementiaTest(Base):
    __table__ = get_table(
        "dementia_tests",
        Column("id", Integer, primary_key=True, index=True),
        Column("user_id", Integer, ForeignKey("users.id")),
        Column("test_date", DateTime, default=datetime.utcnow),
        Column("voice_analysis_score", Float),
        Column("image_analysis_score", Float),
        Column("story_analysis_score", Float),
        Column("chat_analysis_score", Float),
        Column("overall_score", Float),
        extend_existing=True
    )
    user = relationship("User", back_populates="tests")

class FishSpeech(Base):
    __table__ = get_table(
        "fish_speech",
        Column("id", Integer, primary_key=True, index=True),
        Column("user_id", Integer, ForeignKey("users.id")),
        Column("audio_file", String),
        Column("text_content", String),
        Column("created_at", DateTime, default=datetime.utcnow),
        extend_existing=True
    )

class Dialogue(Base):
    __table__ = get_table(
        "dialogues",
        Column("id", Integer, primary_key=True, index=True),
        Column("user_id", Integer, ForeignKey("users.id")),
        Column("content", String),
        Column("response", String),
        Column("created_at", DateTime, default=datetime.utcnow),
        extend_existing=True
    ) 