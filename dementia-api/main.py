from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
import os
import logging
from pathlib import Path
import uvicorn
from datetime import datetime

# 기본 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 환경 변수에서 설정 읽기
def get_env_bool(key: str, default: bool = False) -> bool:
    """환경 변수를 bool로 변환"""
    value = os.getenv(key, str(default)).lower()
    return value in ('true', '1', 'yes', 'on')

# FastAPI 앱 생성
app = FastAPI(
    title="치매 진단 대화 시스템 API",
    description="이미지 기반 치매 진단을 위한 대화형 AI 시스템",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:8080", 
        "http://127.0.0.1:8080",
        "capacitor://localhost",
        "ionic://localhost",
        "http://localhost",
        "*"  # 개발 환경에서는 모든 origin 허용
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# 기본 응답 유틸리티
def success_response(data=None, message="Success"):
    """성공 응답 생성"""
    response = {
        "status": "ok",
        "message": message,
        "timestamp": datetime.now().isoformat()
    }
    if data is not None:
        response["data"] = data
    return response

def error_response(error, code=500):
    """에러 응답 생성"""
    return {
        "status": "error",
        "error": error,
        "code": code,
        "timestamp": datetime.now().isoformat()
    }

# 예외 핸들러
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """요청 검증 오류 처리"""
    logger.warning(f"요청 검증 실패: {exc.errors()}")
    return JSONResponse(
        status_code=422,
        content=error_response("요청 데이터가 올바르지 않습니다", 422)
    )

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """HTTP 예외 처리"""
    logger.warning(f"HTTP 예외: {exc.status_code} - {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content=error_response(exc.detail, exc.status_code)
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """일반 예외 처리"""
    logger.error(f"예상치 못한 오류: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content=error_response("서버 내부 오류가 발생했습니다", 500)
    )

# 필요한 디렉토리 생성
def create_directories():
    """필요한 디렉토리들을 생성"""
    directories = ["uploads", "audio_files", "logs", "static"]
    for directory in directories:
        Path(directory).mkdir(exist_ok=True)
        logger.info(f"디렉토리 생성 확인: {directory}")

# 시스템 초기화
def initialize_system():
    """시스템 초기화"""
    try:
        create_directories()
        logger.info("시스템 초기화 완료")
        return True
    except Exception as e:
        logger.error(f"시스템 초기화 실패: {e}")
        return False

# 앱 시작 이벤트
@app.on_event("startup")
async def startup_event():
    """애플리케이션 시작 시 실행"""
    logger.info("🚀 치매 진단 대화 시스템 API 서버 시작")
    
    if not initialize_system():
        logger.error("❌ 시스템 초기화 실패")
        exit(1)
    
    logger.info("✅ 시스템 초기화 완료")
    logger.info("📋 API 문서: http://localhost:8000/docs")

# 앱 종료 이벤트
@app.on_event("shutdown")
async def shutdown_event():
    """애플리케이션 종료 시 실행"""
    logger.info("🛑 서버 종료")

# 헬스체크 엔드포인트
@app.get("/health")
async def health_check():
    """기본 헬스체크"""
    return success_response({
        "status": "healthy",
        "uptime": "running"
    }, "서버가 정상적으로 작동 중입니다")

@app.get("/health/detailed")
async def detailed_health_check():
    """상세 헬스체크"""
    try:
        # 간단한 상태 확인
        status = {
            "server": True,
            "timestamp": datetime.now().isoformat()
        }
        
        # 데이터베이스 확인 시도
        try:
            from database import SessionLocal
            db = SessionLocal()
            db.execute("SELECT 1").fetchone()
            db.close()
            status["database"] = True
        except Exception as e:
            logger.warning(f"데이터베이스 확인 실패: {e}")
            status["database"] = False
        
        # 설정 파일 확인
        try:
            from config import Config
            status["config"] = bool(Config.ENDPOINT)
        except Exception as e:
            logger.warning(f"설정 확인 실패: {e}")
            status["config"] = False
        
        return success_response(status, "상세 헬스체크 완료")
        
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content=error_response(f"헬스체크 실패: {str(e)}", 500)
        )

# 정적 파일 서빙 (디렉토리가 존재할 때만)
if Path("uploads").exists():
    app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
if Path("audio_files").exists():
    app.mount("/audio", StaticFiles(directory="audio_files"), name="audio") 
if Path("static").exists():
    app.mount("/static", StaticFiles(directory="static"), name="static")

# API 라우터 포함 (파일이 존재할 때만)
try:
    from api.routes import router as api_router
    app.include_router(api_router)
    logger.info("✅ API 라우터 로드 완료")
except ImportError as e:
    logger.warning(f"⚠️ API 라우터 로드 실패: {e}")
    logger.info("기본 엔드포인트만 사용합니다")

# 루트 경로 - 간단한 API 정보
@app.get("/")
async def read_root():
    """메인 페이지 - API 정보"""
    return success_response({
        "service": "치매 진단 대화 시스템 API",
        "version": "2.0.0",
        "status": "운영 중",
        "docs": "/docs",
        "health": "/health",
        "available_endpoints": {
            "basic": [
                "GET /",
                "GET /health", 
                "GET /health/detailed",
                "GET /docs",
                "GET /api/version"
            ],
            "api": "API 라우터 로드 상태에 따라 추가됨"
        }
    })

# API 버전 정보
@app.get("/api/version")
async def get_version():
    """API 버전 정보"""
    return success_response({
        "version": "2.0.0",
        "build_time": datetime.now().isoformat(),
        "environment": "development" if get_env_bool("DEBUG") else "production",
        "features": [
            "기본 API 서버",
            "헬스체크",
            "에러 처리",
            "CORS 지원"
        ]
    })

# 개발 환경 전용 엔드포인트
if get_env_bool("DEBUG", False):
    @app.get("/debug/info")
    async def debug_info():
        """개발용: 디버그 정보"""
        return {
            "환경변수": {
                "DEBUG": get_env_bool("DEBUG"),
                "HOST": os.getenv("HOST", "0.0.0.0"),
                "PORT": os.getenv("PORT", "8000")
            },
            "디렉토리": {
                "uploads": Path("uploads").exists(),
                "audio_files": Path("audio_files").exists(),
                "logs": Path("logs").exists()
            },
            "모듈상태": {
                "database": "database.py를 확인하세요",
                "config": "config.py를 확인하세요", 
                "api_routes": "api/routes.py를 확인하세요"
            }
        }

# 메인 실행부
if __name__ == "__main__":
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    debug = get_env_bool("DEBUG", False)
    
    logger.info(f"서버 설정 - Host: {host}, Port: {port}, Debug: {debug}")
    
    try:
        uvicorn.run(
            "main:app" if debug else app,
            host=host,
            port=port,
            reload=debug,
            log_level="debug" if debug else "info"
        )
    except Exception as e:
        logger.error(f"서버 시작 실패: {e}")
        print(f"\n❌ 서버 실행 중 오류 발생: {e}")
        print("\n🔧 해결 방법:")
        print("1. 필요한 파일들이 모두 있는지 확인")
        print("2. .env 파일 설정 확인")
        print("3. python -m pip install -r requirements.txt")
        print("4. python scripts/setup_dev.py 실행")