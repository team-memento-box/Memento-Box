from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from db.database import get_db
from db.models.family_model import Family
from uuid import UUID
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/families",
    tags=["families"]
)

@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_family(family_code: str, db: AsyncSession = Depends(get_db)):
    """
    새로운 가족 생성
    """
    try:
        family = Family(family_code=family_code)
        db.add(family)
        await db.commit()
        await db.refresh(family)
        return family
    except Exception as e:
        logger.error(f"Error in create_family: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.get("/{family_id}", status_code=status.HTTP_200_OK)
async def get_family(family_id: UUID, db: AsyncSession = Depends(get_db)):
    """
    특정 가족 정보 조회
    """
    try:
        family = await db.get(Family, family_id)
        if not family:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Family not found"
            )
        return family
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in get_family: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        ) 