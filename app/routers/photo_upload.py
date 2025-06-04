import os
import sys
import uuid
import asyncio
from datetime import datetime
from uuid import uuid4
from dotenv import load_dotenv

import aiofiles
from azure.storage.blob.aio import BlobServiceClient
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from db.database import async_session
from db.models import family, photo

from db.models.photo import Photo
from db.models.family import Family

# .env 로드
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# Azure Blob 설정
connection_string = os.getenv("AZURE_BLOBSTORAGE_KEY")
container_name = "photo"

# 업로드할 로컬 경로 (호스트 uploads/ 폴더)
LOCAL_UPLOADS_PATH = os.path.join(os.path.dirname(__file__), "../uploads")

# Blob에 업로드
async def upload_to_blob(file_path: str, blob_name: str) -> str:
    blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    async with blob_service_client:
        container_client = blob_service_client.get_container_client(container_name)
        blob_client = container_client.get_blob_client(blob_name)

        async with aiofiles.open(file_path, "rb") as f:
            data = await f.read()
            await blob_client.upload_blob(data, overwrite=True)
            print(f"Uploaded to Azure Blob: {blob_client.url}")
            return blob_client.url

# family_id 가져오기
async def get_family_id_by_code(db: AsyncSession, family_code: str) -> uuid.UUID:
    result = await db.execute(select(Family).where(Family.family_code == family_code))
    family = result.scalar_one_or_none()
    if family is None:
        raise ValueError(f"Family with code {family_code} not found")
    return family.id

# 사진 메타를 PostgreSQL에 저장
async def save_photo_to_db(photo_url: str, photo_name: str, family_id: uuid.UUID, db: AsyncSession):
    print(f"💾 Saving photo to DB: {photo_name}, URL: {photo_url}")
    try:
        photo = Photo(
            id=uuid4(),
            photo_name=photo_name,
            photo_url=photo_url,
            story_year=datetime.now(),
            story_season="summer",
            story_nudge={"note": "auto-uploaded"},
            family_id=family_id,
            uploaded_at=datetime.utcnow()
        )
        db.add(photo)
        await db.commit()
        await db.refresh(photo)
        print("✅ DB 저장 성공")
        return photo
    except Exception as e:
        print(f"❌ DB 저장 실패: {e}")
        await db.rollback()
        raise

# 전체 업로드 로직
async def upload_all_photos():
    print("📂 Upload 경로:", LOCAL_UPLOADS_PATH)
    print("📸 포함된 파일:", os.listdir(LOCAL_UPLOADS_PATH))

    async with async_session() as db:
        family_id = await get_family_id_by_code(db, "FAMILY001")

        for file in os.listdir(LOCAL_UPLOADS_PATH):
            if not file.lower().endswith((".jpg", ".jpeg", ".png")):
                continue

            file_path = os.path.join(LOCAL_UPLOADS_PATH, file)
            blob_name = f"{uuid.uuid4()}_{file}"
            try:
                photo_url = await upload_to_blob(file_path, blob_name)
                await save_photo_to_db(photo_url, file, family_id, db)
                print(f"Uploaded and saved: {file}")
                os.remove(file_path)
            except Exception as e:
                print(f"❌ Error processing {file}: {e}")
                raise  # 반드시 추가: 실제 문제 로그를 터미널에 보여줌

if __name__ == "__main__":
    asyncio.run(upload_all_photos())


