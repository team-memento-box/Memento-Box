'''
더미 데이터를 추가하는 함수
'''

from sqlalchemy.ext.asyncio import AsyncSession
from app.models.family import Family
from app.models.user import User
from app.models.photo import Photo
from app.models.mention import Mention
from app.models.anomalies_report import AnomaliesReport
import asyncio
from datetime import datetime
import uuid

# 더미 데이터를 추가하는 비동기 함수
async def add_dummy_data(session: AsyncSession):
    # 1. Family
    family = Family(
        id=uuid.uuid4(),
        family_code="FAM001",
        created_at=datetime.utcnow()
    )
    session.add(family)
    await session.commit()
    await session.refresh(family)


    # 2. User
    user = User(
        id=uuid.uuid4(),
        kakao_id="kakao_dummy",
        username="홍길동",
        gender="male",
        birthday=datetime(1990, 1, 1),
        profile_img=None,
        family_id=family.id,
        family_role="손자",
        speak_vector=None,
        created_at=datetime.utcnow()
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)

    # 3. Photo
    photo = Photo(
        id=uuid.uuid4(),
        photo_name="test_photo.jpg",
        photo_url="http://example.com/photo.jpg",
        story_year=datetime(2020, 1, 1),
        story_season="spring",
        story_nudge=None,
        summary_text="요약 텍스트",
        summary_voice=None,
        family_id=family.id,
        uploaded_at=datetime.utcnow()
    )
    session.add(photo)
    await session.commit()
    await session.refresh(photo)

    # 4. Mention
    mention = Mention(
        id=uuid.uuid4(),
        photo_id=photo.id,
        question_answer={
            "q_text": "질문 예시",
            "a_text": "답변 예시",
            "q_voice": "http://example.com/q_voice.mp3",
            "a_voice": "http://example.com/a_voice.mp3"
        },
        recorded_at=datetime.utcnow()
    )
    session.add(mention)
    await session.commit()
    await session.refresh(mention)

    # 5. AnomaliesReport
    anomalies = AnomaliesReport(
        id=uuid.uuid4(),
        mention_id=mention.id,
        event_interval="00:00-00:10",
        family_id=family.id
    )
    session.add(anomalies)
    await session.commit()
    await session.refresh(anomalies)

    print("더미 데이터 추가 완료")
    return user, photo, mention, anomalies #, family

 

# 메인 함수
async def main():
    from app.database import AsyncSessionLocal
    async with AsyncSessionLocal() as session:
        await add_dummy_data(session)

if __name__ == "__main__":
    asyncio.run(main())


'''

사진을 storage에 업로드 하는 함수

'''
from fastapi import FastAPI, File, UploadFile, Depends
from fastapi.responses import JSONResponse
from sqlalchemy import Column, String, DateTime, Text, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Session
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from azure.storage.blob import BlobServiceClient
from uuid import uuid4
from datetime import datetime
import os
from app.database import AsyncSessionLocal
from app.models.photo import Photo

# Azure Blob Storage 설정
connection_string = "your_connection_string"  # Azure 연결 문자열
container_name = "team2storage3rdproject"  # Blob 컨테이너 이름
blob_service_client = BlobServiceClient.from_connection_string(connection_string)
container_client = blob_service_client.get_container_client(container_name)


# 사진 업로드 함수 (Azure Blob Storage에 파일 업로드)
def upload_to_blob(file_path: str, blob_name: str):
    with open(file_path, "rb") as data:
        blob_client = container_client.get_blob_client(blob_name)
        blob_client.upload_blob(data, overwrite=True)
    return f"https://{blob_service_client.account_name}.blob.core.windows.net/{container_name}/{blob_name}"

# DB 세션 생성
def get_db():
    db = AsyncSessionLocal()
    try:
        yield db
    finally:
        db.close()

# DB에 새로운 사진 정보 저장
def add_photo_to_db(photo_url: str, family_id: uuid4, photo_name: str = None, db: Session = None):
    new_photo = Photo(
        id=uuid4(),
        photo_name=photo_name,
        photo_url=photo_url,
        family_id=family_id,
        uploaded_at=datetime.utcnow()  # 업로드 일자는 UTC 기준으로 설정
    )
    db.add(new_photo)
    db.commit()  # DB에 커밋
    db.refresh(new_photo)  # 새로 생성된 객체를 갱신
    print(f"Photo added: {new_photo.id}, {new_photo.photo_name}, {new_photo.photo_url}")


# 테스트 코드 (로컬에서 사진 업로드 후 DB 확인)
def test_upload():
    # 파일 경로와 업로드할 파일 이름
    photo_path = "path/to/your/photo.jpg"  # 로컬 사진 파일 경로
    photo_blob_name = f"photos/{uuid4()}.jpg"
    
    # Azure Blob Storage에 사진 업로드
    photo_url = upload_to_blob(photo_path, photo_blob_name)
    print(f"Photo uploaded to: {photo_url}")
    
    # DB에 저장
    with next(get_db()) as db:
        family_id = uuid4()  # 임시 가족 ID
        add_photo_to_db(photo_url, family_id, "Family Photo", db)

    # DB에서 저장된 사진 정보 확인
    with next(get_db()) as db:
        stmt = select(Photo).filter(Photo.photo_url == photo_url)
        result = db.execute(stmt).scalars().first()
        if result:
            print(f"DB Confirm: {result.id}, {result.photo_name}, {result.photo_url}")


if __name__ == "__main__":
    test_upload()




