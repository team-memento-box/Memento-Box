from fastapi import UploadFile, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from db.models.photo import Photo
from db.models.family import Family
from core.config import settings
from services.photo_analysis_service import photo_analysis_service
import os
import logging
from typing import Dict, Any, List, Optional
from datetime import datetime
from uuid import UUID
import aiofiles
from azure.storage.blob.aio import BlobServiceClient
import uuid
from dotenv import load_dotenv

# Configure logging
# logging.basicConfig(level=logging.INFO)
# logger = logging.getLogger(__name__)

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# ─────────────────────────────환경변수─────────────────────────────
API_KEY    = os.getenv("AZURE_OPENAI_KEY")
ENDPOINT   = os.getenv("AZURE_OPENAI_ENDPOINT")
DEPLOYMENT = os.getenv("AZURE_OPENAI_DEPLOYMENT")
API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION")
STORAGE_ACCOUNT = os.getenv("AZURE_BLOBSTORAGE_ACCOUNT")
STORAGE_KEY = os.getenv("AZURE_BLOBSTORAGE_KEY")
#──────────────────────────────────────────────────────────

# Azure Blob 설정

# 연결 문자열 생성
connection_string = f"DefaultEndpointsProtocol=https;AccountName={STORAGE_ACCOUNT};AccountKey={STORAGE_KEY};EndpointSuffix=core.windows.net"
container_name = "kev-backup"

