from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from db.models.conversation import Conversation
from db.models.turn import Turn
from db.database import get_db
from schemas.conversation import ConversationDetail, ConversationOriginTextResponse, ConversationOriginVoiceResponse, ConversationOriginTextResponse, ConversationOriginVoiceResponse
from services.conversation import get_conversation_with_turns, get_latest_conversation_for_photo, get_conversation_origin_text, get_conversation_origin_voice, get_conversation_origin_text, get_conversation_origin_voice

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

@router.get("/api/photos/{photo_id}/conversations/{conversation_id}/origin_text", response_model=ConversationOriginTextResponse)
async def get_conversation_origin_text_api(photo_id: UUID, conversation_id: UUID, db: AsyncSession = Depends(get_db)):
    origin_text = await get_conversation_origin_text(db, conversation_id)
    if origin_text is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return {"conversation_id": conversation_id, "origin_text": origin_text}

@router.get("/api/photos/{photo_id}/conversations/{conversation_id}/origin_voice", response_model=ConversationOriginVoiceResponse)
async def get_conversation_origin_voice_api(photo_id: UUID, conversation_id: UUID, db: AsyncSession = Depends(get_db)):
    origin_voice = await get_conversation_origin_voice(db, conversation_id)
    if origin_voice is None:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return {"conversation_id": conversation_id, "origin_voice": origin_voice}