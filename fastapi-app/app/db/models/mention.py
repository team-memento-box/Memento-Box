from sqlalchemy import Column, DateTime, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from db.database import Base
from sqlalchemy.orm import relationship
import uuid
class Mention(Base):
    """
    멘션 테이블
    추후 사용자를 배려해 내용 쿼리 검색 기능을 구현하려면 재분리가 필요할 것
    """
    __tablename__ = 'mentions'
    __table_args__ = {
        #"schema": "", # 파일명
    }
    # mention id (질답 1쌍으로 관리)
    id = Column(UUID(as_uuid=True), primary_key=True,default=uuid.uuid4)
    # 관계 회기 id
    conv_id = Column(UUID(as_uuid=True), ForeignKey('conversations.id'))
    # 질답쌍 {q_text:txt, a_text:txt, q_voice: url, a_voice: url}
    question_answer = Column(JSON, nullable=True)
    # 기록일자
    recorded_at = Column(DateTime, nullable=True)
    # Conversation ↔ Mention 
    conv_mention = relationship("Conversation", back_populates="mention")

