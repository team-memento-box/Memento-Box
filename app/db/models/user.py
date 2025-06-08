from sqlalchemy import Column, String, DateTime, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
from db.database import Base
from sqlalchemy.orm import relationship
import uuid

class User(Base):
    """
    users 테이블 모델
    """
    __tablename__ = "users"
    __table_args__ = {
        #"schema": "", # 파일명
        #"mysql_engine": "InnoDB",
        "mysql_charset": "utf8mb4", 
        "mysql_collate": "utf8mb4_general_ci" 
    }
    # uuid
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    # kakao 로그인 정보
    kakao_id = Column(String, unique=True, nullable=False)
    # 이메일
    email = Column(String, unique=True, nullable=True)
    # 닉네임
    nickname = Column(String, nullable=True)
    # 프로필 이미지
    profile_image = Column(String, nullable=True)
    # 관계 가족 id
    family_id = Column(UUID(as_uuid=True), ForeignKey('families.id'), nullable=False)
    # 가족 역할: 할머니/할아버지, 손자/손녀/자녀 > 접근권한 설정
    family_role = Column(String)
    # 계정 생성일자
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    # 마지막 로그인
    last_login = Column(DateTime, nullable=True)
    
    # 관계 설정
    # User ↔ Family
    family = relationship("Family", backref="members")
    
