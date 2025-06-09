from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from db.database import get_db
from db.models.conversation import Conversation
from schemas.conversation import ConversationCreate, ConversationResponse
from services.conversation import ConversationService
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
    conversation_service = ConversationService(db)
    conversation = await conversation_service.create_conversation(conversation_in)
    return conversation

@router.get("/{conversation_id}", response_model=ConversationResponse)
async def get_conversation(
    conversation_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    conversation_service = ConversationService(db)
    return await conversation_service.get_conversation(conversation_id)

@router.get("/", response_model=List[ConversationResponse])
async def list_conversations(
    db: AsyncSession = Depends(get_db)
):
    conversation_service = ConversationService(db)
    return await conversation_service.list_conversations()

@router.delete("/{conversation_id}")
async def delete_conversation(
    conversation_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    conversation_service = ConversationService(db)
    success = await conversation_service.delete_conversation(conversation_id)
    if not success:
        raise HTTPException(status_code=404, detail="회기를 찾을 수 없습니다.")
    return {"message": "회기가 삭제되었습니다."}