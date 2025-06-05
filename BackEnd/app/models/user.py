from sqlalchemy import Column, String, DateTime, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
import uuid
from app.database import Base

class User(Base):
    __tablename__ = "users"
    __table_args__ = {
        "mysql_charset": "utf8mb4",
        "mysql_collate": "utf8mb4_general_ci"
    }

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    kakao_id = Column(String, index=True, nullable=False)
    username = Column(String, nullable=False)
    email = Column(String, nullable=True)  # ✅ 추가
    gender = Column(String, nullable=True)
    birthday = Column(DateTime, nullable=True)
    profile_img = Column(Text, nullable=True)
    family_id = Column(UUID(as_uuid=True), ForeignKey('families.id'), nullable=True)
    family_role = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
