from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional
from uuid import UUID

class FamilyBase(BaseModel):
    """
    가족 기본 스키마
    """
    code: str
    name: Optional[str] = None

class FamilyCreate(FamilyBase):
    """
    가족 생성 스키마
    """
    pass

class FamilyUpdate(BaseModel):
    code: Optional[str] = None
    name: Optional[str] = None

class FamilyResponse(FamilyBase):
    """
    가족 응답 스키마
    """
    id: UUID
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
