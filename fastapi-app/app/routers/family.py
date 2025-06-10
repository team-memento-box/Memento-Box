from fastapi import APIRouter, Body
from fastapi.responses import JSONResponse
from db.database import async_session
from sqlalchemy.future import select
from db.models.family import Family
from uuid import uuid4
from datetime import datetime
import random, string

router = APIRouter(prefix="/family", tags=["family"])

@router.post("/create")
async def create_family(data: dict = Body(...)):
    family_name = data.get("family_name")
    if not family_name:
        return JSONResponse({"error": "No family_name provided"}, status_code=400)
        
    def generate_family_code():
        return 'DA' + ''.join(random.choices(string.digits, k=6))
        
    family_code = generate_family_code()
    new_family = Family(
        id=uuid4(),
        code=family_code,
        name=family_name,
        created_at=datetime.utcnow()
    )
    
    async with async_session() as session:
        session.add(new_family)
        await session.commit()
        return {
            "family_id": str(new_family.id),
            "family_code": new_family.code,
            "family_name": new_family.name
        }

@router.post("/join")
async def join_family(data: dict = Body(...)):
    family_code = data.get("family_code")
    if not family_code:
        return JSONResponse({"error": "No family_code provided"}, status_code=400)
    async with async_session() as session:
        result = await session.execute(select(Family).where(Family.code == family_code))
        family = result.scalar_one_or_none()
        if not family:
            return JSONResponse({"error": "Invalid family_code"}, status_code=404)
        return {
            "family_id": str(family.id), 
            "family_code": family.code,
            "family_name": family.name
        } 
