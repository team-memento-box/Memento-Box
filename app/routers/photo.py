from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from services.photo import PhotoService, get_photo_conversations_with_mentions
from schemas.photo import PhotoCreate, Photo
from db.database import get_db
from typing import List
from uuid import UUID

router = APIRouter(
    prefix="/photos",
    tags=["photos"]
)

@router.post("/upload", response_model=Photo)
async def upload_photo(
    file: UploadFile = File(...),
    title: str = None,
    description: str = None,
    db: AsyncSession = Depends(get_db)
):
    try:
        # 파일 타입 검증
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")
        
        # 사진 서비스 생성
        photo_service = PhotoService(db)
        
        # 사진 업로드 및 DB 저장
        photo = await photo_service.create_photo(file, title, description)
        if not photo:
            raise HTTPException(status_code=500, detail="사진 업로드에 실패했습니다.")
        
        return photo
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/", response_model=List[Photo])
async def list_photos(db: AsyncSession = Depends(get_db)):
    try:
        result = await db.execute(select(Photo))
        photos = result.scalars().all()
        return photos
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{photo_id}", response_model=Photo)
async def get_photo(photo_id: UUID, db: AsyncSession = Depends(get_db)):
    try:
        result = await db.execute(select(Photo).where(Photo.id == photo_id))
        photo = result.scalars().first()
        if not photo:
            raise HTTPException(status_code=404, detail="사진을 찾을 수 없습니다.")
        return photo
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{photo_id}")
async def delete_photo(photo_id: UUID, db: AsyncSession = Depends(get_db)):
    try:
        photo_service = PhotoService(db)
        if await photo_service.delete_photo(photo_id):
            return {"message": "사진이 삭제되었습니다."}
        raise HTTPException(status_code=404, detail="사진을 찾을 수 없습니다.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 사진의 전체 대화내역 조회
from services.photo import get_photo_conversations_with_mentions
from schemas.conversation import ConversationWithTurns

@router.get("/{photo_id}/conversations", response_model=List[ConversationWithTurns])
async def get_conversations_with_turns_by_photo_id(
    photo_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    try:
        result = await get_photo_conversations_with_mentions(db, photo_id)
        return result
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    