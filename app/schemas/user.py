from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from uuid import UUID

class UserCreate(BaseModel):
    kakao_id: str
    username: str
    gender: str
    birthday: datetime
    profile_img: Optional[str] = None
    family_id: UUID
    family_role: str


class UserRead(BaseModel):
    id: UUID
    kakao_id: str
    username: str
    gender: str
    birthday: datetime
    profile_img: Optional[str]
    family_id: UUID
    family_role: str
    created_at: datetime

    class Config:
        orm_mode = True
