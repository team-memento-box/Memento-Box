from uuid import UUID
from pydantic import BaseModel
from datetime import datetime
from typing import Optional, Dict, Any, List

class PhotoBase(BaseModel):
    title: str
    description: Optional[str] = None
    story_year: Optional[str] = None
    story_season: Optional[str] = None
    story_nudge: Optional[Dict[str, Any]] = None

class PhotoCreate(PhotoBase):
    pass

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