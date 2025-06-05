# # '''
# # 더미 데이터를 추가하는 함수
# # '''

# import sys
# import os

# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# from sqlalchemy.ext.asyncio import AsyncSession
# from app.models.family import Family
# from app.models.user import User
# from app.models.photo import Photo
# from app.models.conversation import Conversation
# from app.models.mention import Mention
# from app.models.anomalies_report import AnomaliesReport

# import asyncio
# from datetime import datetime
# import uuid

# # 더미 데이터를 추가하는 비동기 함수s
# async def add_dummy_data(session: AsyncSession):
#     # # 1. Family
#     # family = Family(
#     #     id=uuid.uuid4(),
#     #     family_code="FAM001",
#     #     created_at=datetime.utcnow()
#     # )
#     # session.add(family)
#     # await session.commit()
#     # await session.refresh(family)


#     # # 2. User
#     # user = User(
#     #     id=uuid.uuid4(),
#     #     kakao_id="kakao_dummy",
#     #     username="홍길동",
#     #     gender="male",
#     #     birthday=datetime(1990, 1, 1),
#     #     profile_img=None,
#     #     family_id=family.id,
#     #     family_role="손자",
#     #     speak_vector=None,
#     #     created_at=datetime.utcnow()
#     # )
#     # session.add(user)
#     # await session.commit()
#     # await session.refresh(user)

#     # # 3. Photo
#     # photo = Photo(
#     #     id=uuid.uuid4(),
#     #     photo_name="test_photo.jpg",
#     #     photo_url="http://example.com/photo.jpg",
#     #     story_year=datetime(2020, 1, 1),
#     #     story_season="spring",
#     #     story_nudge=None,
#     #     summary_text="요약 텍스트",
#     #     summary_voice=None,
#     #     family_id=family.id,
#     #     uploaded_at=datetime.utcnow()
#     # )
#     # session.add(photo)
#     # await session.commit()
#     # await session.refresh(photo)

#     # 4. Mention
#     conversation = Conversation(
#             id=uuid.uuid4(),  # 새로운 UUID 생성
#             photo_id="0c4d0875-7722-4552-ba1b-6c5c2ce8f574",  # 첫 번째 사진의 ID 사용
#             created_at=datetime.utcnow()  # 현재 시간으로 설정
#         )
    
#     session.add(conversation)
#     await session.commit()
#     await session.refresh(conversation)

#     # # 5. Mention
#     # mention = Mention(
#     #     id=uuid.uuid4(),
#     #     photo_id=photo.id,
#     #     question_answer={
#     #         "q_text": "질문 예시",
#     #         "a_text": "답변 예시",
#     #         "q_voice": "http://example.com/q_voice.mp3",
#     #         "a_voice": "http://example.com/a_voice.mp3"
#     #     },
#     #     recorded_at=datetime.utcnow()
#     # )
#     # session.add(mention)
#     # await session.commit()
#     # await session.refresh(mention)

#     # # 6. AnomaliesReport
#     # anomalies = AnomaliesReport(
#     #     id=uuid.uuid4(),
#     #     mention_id=mention.id,
#     #     event_interval="00:00-00:10",
#     #     family_id=family.id
#     # )
#     # session.add(anomalies)
#     # await session.commit()
#     # await session.refresh(anomalies)

#     # print("더미 데이터 추가 완료")
#     return conversation #user, photo, mention, anomalies #, family

 
# # 메인 함수
# async def main():
#     from app.database import AsyncSessionLocal
#     async with AsyncSessionLocal() as session:
#         await add_dummy_data(session)

# if __name__ == "__main__":
#     asyncio.run(main())


'''

test code: 사진 업로드, url 생성, postgresql 반영 (동기/비동기 혼용)

'''
# import os
# import sys

# # app 디렉토리를 Python 경로에 추가
# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# import asyncio
# from uuid import uuid4
# from datetime import datetime
# from azure.storage.blob import BlobServiceClient
# from sqlalchemy.ext.asyncio import AsyncSession
# from app.database import AsyncSessionLocal
# from app.models.photo import Photo
# from app.models.family import Family
# from dotenv import load_dotenv
# from sqlalchemy.future import select
# import uuid

# # .env 파일 로드
# load_dotenv()


# # Azure Blob Storage 연결 문자열
# connection_string = ""
# container_name = "photo"

# # BlobServiceClient 객체 생성
# blob_service_client = BlobServiceClient.from_connection_string(connection_string)
# container_client = blob_service_client.get_container_client(container_name)

# # 비동기 세션 생성
# async def get_db():
#     async with AsyncSessionLocal() as session:
#         yield session

# # 동기식 Blob 업로드 함수
# def upload_to_blob_sync(file_path: str, blob_name: str):
#     blob_client = container_client.get_blob_client(blob_name)
#     with open(file_path, "rb") as file_data:
#         # Blob에 파일 업로드 (동기식)
#         blob_client.upload_blob(file_data, overwrite=True)
#         print(f"File uploaded to Blob Storage: {blob_client.url}")
#     return blob_client.url

# # 비동기 함수에서 동기 함수 실행
# async def upload_to_blob(file_path: str, blob_name: str):
#     loop = asyncio.get_event_loop()
#     # ThreadPoolExecutor를 사용하여 동기 함수를 비동기적으로 실행
#     return await loop.run_in_executor(None, upload_to_blob_sync, file_path, blob_name)

