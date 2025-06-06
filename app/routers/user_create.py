from sqlalchemy import Column, String, DateTime, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
from db.database import Base
from sqlalchemy.orm import relationship

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
    id = Column(UUID(as_uuid=True), primary_key=True) 
    # kakao 로그인 정보
    kakao_id = Column(String, index=True)
    # 사용자명
    username = Column(String)
    # 성별
    gender = Column(String)
    # 생년월일
    birthday = Column(DateTime)
    # 프로필 사진
    profile_img = Column(Text, nullable=True)
    # 관계 가족 id
    family_id = Column(UUID(as_uuid=True), ForeignKey('families.id'))
    # 가족 역할: 할머니/할아버지, 손자/손녀/자녀 > 접근권한 설정
    family_role = Column(String)
    # 계정 생성일자
    created_at = Column(DateTime, default=datetime) # 자동생성 부여
    # Family ↔ User
    family = relationship("Family", back_populates="family_user")
    
