from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from typing import List
import os
import uuid
from datetime import datetime
from db.database import get_db
from db.models.photo import Photo
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from schemas.photo import PhotoCreate, PhotoResponse
from services.photo import PhotoService, upload_photo_to_blob, save_photo_to_db, get_photos_by_family
from services.blob_storage import get_blob_service_client
from core.auth import get_current_user
from db.models.user import User

router = APIRouter(
    prefix="/photos",
    tags=["photos"]
)

@router.post("/upload", response_model=PhotoResponse)
async def upload_photo(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    사진을 업로드하고 메타데이터를 저장합니다.
    """
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")

    temp_file_path = None
    try:
        # 임시 파일로 저장
        temp_file_path = f"uploads/{uuid.uuid4()}_{file.filename}"
        os.makedirs("uploads", exist_ok=True)
        
        with open(temp_file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)

        # Blob Storage에 업로드
        blob_service_client = get_blob_service_client()
        photo_url = await upload_photo_to_blob(temp_file_path, file.filename, blob_service_client)

        # DB에 메타데이터 저장
        photo_data = PhotoCreate(
            photo_name=file.filename,
            family_id=current_user.family_id,  # 현재 사용자의 family_id 사용
            photo_url=photo_url,
            story_year=datetime.now(),
            story_season="summer",
            story_nudge={"note": "auto-uploaded"}
        )
        
        photo = await save_photo_to_db(photo_data, db)
        return PhotoResponse.from_orm(photo)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)

@router.get("/", response_model=List[PhotoResponse])
async def list_photos(
    family_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    특정 가족의 모든 사진을 조회합니다.
    """
    photos = await get_photos_by_family(family_id, db)
    return photos

@router.get("/{photo_id}", response_model=PhotoResponse)
async def get_photo(
    photo_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    특정 사진의 상세 정보를 조회합니다.
    """
    result = await db.execute(
        select(Photo).where(Photo.id == photo_id)
    )
    photo = result.scalar_one_or_none()
    if not photo:
        raise HTTPException(status_code=404, detail="사진을 찾을 수 없습니다.")
    return photo

@router.delete("/{photo_id}")
async def delete_photo(
    photo_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    특정 사진을 삭제합니다.
    """
    photo_service = PhotoService(db)
    if await photo_service.delete_photo(photo_id):
        return {"message": "사진이 삭제되었습니다."}
    raise HTTPException(status_code=404, detail="사진을 찾을 수 없습니다.") 