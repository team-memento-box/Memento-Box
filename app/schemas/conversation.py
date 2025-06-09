# schemas/conversation.py
from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import Optional, List
from schemas.mention import MentionOut  # Mention 스키마가 필요

class TurnOut(BaseModel):  # 새로운 스키마 추가
    q_text: str
    a_text: str

    class Config:
        orm_mode = True

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

class ConversationWithTurns(BaseModel):
    conversation: ConversationOut
    turns: List[TurnOut]  # List[dict] -> List[TurnOut]으로 변경

    class Config:
        orm_mode = True
