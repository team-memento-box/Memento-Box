from datetime import datetime
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from uuid import UUID

class QuestionAnswer(BaseModel):
    q_text: str
    a_text: str
    q_voice: Optional[str] = None
    a_voice: Optional[str] = None

class ConversationBase(BaseModel):
    photo_id: UUID

class ConversationCreate(ConversationBase):
    pass

class ConversationResponse(ConversationBase):
    id: UUID
    created_at: datetime
    mentions: Optional[List[Dict[str, Any]]] = None

    class Config:
        from_attributes = True

# Legacy schemas (keeping for backwards compatibility)
class QuestionResponse(BaseModel):
    status: str
    question: str

class Turn(BaseModel):
    question: str
    answer: str
    timestamp: datetime
    question_type: str  # 예: "첫질문", "후속질문"

class ConversationSaveRequest(BaseModel):
    photoId: UUID
    turns: List[Turn]

class ConversationSaveResponse(BaseModel):
    status: str
    mentionId: UUID 