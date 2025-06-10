from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional, Dict, Any, Literal
from uuid import UUID

class PhotoBase(BaseModel):
    id: UUID
    name: Optional[str] = None
    url: str
    year: int
    season: Literal["spring", "summer", "autumn", "winter"]
    description: Optional[str] = None
    story_year: Optional[str] = None
    story_season: Optional[str] = None
    story_nudge: Optional[Dict[str, Any]] = None

# PhotoCreate가 PhotoBase를 상속받지 않는 이유:
# 1. id는 DB에서 자동 생성되는 필드이므로 생성 시에는 필요하지 않음
# 2. PhotoBase는 id를 포함하고 있어서, 상속받으면 불필요한 id 필드가 생성 요청에 포함됨
# 3. 생성 요청과 응답의 스키마를 명확하게 분리하여 관리
class PhotoCreate(BaseModel):
    name: Optional[str] = None
    url: str
    year: int
    season: Literal["spring", "summer", "autumn", "winter"]
    description: Optional[str] = None
    summary_text: Optional[Dict[str, Any]] = None
    summary_voice: Optional[Dict[str, Any]] = None
    family_id: UUID

class Photo(PhotoBase):
    id: int
    filename: str
    created_at: datetime
    image_url: str
    image_path: str
    analysis: Optional[Dict[str, Any]] = None
    class Config:
        from_attributes = True 

class PhotoInfo(PhotoBase):
    id: UUID
    title: Optional[str] = None
    image_url: str
    uploaded_at: datetime 

class PhotoResponse(PhotoBase):
    uploaded_at: datetime
    model_config = ConfigDict(from_attributes=True) 
