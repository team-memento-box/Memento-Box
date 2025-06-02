import os
import sys
import asyncio
from logging.config import fileConfig

from sqlalchemy import pool
from sqlalchemy.ext.asyncio import create_async_engine
from alembic import context
from dotenv import load_dotenv

# ⬇️ 1. 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# ⬇️ 2. .env 파일 로드
load_dotenv()

# ⬇️ 3. Alembic 설정 객체 (alembic.ini 기반)
config = context.config

# ⬇️ 4. 로깅 구성 (선택 사항)
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# ⬇️ 5. DATABASE_URL 결정 (.env 우선)
DATABASE_URL = os.getenv("DATABASE_URL")
if DATABASE_URL is None:
    DATABASE_URL = (
        f"postgresql+asyncpg://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )

# ⬇️ 6. sqlalchemy.url 덮어쓰기
config.set_main_option("sqlalchemy.url", DATABASE_URL)

# ⬇️ 7. ORM Base 및 모델들 import
from app.database import Base
from app.models import user, photo, family, conversation, mention, anomalies_report

target_metadata = Base.metadata

# ⬇️ 8. Async 엔진 생성
connectable = create_async_engine(DATABASE_URL, poolclass=pool.NullPool)

async def run_migrations():
    async with connectable.begin() as conn:
        await conn.run_sync(do_run_migrations)

def do_run_migrations(connection):
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        compare_type=True,  # 컬럼 타입 변경 감지
    )

    with context.begin_transaction():
        context.run_migrations()

def run_async_migrations():
    asyncio.run(run_migrations())

if context.is_offline_mode():
    context.configure(url=DATABASE_URL, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()
else:
    run_async_migrations()



