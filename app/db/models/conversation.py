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


from uuid import uuid4
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from schemas.conversation import ConversationCreate, ConversationUpdate
from typing import List, Optional

async def create_conversation(db: AsyncSession, conv_in: ConversationCreate) -> Conversation:
    new_conv = Conversation(
        id=uuid4(),
        photo_id=conv_in.photo_id,
        created_at=conv_in.created_at
    )
    db.add(new_conv)
    await db.commit()
    await db.refresh(new_conv)
    return new_conv

async def get_conversation_by_id(db: AsyncSession, conv_id) -> Optional[Conversation]:
    result = await db.execute(select(Conversation).where(Conversation.id == conv_id))
    return result.scalars().first()

async def get_conversations_by_photo_id(db: AsyncSession, photo_id) -> List[Conversation]:
    result = await db.execute(select(Conversation).where(Conversation.photo_id == photo_id))
    return result.scalars().all()

async def update_conversation(db: AsyncSession, conv_id, conv_in: ConversationUpdate) -> Optional[Conversation]:
    result = await db.execute(select(Conversation).where(Conversation.id == conv_id))
    conv = result.scalars().first()
    if conv is None:
        return None
    if conv_in.created_at:
        conv.created_at = conv_in.created_at
    await db.commit()
    await db.refresh(conv)
    return conv

async def delete_conversation(db: AsyncSession, conv_id) -> bool:
    result = await db.execute(select(Conversation).where(Conversation.id == conv_id))
    conv = result.scalars().first()
    if conv is None:
        return False
    await db.delete(conv)
    await db.commit()
    return True
