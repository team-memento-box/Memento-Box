from sqlalchemy import Column, Integer, String, Date, DateTime, ForeignKey
from pydantic import BaseModel, Field
from typing import List
from uuid import UUID
from datetime import date, datetime, timedelta

# class Photo(BaseModel):
#     __tablename__ = "photosd"

#     id = Column(Integer, primary_key=True, index=True)
#     family_id = Column(Integer, ForeignKey("families.id"))
#     image_url = Column(String)
#     recorded_at = Column(DateTime)
#     uploaded_at = Column(Date)

# ====== 모델 정의 ======
class Item(BaseModel):
    name: str
    value: int

class StoryNudge(BaseModel):
    mood: str
    keywords: List[str]

class PhotoResponse(BaseModel):
    photoId: str
    photoName: str
    storyYear: str
    storySeason: str
    storyNudge: StoryNudge
    uploadedAt: str

# ✅ Pydantic 스키마
class PhotoSchema(BaseModel):
    id: int
    family_id: int
    image_url: str
    recorded_at: datetime
    uploaded_at: date

# [첫 질문 생성]
# 입력 모델
class StoryNudge(BaseModel):
    mood: str
    keywords: List[str]

class PhotoInfo(BaseModel):
    photoName: str
    storyYear: str
    storySeason: str
    storyNudge: StoryNudge

# 출력 모델
class QuestionResponse(BaseModel):
    status: str
    question: str

# [대화 관리 (대화 저장)]
# 대화 턴 모델
class Turn(BaseModel):
    question: str
    answer: str
    timestamp: datetime
    question_type: str  # 예: "첫질문", "후속질문"

# 전체 요청 모델
class ConversationSaveRequest(BaseModel):
    photoId: UUID
    turns: List[Turn]

# 응답 모델
class ConversationSaveResponse(BaseModel):
    status: str
    mentionId: UUID