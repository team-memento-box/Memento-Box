from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from uuid import UUID

class PhotoBase(BaseModel):
    photo_name: str
    photo_url: str
    family_id: str

class PhotoCreate(PhotoBase):
    pass

class Photo(PhotoBase):
    id: UUID
    created_at: datetime
    
    class Config:
        from_attributes = True