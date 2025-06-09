from sqlalchemy import Column, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from db.database import Base
from sqlalchemy.orm import relationship

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
    id = Column(UUID(as_uuid=True), primary_key=True)
    # 관계 사진 id
    photo_id = Column(UUID(as_uuid=True), ForeignKey('photos.id'))
    # 실행 일자
    created_at = Column(DateTime)
    # Photo ↔ Conversation 
    photo_conversation = relationship("Photo", back_populates="conversation")
    # Conversation ↔ Mention
    mention = relationship("Mention", back_populates="conv_mention")
    # Conversation ↔ AnomaliesReport
    report = relationship("AnomaliesReport", back_populates="conv_report")