from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID
from datetime import datetime

class ConversationBase(BaseModel):
    id: UUID
    photo_id: Optional[UUID] = None
    created_at: Optional[datetime] = None

class ConversationCreate(BaseModel):
    photo_id: Optional[UUID] = None
    created_at: Optional[datetime] = None

class ConversationResponse(ConversationBase):
    pass 