from datetime import datetime
from typing import List, Optional, Dict, Any
from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

# SQLAlchemy 데이터베이스 모델들
class User(Base):
    __tablename__ = "users"
    
    id = Column(String, primary_key=True)
    kakao_id = Column(String)
    username = Column(String)
    gender = Column(String)
    birthday = Column(DateTime)
    profile_img = Column(Text)
    family_id = Column(String, ForeignKey("families.id"))
    family_role = Column(String)
    speak_vector = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    family = relationship("Family", back_populates="users")

class Family(Base):
    __tablename__ = "families"
    
    id = Column(String, primary_key=True)
    family_code = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    users = relationship("User", back_populates="family")
    photos = relationship("Photo", back_populates="family")
    anomaly_reports = relationship("AnomalyReport", back_populates="family")

class Photo(Base):
    __tablename__ = "photos"
    
    id = Column(String, primary_key=True)
    photo_name = Column(Text)
    photo_url = Column(Text)
    story_year = Column(DateTime)
    story_season = Column(String)
    story_nudge = Column(JSON)
    summary_text = Column(Text)
    summary_voice = Column(Text)
    family_id = Column(String, ForeignKey("families.id"))
    uploaded_at = Column(DateTime, default=datetime.utcnow)
    
    family = relationship("Family", back_populates="photos")
    mentions = relationship("Mention", back_populates="photo")

class Mention(Base):
    __tablename__ = "mentions"
    
    id = Column(String, primary_key=True)
    photo_id = Column(String, ForeignKey("photos.id"))
    question_answer = Column(JSON)
    recorded_at = Column(DateTime, default=datetime.utcnow)
    
    photo = relationship("Photo", back_populates="mentions")
    anomaly_reports = relationship("AnomalyReport", back_populates="mention")

class AnomalyReport(Base):
    __tablename__ = "anomalies_reports"
    
    id = Column(String, primary_key=True)
    mention_id = Column(String, ForeignKey("mentions.id"))
    event_interval = Column(String)
    family_id = Column(String, ForeignKey("families.id"))
    
    mention = relationship("Mention", back_populates="anomaly_reports")
    family = relationship("Family", back_populates="anomaly_reports")

# Pydantic 요청/응답 모델들
class PhotoUploadRequest(BaseModel):
    photo_name: str
    story_year: str
    story_season: str
    story_nudge: Dict[str, Any]
    family_id: str

class InitialQuestionRequest(BaseModel):
    photoId: str
    photoName: str
    storyYear: str
    storySession: str
    storyNudge: Dict[str, Any]
    mood: str
    keywords: List[str]

class FollowupQuestionRequest(BaseModel):
    photoId: str
    chatHistory: List[Dict[str, str]]

class ConversationSaveRequest(BaseModel):
    photoId: str
    turns: List[Dict[str, Any]]

class StoryGenerationRequest(BaseModel):
    mentionId: str

class AudioAnalysisRequest(BaseModel):
    photoId: str

class ReportRequest(BaseModel):
    mentionId: str

# 응답 모델들
class QuestionResponse(BaseModel):
    status: str
    question: str

class ConversationResponse(BaseModel):
    status: str
    mentionId: str

class StoryResponse(BaseModel):
    status: str
    mentionId: str
    storyText: str

class AudioResponse(BaseModel):
    status: str
    audioPath: str

class ReportResponse(BaseModel):
    status: str
    mentionId: str
    severity: str
    event_interval: str
    created_at: str

class PhotoListResponse(BaseModel):
    status: str
    data: List[Dict[str, Any]]

class ConversationDetailResponse(BaseModel):
    status: str
    mentionId: str
    turns: List[Dict[str, Any]]