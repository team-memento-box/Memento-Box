from pydantic import BaseModel, EmailStr, Field, ConfigDict
from datetime import datetime, date
from typing import Optional
from uuid import UUID

class UserBase(BaseModel):
    """
    사용자 기본 스키마
    """
    kakao_id: str
    name: str
    email: EmailStr
    phone: str
    gender: str
    birthday: date
    profile_img: Optional[str] = None
    family_id: UUID
    family_role: str
    is_guardian: bool = False

class UserCreate(UserBase):
    """
    사용자 생성 스키마
    """
    password: str

class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    gender: Optional[str] = None
    birthday: Optional[date] = None
    profile_img: Optional[str] = None
    family_role: Optional[str] = None
    is_guardian: Optional[bool] = None
    password: Optional[str] = None

class UserResponse(UserBase):
    """
    사용자 응답 스키마
    """
    id: UUID
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
