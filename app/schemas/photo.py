from pydantic import BaseModel
from typing import Optional, Dict, Any, List
from datetime import datetime
from uuid import UUID

class StoryNudge(BaseModel):
    keywords: List[str]
    mood: str

class PhotoBase(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    story_year: Optional[str] = None
    story_season: Optional[str] = None
    story_nudge: Optional[Dict[str, Any]] = None

class PhotoCreate(PhotoBase):
    pass

class PhotoAnalysis(BaseModel):
    people: List[str] = []
    relationships: str = ""
    location: str = ""
    mood: str = ""
    key_objects: List[str] = []
    keywords: List[str] = []
    situation: str = ""

class Photo(PhotoBase):
    id: UUID
    image_url: str
    image_path: str
    analysis: Optional[Dict[str, Any]] = None
    uploaded_at: datetime

    class Config:
        from_attributes = True

class PhotoResponse(Photo):
    pass

class PhotoInfo(BaseModel):
    id: UUID
    title: Optional[str] = None
    image_url: str
    uploaded_at: datetime 