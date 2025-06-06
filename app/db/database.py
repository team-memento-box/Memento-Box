from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from core.config import settings
from typing import AsyncGenerator
from sqlalchemy import MetaData

# 메타데이터 설정
metadata = MetaData()

# 모든 모델 클래스의 부모가 되는 기본 클래스 Base
Base = declarative_base(metadata=metadata)

# 1. 비동기 DB 엔진 생성
async_engine = create_async_engine(
    settings.ASYNC_DATABASE_URL,  # .env에서 불러온 연결 문자열
    echo=True,              # 로그 출력 (개발 시 디버깅에 유용)
    future=True            # 2.0 스타일 쿼리 사용
)

# 동기 엔진 생성 (마이그레이션용)
engine = create_engine(
    settings.SYNC_DATABASE_URL,
    echo=True,
    future=True
)

# 2. 비동기 세션 생성기
async_session = sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False  # 커밋 후 객체가 expire되지 않도록 설정
)

# 3. DB 세션 의존성
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()