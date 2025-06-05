from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from sqlalchemy.orm import Session
from ..services.photo import PhotoService
from ..schemas.photo import PhotoCreate, Photo
from ..db.database import get_db
from typing import List

router = APIRouter(
    prefix="/photos",
    tags=["photos"]
)

@router.post("/upload", response_model=Photo)
async def upload_photo(
    file: UploadFile = File(...),
    title: str = None,
    description: str = None,
    db: Session = Depends(get_db)
):
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

@router.get("/", response_model=List[Photo])
async def list_photos(db: Session = Depends(get_db)):
    photos = db.query(Photo).all()
    return photos

@router.get("/{photo_id}", response_model=Photo)
async def get_photo(photo_id: int, db: Session = Depends(get_db)):
    photo = db.query(Photo).filter(Photo.id == photo_id).first()
    if not photo:
        raise HTTPException(status_code=404, detail="사진을 찾을 수 없습니다.")
    return photo

@router.delete("/{photo_id}")
async def delete_photo(photo_id: int, db: Session = Depends(get_db)):
    photo_service = PhotoService(db)
    if await photo_service.delete_photo(photo_id):
        return {"message": "사진이 삭제되었습니다."}
    raise HTTPException(status_code=404, detail="사진을 찾을 수 없습니다.") 