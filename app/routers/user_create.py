from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import uuid4
from datetime import datetime

from db.database import get_db
from db.models.user import User

from pydantic import BaseModel
from typing import Optional
from datetime import date
from uuid import UUID

router = APIRouter()

# 요청 데이터 구조 정의
class UserCreateRequest(BaseModel):
    kakao_id: str
    username: str
    gender: str
    birthday: date
    profile_img: Optional[str] = None
    family_id: Optional[UUID] = None
    family_role: Optional[str] = None

@router.post("/api/users", summary="유저 생성")
async def create_user(
    req: UserCreateRequest,
    db: AsyncSession = Depends(get_db)
):
    try:
        user = User(
            id=uuid4(),
            kakao_id=req.kakao_id,
            username=req.username,
            gender=req.gender,
            birthday=datetime.combine(req.birthday, datetime.min.time()),
            profile_img=req.profile_img,
            family_id=req.family_id,
            family_role=req.family_role,
            created_at=datetime.utcnow()
        )

        db.add(user)
        await db.commit()
        await db.refresh(user)

        return {
            "status": "ok",
            "user_id": str(user.id),
            "username": user.username
        }

    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"User creation failed: {str(e)}")