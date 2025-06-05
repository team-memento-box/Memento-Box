from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class PhotoBase(BaseModel):
    title: str
    description: Optional[str] = None

class PhotoCreate(PhotoBase):
    pass

class Photo(PhotoBase):
    id: int
    filename: str
    created_at: datetime
    
    class Config:
        from_attributes = True 