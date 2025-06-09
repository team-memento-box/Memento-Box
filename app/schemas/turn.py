from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, Dict, Any
from uuid import UUID

class TurnBase(BaseModel):
    """
    대화 턴 기본 스키마
    """
    conv_id: UUID
    turn: Optional[Dict[str, Any]] = None
    recorded_at: Optional[datetime] = None


class TurnCreate(TurnBase):
    """
    대화 턴 생성 스키마
    """
    pass


class TurnUpdate(BaseModel):
    turn: Optional[Dict[str, Any]] = None
    recorded_at: Optional[datetime] = None


class TurnResponse(BaseModel):
    q_text: str
    a_text: str
    q_voice: Optional[str] = None  # wav 파일의 blob url
    a_voice: Optional[str] = None


class TurnTextResponse(BaseModel):
    q_voice: Optional[str] = None  # wav 파일의 blob url
    a_voice: Optional[str] = None


class TurnWavResponse(BaseModel):
    q_text: str
    a_text: str


class TurnAllResponse(TurnBase):
    """
    대화 턴 응답 스키마
    """
    id: UUID   
    model_config = ConfigDict(from_attributes=True)
