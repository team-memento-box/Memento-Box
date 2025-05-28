from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime
from .database import Base

class AnomaliesReport(Base):
    """
    anomalies_reports 테이블 모델

    anomalies_reports는 mention에, mention은 photo에 종속된 구조
    """
    __tablename__ = 'anomalies_reports'
    __table_args__ = {
        #"schema": "", # 파일명
        #"mysql_engine": "InnoDB",
        "mysql_charset": "utf8mb4", 
        "mysql_collate": "utf8mb4_general_ci" 
    }
    # 이상현상 id
    id = Column(UUID(as_uuid=True), primary_key=True)
    # 이상현상 대화 내용
    mention_id = Column(UUID(as_uuid=True), ForeignKey('mentions.id'))
    # 이상대화 구간
    event_interval = Column(String, nullable=True)
    # 접근 가족 (서비스 접근 권한 - 보호자)
    family_id = Column(String, ForeignKey('families.id'))
    # Mention ↔ AnomaliesReport 역참조 # anomalies_report.mention.question_answer
    mention = relationship("Mention", back_populates="anomalies_reports")
