import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from core.config import settings
from db.database import init_models
from routers import (
    photo_router,
    user_router,
    family_router,
    conversation_router,
    health_router
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static files
app.mount("/static", StaticFiles(directory=settings.STATIC_DIR), name="static")
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")
app.mount("/audio", StaticFiles(directory=settings.AUDIO_DIR), name="audio")

# 라우터 등록
app.include_router(
    photo_router,
    prefix=settings.API_V1_STR,
    tags=["photos"]
)

app.include_router(
    user_router,
    prefix=settings.API_V1_STR,
    tags=["users"]
)

app.include_router(
    family_router,
    prefix=settings.API_V1_STR,
    tags=["families"]
)

app.include_router(
    conversation_router,
    prefix=settings.API_V1_STR,
    tags=["conversations"]
)

app.include_router(
    health_router,
    prefix=settings.API_V1_STR,
    tags=["health"]
)

@app.on_event("startup")
async def startup_event():
    """
    앱 시작 시 초기화 작업
    """
    try:
        logger.info("Initializing database models...")
        await init_models()
        logger.info("Database initialization completed")
    except Exception as e:
        logger.error(f"Failed to initialize application: {str(e)}")
        raise

@app.get("/", tags=["health"])
async def read_root():
    """
    Health check endpoint
    """
    return {
        "status": "healthy",
        "version": "1.0.0",
        "service": settings.PROJECT_NAME
    }