from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from db.database import get_db
from db.models.conversation import Conversation
from schemas.conversation import ConversationCreate, ConversationResponse
from core.auth import get_current_user
from db.models.user import User
from typing import List
import uuid
from datetime import datetime

router = APIRouter(
    prefix="/api/conversations",
    tags=["conversations"]
)

@router.post("/upload", response_model=ConversationResponse)
async def create_conversation(
    conversation_in: ConversationCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    conversation = Conversation(
        id=uuid.uuid4(),
        photo_id=conversation_in.photo_id,
        created_at=conversation_in.created_at or datetime.utcnow()
    )
    db.add(conversation)
    await db.commit()
    await db.refresh(conversation)
    return conversation

@router.get("/{conversation_id}", response_model=ConversationResponse)
async def get_conversation(
    conversation_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(Conversation).where(Conversation.id == conversation_id)
    )
    conversation = result.scalar_one_or_none()
    if not conversation:
        raise HTTPException(status_code=404, detail="회기를 찾을 수 없습니다.")
    return conversation

@router.get("/", response_model=List[ConversationResponse])
async def list_conversations(
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Conversation))
    conversations = result.scalars().all()
    return conversations

@router.delete("/{conversation_id}")
async def delete_conversation(
    conversation_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(Conversation).where(Conversation.id == conversation_id)
    )
    conversation = result.scalar_one_or_none()
    if not conversation:
        raise HTTPException(status_code=404, detail="회기를 찾을 수 없습니다.")
    await db.delete(conversation)
    await db.commit()
    return {"message": "회기가 삭제되었습니다."}