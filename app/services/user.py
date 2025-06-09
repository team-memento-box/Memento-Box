from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional, List
from uuid import UUID
from fastapi import HTTPException
from db.models.user import User
from schemas.user import UserCreate, UserUpdate
from datetime import datetime
import uuid

class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_user(self, user_in: UserCreate) -> User:
        """새로운 사용자를 생성합니다."""
        user = User(
            id=uuid.uuid4(),
            email=user_in.email,
            hashed_password=user_in.hashed_password,
            full_name=user_in.full_name,
            family_id=user_in.family_id,
            role=user_in.role,
            created_at=datetime.utcnow()
        )
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def get_user(self, user_id: UUID) -> Optional[User]:
        """특정 사용자를 조회합니다."""
        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()

    async def get_user_by_email(self, email: str) -> Optional[User]:
        """이메일로 사용자를 조회합니다."""
        result = await self.db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()

    async def get_users_by_family(self, family_id: UUID) -> List[User]:
        """특정 가족의 모든 사용자를 조회합니다."""
        result = await self.db.execute(
            select(User).where(User.family_id == family_id)
        )
        return result.scalars().all()

    async def update_user(self, user_id: UUID, user_in: UserUpdate) -> Optional[User]:
        """사용자 정보를 업데이트합니다."""
        user = await self.get_user(user_id)
        if not user:
            return None

        for key, value in user_in.dict(exclude_unset=True).items():
            setattr(user, key, value)

        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def delete_user(self, user_id: UUID) -> bool:
        """사용자를 삭제합니다."""
        user = await self.get_user(user_id)
        if not user:
            return False

        await self.db.delete(user)
        await self.db.commit()
        return True
   