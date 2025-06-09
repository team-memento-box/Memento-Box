import os
from fastapi import UploadFile
from datetime import datetime
import shutil
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from db.models.photo import Photo
from db.models.conversation import Conversation
from .blob_storage import BlobStorageService
from typing import Optional, List
from uuid import UUID


UPLOAD_DIR = "uploads"

class PhotoService:
    def __init__(self, db: AsyncSession):
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
                name=title or file.filename,
                url=blob_url,
                family_id=family_id,
                description=description,
                uploaded_at=datetime.utcnow()
            )
            
            self.db.add(photo)
            await self.db.commit()
            await self.db.refresh(photo)
            
            return photo
            
        except Exception as e:
            await self.db.rollback()
            print(f"Error creating photo: {str(e)}")
            return None
        finally:
            await file.close()

    async def delete_photo(self, photo_id: str) -> bool:
        try:
            # DB에서 사진 정보 조회
            result = await self.db.execute(select(Photo).where(Photo.id == photo_id))
            photo = result.scalars().first()
            if not photo:
                return False
            
            # Azure Blob Storage에서 파일 삭제
            if await self.blob_storage.delete_file(photo.name):
                # DB에서 정보 삭제
                await self.db.delete(photo)
                await self.db.commit()
                return True
            return False
            
        except Exception as e:
            await self.db.rollback()
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


"""

특정 photo_id에 연결된 conversation들과, 각 conversation에 연결된 mention들을 JOIN으로 함께 조회

"""

def _serialize_conversation_with_mentions(conv: Conversation) -> dict:
    return {
        "conversation": {
            "id": conv.id,
            "photo_id": conv.photo_id,
            "created_at": conv.created_at
        },
        "turns": [
            {
                "q_text": turn.turn.get("q_text", ""),
                "a_text": turn.turn.get("a_text", "")
            }
            for turn in conv.turns
        ]
    }

from fastapi import HTTPException  # 이 줄 추가

async def get_photo_conversations_with_mentions(db: AsyncSession, photo_id: UUID) -> List[dict]:
    try:
        # 먼저 photo가 존재하는지 확인
        photo_result = await db.execute(select(Photo).where(Photo.id == photo_id))
        photo = photo_result.scalars().first()
        if not photo:
            raise HTTPException(status_code=404, detail="사진을 찾을 수 없습니다.")

        result = await db.execute(
            select(Conversation)
            .options(selectinload(Conversation.turns))
            .where(Conversation.photo_id == photo_id)
        )
        conversations = result.scalars().all()
        return [_serialize_conversation_with_mentions(conv) for conv in conversations]
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error fetching conversations: {str(e)}")
        raise HTTPException(status_code=500, detail=f"대화 내역을 가져오는 중 오류가 발생했습니다: {str(e)}")
    