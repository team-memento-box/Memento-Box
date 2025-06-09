# schemas/conversation.py
from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import Optional, List
from schemas.mention import MentionOut  # Mention 스키마가 필요

class ConversationCreate(BaseModel):
    photo_id: UUID
    created_at: Optional[datetime] = None

class ConversationUpdate(BaseModel):
    created_at: Optional[datetime] = None

class ConversationOut(BaseModel):
    id: UUID
    photo_id: UUID
    created_at: Optional[datetime]

    class Config:
        orm_mode = True

class ConversationWithMentions(BaseModel):
    conversation: ConversationOut
    mentions: List[dict]  # q_text와 a_text만 포함하는 딕셔너리 리스트

    class Config:
        orm_mode = True
