from sqlalchemy import Column, String, DateTime, Text, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from ..database import Base

class Photo(Base):
    """
    photos 테이블 모델
    """
    __tablename__ = 'photos'
    __table_args__ = {
        #"schema": "", # 파일명
        #"mysql_engine": "InnoDB",
        "mysql_charset": "utf8mb4",
        "mysql_collate": "utf8mb4_general_ci" 
    }
    # 사진 id
    id = Column(UUID(as_uuid=True), primary_key=True)
    # 업로드 유저
    # uploaded_by = Column(UUID(as_uuid=True), ForeignKey("users.id")) 
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
    # 사진 접근 가능 가족 id
    family_id = Column(UUID(as_uuid=True), ForeignKey('families.id'))
    # 업로드 일자
    uploaded_at = Column(DateTime)
    # Family ↔ Photo 역참조 # photo.family.family_code
    # family = relationship("Family", back_populates="photos")
    # Photo ↔ Mention 역참조 # photo.mentions[0].question_answer
    # mentions = relationship("Mention", back_populates="photo", cascade="all, delete-orphan")
