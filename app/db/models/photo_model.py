from sqlalchemy import Column, String, DateTime, Text, ForeignKey, JSON, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from db.database import Base
from datetime import datetime

class Photo(Base):
    """
    photos 테이블 모델
    """
    __tablename__ = 'photos'
    __table_args__ = {
        "mysql_charset": "utf8mb4",
        "mysql_collate": "utf8mb4_general_ci" 
    }

    # Primary Key
    id = Column(Integer, primary_key=True, autoincrement=True)
    # 사진 제목 (원본 파일명)
    title = Column(String, nullable=True)
    # 사진 설명
    description = Column(String, nullable=True)
    # 사진 저장소 주소 (Azure Blob Storage URL)
    image_url = Column(String, nullable=False)
    # 로컬 저장 경로
    image_path = Column(String, nullable=True)
    # 촬영 연도
    story_year = Column(String, nullable=True)
    # 촬영 계절
    story_season = Column(String, nullable=True)
    # 넛지
    story_nudge = Column(JSON, nullable=True)
    # 이미지 분석 결과
    analysis = Column(JSON, nullable=True)
    # 요약 텍스트
    summary_text = Column(Text, nullable=True)
    # 요약 음성 주소
    summary_voice = Column(Text, nullable=True)
    # 가족 ID (외래 키)
    family_id = Column(UUID(as_uuid=True), ForeignKey('families.id'), nullable=False)
    # 업로드 일자
    uploaded_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # 관계 설정
    # Photo ↔ Family
    family = relationship("Family", back_populates="photos")
    # Photo ↔ Conversation 
    conversations = relationship("Conversation", back_populates="photo", cascade="all, delete-orphan") 