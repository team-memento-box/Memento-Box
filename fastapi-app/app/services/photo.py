import os
from fastapi import UploadFile
from datetime import datetime
import shutil
from typing import Optional
from sqlalchemy.orm import Session
from db.models.photo import Photo
from .blob_storage import BlobStorageService

UPLOAD_DIR = "uploads"

class PhotoService:
    def __init__(self, db: Session):
        self.db = db
        self.blob_storage = BlobStorageService()

    async def create_photo(self, file: UploadFile, family_id: str, title: str = None, description: str = None) -> Optional[Photo]:
        try:
            # 파일 데이터 읽기
            file_data = await file.read()
            
            # Azure Blob Storage에 업로드
            blob_url, _ = await self.blob_storage.upload_file(file_data, file.filename)
            
            # DB에 정보 저장
            photo = Photo(
                photo_name=title or file.filename,
                photo_url=blob_url,
                family_id=family_id
            )
            
            self.db.add(photo)
            self.db.commit()
            self.db.refresh(photo)
            
            return photo
            
        except Exception as e:
            self.db.rollback()
            print(f"Error creating photo: {str(e)}")
            return None
        finally:
            await file.close()

    async def delete_photo(self, photo_id: str) -> bool:
        try:
            # DB에서 사진 정보 조회
            photo = self.db.query(Photo).filter(Photo.id == photo_id).first()
            if not photo:
                return False
            
            # Azure Blob Storage에서 파일 삭제
            if await self.blob_storage.delete_file(photo.photo_name):
                # DB에서 정보 삭제
                self.db.delete(photo)
                self.db.commit()
                return True
            return False
            
        except Exception as e:
            self.db.rollback()
            print(f"Error deleting photo: {str(e)}")
            return False

async def save_upload_file(upload_file: UploadFile) -> Optional[str]:
    try:
        # 업로드 디렉토리가 없으면 생성
        os.makedirs(UPLOAD_DIR, exist_ok=True)
        
        # 파일명 생성 (timestamp + original filename)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{timestamp}_{upload_file.filename}"
        file_path = os.path.join(UPLOAD_DIR, filename)
        
        # 파일 저장
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(upload_file.file, buffer)
            
        return filename
    except Exception as e:
        print(f"Error saving file: {str(e)}")
        return None
    finally:
        upload_file.file.close() 