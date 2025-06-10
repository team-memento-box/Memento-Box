from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from db.models.conversation import Conversation
from uuid import UUID

async def get_conversation_with_turns(db: AsyncSession, photo_id: UUID, conversation_id: UUID):
    result = await db.execute(
        select(Conversation)
        .options(selectinload(Conversation.turns))
        .where(
            Conversation.id == conversation_id,
            Conversation.photo_id == photo_id
        )
    )
    conversation = result.scalars().first()
    return conversation

async def get_latest_conversation_for_photo(db: AsyncSession, photo_id: UUID):
    result = await db.execute(
        select(Conversation)
        .options(selectinload(Conversation.turns))
        .where(Conversation.photo_id == photo_id)
        .order_by(Conversation.created_at.desc())
        .limit(1)
    )
    conversation = result.scalars().first()
    return conversation 