from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from db.database import get_db
from db.models.photo_model import Photo
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/conversations",
    tags=["conversations"]
)

@router.post("/{photo_id}/chat", status_code=status.HTTP_200_OK)
async def chat_with_photo(
    photo_id: int,
    message: str,
    db: AsyncSession = Depends(get_db)
):
    """
    사진에 대한 대화 생성
    """
    try:
        # 사진 존재 여부 확인
        photo = await db.get(Photo, photo_id)
        if not photo:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Photo not found"
            )
            
        # TODO: 실제 대화 처리 로직 구현
        return {
            "message": "Chat functionality will be implemented",
            "photo_id": photo_id,
            "user_message": message
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in chat_with_photo: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        ) 