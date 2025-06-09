from fastapi import APIRouter, Body, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from db.database import get_db
from services.family import FamilyService

router = APIRouter(prefix="/family", tags=["family"])

@router.post("/create")
async def create_family(
    data: dict = Body(...),
    db: AsyncSession = Depends(get_db)
):
    family_service = FamilyService(db)
    return await family_service.create_family(data.get("family_name"))

@router.post("/join")
async def join_family(
    data: dict = Body(...),
    db: AsyncSession = Depends(get_db)
):
    family_service = FamilyService(db)
    return await family_service.join_family(data.get("family_code")) 