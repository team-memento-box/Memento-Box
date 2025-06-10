from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from db.models.conversation import Conversation
from db.models.turn import Turn
from db.database import get_db
from schemas.conversation import ConversationDetail
from services.conversation import get_conversation_with_turns, get_latest_conversation_for_photo

router = APIRouter()

@router.get("/api/photos/{photo_id}/latest_conversation", response_model=ConversationDetail)
async def get_latest_conversation(photo_id: UUID, db: AsyncSession = Depends(get_db)):
    conversation = await get_latest_conversation_for_photo(db, photo_id)
    if not conversation:
        raise HTTPException(status_code=404, detail="No conversation found for this photo")
    return conversation 

@router.get("/api/photos/{photo_id}/{conversation_id}", response_model=ConversationDetail)
async def get_conversation_for_photo(photo_id: UUID, conversation_id: UUID, db: AsyncSession = Depends(get_db)):
    conversation = await get_conversation_with_turns(db, photo_id, conversation_id)
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found for this photo")
    return conversation