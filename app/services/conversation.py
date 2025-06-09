from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional, List
from uuid import UUID
from fastapi import HTTPException
from db.models.conversation import Conversation
from schemas.conversation import ConversationCreate, ConversationUpdate
from datetime import datetime
import uuid

class ConversationService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_conversation(self, conversation_in: ConversationCreate) -> Conversation:
        """새로운 대화를 생성합니다."""
        conversation = Conversation(
            id=uuid.uuid4(),
            photo_id=conversation_in.photo_id,
            created_at=conversation_in.created_at or datetime.utcnow()
        )
        self.db.add(conversation)
        await self.db.commit()
        await self.db.refresh(conversation)
        return conversation

    async def get_conversation(self, conversation_id: UUID) -> Optional[Conversation]:
        """특정 대화를 조회합니다."""
        result = await self.db.execute(
            select(Conversation).where(Conversation.id == conversation_id)
        )
        conversation = result.scalar_one_or_none()
        if not conversation:
            raise HTTPException(status_code=404, detail="회기를 찾을 수 없습니다.")
        return conversation

    async def list_conversations(self) -> List[Conversation]:
        """모든 대화를 조회합니다."""
        result = await self.db.execute(select(Conversation))
        return result.scalars().all()

    async def delete_conversation(self, conversation_id: UUID) -> bool:
        """대화를 삭제합니다."""
        conversation = await self.get_conversation(conversation_id)
        if not conversation:
            return False
            
        await self.db.delete(conversation)
        await self.db.commit()
        return True