# # PostgreSQL에 사진 저장 함수 (비동기 방식)
# async def save_photo_to_db(photo_url: str, photo_name: str, family_id: uuid.UUID, db: AsyncSession):
#     new_photo = Photo(
#         id=uuid4(),
#         photo_name=photo_name,
#         photo_url=photo_url,
#         story_season="summer",  # 예시로 "summer" 계정
#         story_nudge={"note": "family picture"},  # 예시 넛지
#         family_id=family_id,  # 유효한 family_id 사용
#         uploaded_at=datetime.utcnow()
#     )

#     db.add(new_photo)
#     await db.commit()
#     await db.refresh(new_photo)

#     return new_photo

# # # 가족 코드를 이용하여 family_id 가져오기
# # async def get_family_id_by_code(db: AsyncSession, family_code: str) -> uuid.UUID:
# #     result = await db.execute(select(Family).filter(Family.family_code == family_code))
# #     family = result.scalar_one_or_none()
# #     if family:
# #         return family.id  # 유효한 family_id 반환
# #     else:
# #         raise ValueError(f"Family with code {family_code} not found")

# # select(Family)에서 **family_code**가 중복된 경우 중복 제거
# async def get_family_id_by_code(db: AsyncSession, family_code: str) -> uuid.UUID:
#     result = await db.execute(select(Family).filter(Family.family_code == family_code).limit(1))
#     family = result.scalar_one_or_none()
#     if family:
#         return family.id  # 유효한 family_id 반환
#     else:
#         raise ValueError(f"Family with code {family_code} not found")


# # 비동기 테스트 함수
# async def test_upload_photo():
#     # 로컬 파일 경로 및 Blob 저장 이름
#     file_path = "/home/azureuser/fastapi_app/app/IE001161299_STD.jpg"  # 업로드할 파일 경로 (Linux 경로)
#     blob_name = f"{uuid4()}.jpg"  # 업로드할 Blob 이름

#     # 파일을 Blob Storage에 업로드
#     photo_url = await upload_to_blob(file_path, blob_name)

#     # 유효한 family_id를 DB에서 조회
#     async with AsyncSessionLocal() as db:
#         family_id = await get_family_id_by_code(db, "FAM001")  # 실제 존재하는 family_code를 사용

#         # PostgreSQL에 사진 정보 저장
#         photo = await save_photo_to_db(photo_url, "Test Photo", family_id, db)

#     print(f"Uploaded photo: {photo.photo_name}, URL: {photo.photo_url}")

# # 실행
# if __name__ == "__main__":
#     asyncio.run(test_upload_photo())


'''
test code: 사진 업로드, url 생성, postgresql 반영 (비동기: BlobServiceClient를 비동기 방식으로 수정)

'''

import os
import sys
# app 디렉토리를 Python 경로에 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import asyncio
from uuid import uuid4
from datetime import datetime
from azure.storage.blob.aio import BlobServiceClient  # 비동기 버전으로 임포트
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import AsyncSessionLocal
from app.models.photo import Photo
from app.models.family import Family
from dotenv import load_dotenv
from sqlalchemy.future import select
import uuid

# .env 파일 로드
load_dotenv()



# Azure Blob Storage 연결 문자열
connection_string = ""
container_name = "photo"

# BlobServiceClient 객체 생성 (비동기 버전)
blob_service_client = BlobServiceClient.from_connection_string(connection_string)
container_client = blob_service_client.get_container_client(container_name)

# 비동기 세션 생성
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session

# 비동기 Blob 업로드 함수
async def upload_to_blob(file_path: str, blob_name: str):
    blob_client = container_client.get_blob_client(blob_name)
    async with blob_client:
        # 비동기 방식으로 파일 업로드
        with open(file_path, "rb") as file_data:
            await blob_client.upload_blob(file_data, overwrite=True)
            print(f"File uploaded to Blob Storage: {blob_client.url}")
    return blob_client.url

# PostgreSQL에 사진 저장 함수 (비동기 방식)
async def save_photo_to_db(photo_url: str, photo_name: str, family_id: uuid.UUID, db: AsyncSession):
    new_photo = Photo(
        id=uuid4(),
        photo_name=photo_name,
        photo_url=photo_url,
        story_season="summer",  # 예시로 "summer" 계정
        story_nudge={"note": "family picture"},  # 예시 넛지
        family_id=family_id,  # 유효한 family_id 사용
        uploaded_at=datetime.utcnow()
    )

    db.add(new_photo)
    await db.commit()
    await db.refresh(new_photo)

    return new_photo

# 가족 코드를 이용하여 family_id 가져오기
async def get_family_id_by_code(db: AsyncSession, family_code: str) -> uuid.UUID:
    result = await db.execute(select(Family).filter(Family.family_code == family_code).limit(1))
    family = result.scalar_one_or_none()
    if family:
        return family.id  # 유효한 family_id 반환
    else:
        raise ValueError(f"Family with code {family_code} not found")

# 비동기 테스트 함수
async def test_upload_photo():
    # 로컬 파일 경로 및 Blob 저장 이름
    file_path = ""  # 업로드할 파일 경로 (Linux 경로)
    blob_name = f"{uuid4()}.jpg"  # 업로드할 Blob 이름

    # 파일을 Blob Storage에 업로드
    photo_url = await upload_to_blob(file_path, blob_name)

    # 유효한 family_id를 DB에서 조회
    async with AsyncSessionLocal() as db:
        family_id = await get_family_id_by_code(db, "FAM001")  # 실제 존재하는 family_code를 사용

        # PostgreSQL에 사진 정보 저장
        photo = await save_photo_to_db(photo_url, "Test Photo", family_id, db)

    print(f"Uploaded photo: {photo.photo_name}, URL: {photo.photo_url}")

# 실행
if __name__ == "__main__":
    asyncio.run(test_upload_photo())
