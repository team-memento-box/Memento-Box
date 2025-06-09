from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List
from uuid import UUID
from datetime import datetime
from schemas.turn import TurnTextResponse

class ConversationBase(BaseModel):
    id: UUID
    photo_id: Optional[UUID] = None
    created_at: Optional[datetime] = None

class ConversationCreate(ConversationBase):
    pass

class ConversationUpdate(BaseModel):
    """대화 업데이트를 위한 스키마"""
    photo_id: Optional[UUID] = None
    created_at: Optional[datetime] = None
    model_config = ConfigDict(from_attributes=True)

class ConversationResponse(ConversationBase):
    model_config = ConfigDict(from_attributes=True)

class ConversationWithTurns(ConversationResponse):
    turns: List[TurnTextResponse]
    model_config = ConfigDict(from_attributes=True) 