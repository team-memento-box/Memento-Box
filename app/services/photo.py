import os
from fastapi import UploadFile, HTTPException
from datetime import datetime
import shutil
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from uuid import UUID
from schemas.photo import PhotoBase, PhotoResponse, PhotoCreate
from db.models.photo import Photo
from db.models.user import User
from .blob_storage import BlobStorageService, get_blob_service_client
import uuid
from fastapi import HTTPException 
from sqlalchemy.orm import selectinload
from schemas.turn import TurnTextResponse
from schemas.conversation import ConversationWithTurns

UPLOAD_DIR = "uploads"

class PhotoService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.blob_storage = BlobStorageService()

    async def create_photo(self, file: UploadFile, current_user: User) -> Photo:
        """
        사진을 업로드하고 메타데이터를 저장합니다.
        """
        temp_file_path = None
        try:
            # 임시 파일로 저장
            temp_file_path = f"{UPLOAD_DIR}/{uuid.uuid4()}_{file.filename}"
            os.makedirs(UPLOAD_DIR, exist_ok=True)
            
            with open(temp_file_path, "wb") as buffer:
                content = await file.read()
                buffer.write(content)

            # Blob Storage에 업로드
            blob_service_client = get_blob_service_client()
            photo_url = await upload_photo_to_blob(temp_file_path, file.filename, blob_service_client)

            # DB에 메타데이터 저장
            photo_data = PhotoBase(
                name=file.filename,
                family_id=current_user.family_id,
                url=photo_url,
                year=datetime.now().year,
                season=datetime.now().strftime('%B'),
                description={"note": "auto-uploaded"}
            )
            
            return await save_photo_to_db(photo_data, self.db)

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        finally:
            if temp_file_path and os.path.exists(temp_file_path):
                os.remove(temp_file_path)

    async def delete_photo(self, photo_id: UUID) -> bool:
        """
        사진을 삭제합니다.
        """
        try:
            result = await self.db.execute(
                select(Photo).where(Photo.id == photo_id)
            )
            photo = result.scalar_one_or_none()
            
            if not photo:
                return False
            
            # Azure Blob Storage에서 파일 삭제
            if await self.blob_storage.delete_file(photo.name):
                await self.db.delete(photo)
                await self.db.commit()
                return True
            return False
            
        except Exception as e:
            await self.db.rollback()
            raise HTTPException(status_code=500, detail=str(e))

async def upload_photo_to_blob(file_path: str, original_filename: str, blob_service_client) -> str:
    """
    Azure Blob Storage에 사진을 업로드합니다.
    """
    blob_name = f"{uuid.uuid4()}_{original_filename}"
    try:
        # BlobStorageService 인스턴스일 경우
        if hasattr(blob_service_client, 'container_client'):
            blob_client = blob_service_client.container_client.get_blob_client(blob_name)
            with open(file_path, "rb") as data:
                blob_client.upload_blob(data, overwrite=True)
                return blob_client.url
        else:
            # (기존 비동기 BlobServiceClient 사용 케이스가 있다면 여기에 추가)
            raise Exception('지원하지 않는 blob_service_client 타입입니다.')
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Blob Storage 업로드 실패: {str(e)}")

async def save_photo_to_db(photo_data: PhotoCreate, db: AsyncSession) -> Photo:
    """
    사진 메타데이터를 데이터베이스에 저장합니다.
    """
    try:
        photo = Photo(
            name=photo_data.name,
            url=photo_data.url,
            year=photo_data.year,
            season=photo_data.season,
            description=photo_data.description,
            summary_text=photo_data.summary_text,
            summary_voice=photo_data.summary_voice,
            family_id=photo_data.family_id,
            uploaded_at=datetime.utcnow()
        )
        
        db.add(photo)
        await db.commit()
        await db.refresh(photo)
        return photo
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"데이터베이스 저장 실패: {str(e)}")

async def get_photos_by_family(family_id: UUID, db: AsyncSession) -> List[Photo]:
    """
    특정 가족의 모든 사진을 조회합니다.
    """
    try:
        result = await db.execute(
            select(Photo).where(Photo.family_id == family_id)
        )
        return result.scalars().all()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"사진 조회 실패: {str(e)}") 
    

# 특정 photo_id에 연결된 conversation들과, 각 conversation에 연결된 mention들을 JOIN으로 함께 조회
from db.models.conversation import Conversation

def _serialize_conversation_with_mentions(conv: Conversation) -> dict:
    return {
        "conversation": {
            "id": conv.id,
            "photo_id": conv.photo_id,
            "created_at": conv.created_at
        },
        "turns": [
            TurnTextResponse(
                q_voice=turn.turn.get("q_voice"),
                a_voice=turn.turn.get("a_voice")
            )
            for turn in conv.turns
        ]
    }

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
    
