# 250605_1508 코드 추가해도 DB 잘 유지되는지????!!!
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from core.config import settings
from db.database import engine, Base

# 데이터베이스 테이블 생성 (동기 엔진 사용)
Base.metadata.create_all(bind=engine)

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

# 정적 파일 마운트
app.mount("/static", StaticFiles(directory=settings.STATIC_DIR), name="static")
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")
app.mount("/audio", StaticFiles(directory=settings.AUDIO_DIR), name="audio")

# 라우터 임포트
from routers.health import router as health_router
from routers.dementia import router as dementia_router
from routers.photo import router as photo_router
from routers.fish_speech import router as fish_speech_router
from routers.dialogue import router as dialogue_router

# 라우터 등록
app.include_router(health_router, prefix=settings.API_V1_STR)
app.include_router(photo_router, prefix=settings.API_V1_STR)
app.include_router(dementia_router, prefix=f"{settings.API_V1_STR}/dementia")
app.include_router(fish_speech_router, prefix=f"{settings.API_V1_STR}/fish-speech")
app.include_router(dialogue_router, prefix=f"{settings.API_V1_STR}/dialogue")

@app.get("/")
async def root():
    return {
        "message": "Welcome to Memento Box API System",
        "docs_url": "/docs",
        "redoc_url": "/redoc"
    }