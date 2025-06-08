from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from db.database import Base
from datetime import datetime
import uuid

class Conversation(Base):
    
    """
    conversations 테이블 모델

    대화 흐름 기반의 이상현상 보고를 고려함
    """
    __tablename__ = 'conversations'
    __table_args__ = {
        #"schema": "", # 파일명
        #"mysql_engine": "InnoDB",
        "mysql_charset": "utf8mb4", 
        "mysql_collate": "utf8mb4_general_ci" 
    }
    # 대화 회기 id
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    # 관계 사진 id
    photo_id = Column(Integer, ForeignKey('photos.id'), nullable=False)
    # 메시지
    message = Column(Text, nullable=False)
    # 응답
    response = Column(Text, nullable=True)
    # 실행 일자
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # 관계 설정
    # Conversation ↔ Photo
    photo = relationship("Photo", back_populates="conversations")
    # Conversation ↔ Mention
    mentions = relationship("Mention", back_populates="conversation")
    # Conversation ↔ AnomaliesReport
    reports = relationship("AnomaliesReport", back_populates="conversation")
