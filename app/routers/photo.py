from fastapi import APIRouter, UploadFile, File, HTTPException
from services.photo import save_upload_file
from schemas.photo import PhotoCreate, Photo
from datetime import datetime

router = APIRouter(
    prefix="/photos",
    tags=["photos"]
)

@router.post("/upload", response_model=Photo)
async def upload_photo(
    file: UploadFile = File(...),
    title: str = None,
    description: str = None
):
    # 파일 타입 검증
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")
    
    # 파일 저장
    filename = await save_upload_file(file)
    if not filename:
        raise HTTPException(status_code=500, detail="파일 업로드에 실패했습니다.")
    
    # 응답 생성
    return Photo(
        id=1,  # 실제 구현에서는 DB에서 생성된 ID를 사용
        title=title or file.filename,
        description=description,
        filename=filename,
        created_at=datetime.now()
    ) 