class PhotoManagementService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.blob_connection_string = connection_string
        self.container_name = container_name
        self.local_storage = not bool(self.blob_connection_string)

    async def _get_default_family(self) -> Optional[UUID]:
        """기본 가족 ID 가져오기"""
        try:
            # 첫 번째로 찾은 가족 ID 반환
            query = select(Family.id).limit(1)
            result = await self.db.execute(query)
            family_id = result.scalar_one_or_none()
            
            if not family_id:
                # 가족이 없는 경우 새로운 가족 생성
                new_family = Family(
                    family_code="DEFAULT_FAMILY",
                    created_at=datetime.utcnow()
                )
                self.db.add(new_family)
                await self.db.commit()
                await self.db.refresh(new_family)
                return new_family.id
                
            return family_id
        except Exception as e:
            # logger.error(f"Error getting default family: {str(e)}")
            return None

    async def _save_file_locally(self, file_data: bytes, filename: str) -> tuple[str, str]:
        """로컬에 파일 저장하고 (로컬 경로, URL)을 반환"""
        try:
            os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
            file_path = os.path.join(settings.UPLOAD_DIR, filename)
            async with aiofiles.open(file_path, "wb") as buffer:
                await buffer.write(file_data)
            return file_path, f"/uploads/{filename}"
        except Exception as e:
            # logger.error(f"Failed to save file locally: {str(e)}")
            raise HTTPException(status_code=500, detail="Failed to save file")

    async def _upload_to_blob(self, file_data: bytes, filename: str) -> tuple[str, str]:
        """Azure Blob Storage에 파일 업로드하고 (로컬 경로, Blob URL)을 반환"""
        if self.local_storage:
            return await self._save_file_locally(file_data, filename)

        try:
            if not self.blob_connection_string:
                raise ValueError("Azure Blob Storage connection string is not configured")

            # 임시 로컬 저장 (분석용)
            os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
            local_path = os.path.join(settings.UPLOAD_DIR, filename)
            async with aiofiles.open(local_path, "wb") as buffer:
                await buffer.write(file_data)

            blob_service_client = BlobServiceClient.from_connection_string(self.blob_connection_string)
            async with blob_service_client:
                container_client = blob_service_client.get_container_client(self.container_name)
                
                # 컨테이너가 없으면 생성
                try:
                    await container_client.create_container()
                except Exception:
                    pass  # 컨테이너가 이미 존재하면 무시

                # 고유한 파일명 생성
                unique_filename = f"{uuid.uuid4()}_{filename}"
                blob_client = container_client.get_blob_client(unique_filename)
                
                # 파일 업로드
                await blob_client.upload_blob(file_data, overwrite=True)
                return local_path, blob_client.url
        except Exception as e:
            # logger.error(f"Failed to upload to Azure Blob: {str(e)}")
            # Azure Blob Storage 업로드 실패 시 로컬 저장으로 폴백
            return await self._save_file_locally(file_data, filename)

    async def create_photo(
        self,
        file: UploadFile,
        title: Optional[str] = None,
        description: Optional[str] = None,
        story_year: Optional[str] = None,
        story_season: Optional[str] = None,
        story_nudge: Optional[Dict[str, Any]] = None,
        family_id: Optional[UUID] = None
    ) -> Photo:
        """사진 업로드 및 저장"""
        try:
            # family_id가 없으면 기본 가족 ID 사용
            if not family_id:
                family_id = await self._get_default_family()
                if not family_id:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="No family available"
                    )

            # 파일 데이터 읽기
            file_data = await file.read()
            
            # 파일 저장 (로컬)
            image_path, image_url = await self._upload_to_blob(file_data, file.filename) # self._save_file_locally(file_data, file.filename)
            
            # Photo 객체 생성
            photo = Photo(
                title=title or file.filename,
                description=description,
                image_url=image_url,
                image_path=image_path,
                story_year=story_year,
                story_season=story_season,
                story_nudge=story_nudge or {},
                analysis={},
                family_id=family_id,
                uploaded_at=datetime.utcnow()
            )
            
            self.db.add(photo)
            await self.db.commit()
            await self.db.refresh(photo)
            
            return photo
            
        except HTTPException as he:
            raise he
        except Exception as e:
            # logger.error(f"Error creating photo: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=str(e)
            )

    async def get_photo(self, photo_id: int) -> Optional[Photo]:
        """특정 사진 조회"""
        try:
            photo = await self.db.get(Photo, photo_id)
            return photo
        except Exception as e:
            # logger.error(f"Error getting photo: {str(e)}")
            return None

    async def get_photos(
        self,
        family_id: Optional[UUID] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[Photo]:
        """사진 목록 조회"""
        try:
            query = select(Photo)
            if family_id:
                query = query.filter(Photo.family_id == family_id)
            query = query.offset(skip).limit(limit)
            result = await self.db.execute(query)
            return result.scalars().all()
        except Exception as e:
            # logger.error(f"Error getting photos: {str(e)}")
            return []

    async def delete_photo(self, photo_id: int) -> bool:
        """사진 삭제"""
        try:
            photo = await self.get_photo(photo_id)
            if not photo:
                return False
                
            # 로컬 파일 삭제
            if os.path.exists(photo.image_path):
                os.remove(photo.image_path)
                
            await self.db.delete(photo)
            await self.db.commit()
            return True
        except Exception as e:
            # logger.error(f"Error deleting photo: {str(e)}")
            return False

    async def update_analysis(self, photo_id: int, analysis_result: Dict[str, Any]) -> Optional[Photo]:
        """사진 분석 결과 업데이트"""
        try:
            photo = await self.get_photo(photo_id)
            if not photo:
                return None
                
            photo.analysis = analysis_result
            if analysis_result:
                # 분석 결과를 문자열로 변환하여 summary_text에도 저장
                summary = (
                    f"장소: {analysis_result.get('location', '알 수 없음')}\n"
                    f"인물: {', '.join(analysis_result.get('people', []))}\n"
                    f"관계: {analysis_result.get('relationships', '알 수 없음')}\n"
                    f"분위기: {analysis_result.get('mood', '알 수 없음')}\n"
                    f"상황: {analysis_result.get('situation', '알 수 없음')}"
                )
                photo.summary_text = summary
                
            await self.db.commit()
            await self.db.refresh(photo)
            return photo
        except Exception as e:
            # logger.error(f"Error updating analysis: {str(e)}")
            return None

# 서비스 인스턴스 생성
photo_management_service = PhotoManagementService(None)  # db는 의존성 주입으로 처리됨 