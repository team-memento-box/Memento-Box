from pydantic import BaseModel
from uuid import UUID
from typing import Optional
from datetime import datetime

class UserResponse(BaseModel):
    id: UUID
    kakao_id: Optional[str] = None
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    gender: Optional[str] = None
    birthday: Optional[str] = None
    profile_img: Optional[str] = None
    family_id: Optional[UUID] = None
    family_role: Optional[str] = None
    is_guardian: Optional[bool] = None
    created_at: Optional[datetime] = None 