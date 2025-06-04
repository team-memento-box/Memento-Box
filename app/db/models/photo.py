
from sqlalchemy import Column, String, DateTime, Text, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from db.database import Base
from sqlalchemy.orm import relationship
from uuid import uuid4
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

    # 사진 id
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    # 사진명
    photo_name = Column(Text, nullable=True)
    # 사진 저장소 주소
    photo_url = Column(Text)
    # 촬영 연도
    story_year = Column(DateTime, nullable=True)
    # 촬영 계정
    story_season = Column(String, nullable=True)
    # 넛지
    story_nudge = Column(JSON, nullable=True)
    # 요약 텍스트
    summary_text = Column(Text, nullable=True)
    # 요약 음성 주소
    summary_voice = Column(Text, nullable=True)
    # 외래 키 (foreign key)
    family_id = Column(UUID(as_uuid=True), ForeignKey('families.id'), nullable=False)  # nullable=False로 설정
    # 업로드 일자
    uploaded_at = Column(DateTime, default=datetime.utcnow)  # 자동생성 부여
    # Family ↔ Photo 
    family_photo = relationship("Family", back_populates="photo")
    # Photo ↔ Conversation 
    conversation = relationship("Conversation", back_populates="photo_conversation")
    