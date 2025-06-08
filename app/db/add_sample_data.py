import uuid
from datetime import datetime
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
import os
import sys
from dotenv import load_dotenv
from core.auth import get_password_hash

# app 디렉토리를 Python 경로에 추가
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from db.models.family import Family
from db.models.user import User
from db.database import Base

# .env 파일 로드
load_dotenv()

DATABASE_URL = os.getenv("ASYNC_DATABASE_URL")

async def seed():
    engine = create_async_engine(DATABASE_URL, echo=True)
    async_session = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with async_session() as session:
        # 가상 Family 생성
        family_id = uuid.uuid4()
        family = Family(
            id=family_id,
            family_code="TESTFAMILY001",
            created_at=datetime.utcnow()
        )
        session.add(family)

        # 가상 User 생성
        user = User(
            id=uuid.uuid4(),
            kakao_id="kakao_test_001",
            password=get_password_hash("test1234"),  # 테스트용 비밀번호 추가
            username="테스트유저",
            gender="female",
            birthday=datetime(1990, 1, 1),
            profile_img=None,
            family_id=family_id,
            family_role="손녀",
            created_at=datetime.utcnow()
        )
        session.add(user)

        await session.commit()
        print(f"가상 Family UUID: {family_id}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(seed()) 