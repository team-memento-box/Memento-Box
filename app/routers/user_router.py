from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from db.database import get_db
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.get("/me", status_code=status.HTTP_200_OK)
async def get_current_user(db: AsyncSession = Depends(get_db)):
    """
    현재 로그인한 사용자 정보 조회
    """
    try:
        # TODO: 실제 사용자 인증 및 정보 조회 로직 구현
        return {
            "message": "Current user info will be implemented"
        }
    except Exception as e:
        logger.error(f"Error in get_current_user: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        ) 