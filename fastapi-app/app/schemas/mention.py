from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from uuid import UUID
from datetime import datetime

class QuestionAnswer(BaseModel):
    q_text: str
    a_text: str
    q_voice: Optional[str] = None  # wav 파일의 blob url
    a_voice: Optional[str] = None

class MentionCreate(BaseModel):
    conv_id: UUID
    question_answer: QuestionAnswer
    recorded_at: Optional[datetime] = None

class MentionResponse(MentionCreate):
    id: UUID
    recorded_at: Optional[datetime] = None