from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional, List, Dict
from uuid import UUID, uuid4
from fastapi import HTTPException
from db.models.family import Family
from schemas.family import FamilyCreate, FamilyUpdate
from datetime import datetime
import random
import string

class FamilyService:
    def __init__(self, db: AsyncSession):
        self.db = db

    def _generate_family_code(self) -> str:
        """가족 코드를 생성합니다."""
        return 'DA' + ''.join(random.choices(string.digits, k=6))

    async def create_family(self, family_name: str) -> Dict:
        """새로운 가족을 생성합니다."""
        if not family_name:
            raise HTTPException(status_code=400, detail="가족 이름이 필요합니다.")

        family_code = self._generate_family_code()
        new_family = Family(
            id=uuid4(),
            family_code=family_code,
            family_name=family_name,
            created_at=datetime.utcnow()
        )
        
        self.db.add(new_family)
        await self.db.commit()
        await self.db.refresh(new_family)
        
        return {
            "family_id": str(new_family.id),
            "family_code": new_family.family_code,
            "family_name": new_family.family_name
        }

    async def join_family(self, family_code: str) -> Dict:
        """가족 코드로 가족에 참여합니다."""
        if not family_code:
            raise HTTPException(status_code=400, detail="가족 코드가 필요합니다.")

        result = await self.db.execute(
            select(Family).where(Family.family_code == family_code)
        )
        family = result.scalar_one_or_none()
        
        if not family:
            raise HTTPException(status_code=404, detail="유효하지 않은 가족 코드입니다.")
            
        return {
            "family_id": str(family.id),
            "family_code": family.family_code,
            "family_name": family.family_name
        }

    