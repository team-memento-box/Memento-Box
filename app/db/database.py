from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from core.config import settings
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create base class for models
Base = declarative_base()

# Create async engine
engine = create_async_engine(
    settings.ASYNC_DATABASE_URL,
    echo=True,
    future=True,
    pool_pre_ping=True  # Enable connection health checks
)

# Create async session factory
async_session = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False  # Disable autoflush for better control
)

# Dependency to get DB session
async def get_db() -> AsyncSession:
    """
    Dependency to get database session.
    """
    async with async_session() as session:
        try:
            yield session
            await session.commit()
        except Exception as e:
            logger.error(f"Database error: {str(e)}")
            await session.rollback()
            raise
        finally:
            await session.close()

# Initialize database
async def init_models():
    """
    Initialize database models.
    """
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
            logger.info("Database models initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize database models: {str(e)}")
        raise

# Cleanup database
async def cleanup_db():
    """
    Cleanup database.
    """
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)