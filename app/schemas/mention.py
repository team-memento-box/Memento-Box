from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from datetime import datetime

class QuestionAnswer(BaseModel):
    q_text: str
    a_text: str
    q_voice: Optional[str] = None
    a_voice: Optional[str] = None

class MentionCreate(BaseModel):
    conv_id: UUID
    question_answer: QuestionAnswer
    recorded_at: Optional[datetime]

class MentionUpdate(BaseModel):
    question_answer: Optional[QuestionAnswer] = None
    recorded_at: Optional[datetime] = None

class MentionOut(BaseModel):
    id: UUID
    conv_id: UUID
    question_answer: QuestionAnswer
    recorded_at: Optional[datetime]

    class Config:
        orm_mode = True
