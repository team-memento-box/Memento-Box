from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import List, Optional

class TurnDetail(BaseModel):
    id: UUID
    conv_id: UUID
    turn: Optional[dict]
    recorded_at: Optional[datetime]
    class Config:
        from_attributes = True

class ConversationDetail(BaseModel):
    id: UUID
    photo_id: UUID
    created_at: datetime
    turns: List[TurnDetail] = []
    class Config:
        from_attributes = True 