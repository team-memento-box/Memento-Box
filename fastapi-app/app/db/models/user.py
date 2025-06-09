from sqlalchemy import Column, String, DateTime, Text, ForeignKey, Boolean
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
from db.database import Base
from sqlalchemy.orm import relationship
from uuid import uuid4

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
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4) 
    # kakao 로그인 정보
    kakao_id = Column(String, index=True)
    # 사용자명
    username = Column(String)
    # 성별
    gender = Column(String)
    # 생년월일
    birthday = Column(String)
    # 프로필 사진
    profile_img = Column(Text, nullable=True)
    # 이메일
    email = Column(String, nullable=True)
    # 전화번호
    phone_number = Column(String, nullable=True)
    # 관계 가족 id
    family_id = Column(UUID(as_uuid=True), ForeignKey('families.id'))
    # 가족 역할: 할머니/할아버지, 손자/손녀/자녀 > 접근권한 설정
    family_role = Column(String)
    # 계정 생성일자
    created_at = Column(DateTime, default=datetime.utcnow)  # datetime.utcnow()를 사용
    # Family ↔ User
    family = relationship("Family", back_populates="family_user")
    # 보호자 여부
    is_guardian = Column(Boolean, nullable=True)
    # 가족 코드
    family_code = Column(String, nullable=True)
    # 가족 이름
    family_name = Column(String, nullable=True)