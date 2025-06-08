from sqlalchemy import Column, String, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from db.database import Base
from datetime import datetime
import uuid

class Family(Base):
    """
    families 테이블 모델
    """
    __tablename__ = 'families'
    __table_args__ = {
        "mysql_charset": "utf8mb4",
        "mysql_collate": "utf8mb4_general_ci"
    }

    # Primary Key
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    # 가족 코드
    family_code = Column(String, nullable=False, unique=True)
    # 생성 일자
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # 관계 설정
    # Family ↔ Photo
    photos = relationship("Photo", back_populates="family", cascade="all, delete-orphan") 