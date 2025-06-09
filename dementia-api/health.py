# health.py
"""
헬스체크 엔드포인트
"""

from fastapi import APIRouter
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

health_router = APIRouter(prefix="/health", tags=["health"])

def check_database_connection():
    """데이터베이스 연결 확인"""
    try:
        from database import SessionLocal
        db = SessionLocal()
        db.execute("SELECT 1").fetchone()
        db.close()
        return True
    except Exception as e:
        logger.error(f"데이터베이스 연결 실패: {e}")
        return False

def check_azure_services():
    """Azure 서비스 연결 확인 (간단한 버전)"""
    try:
        from config import Config
        # 기본적인 설정 확인
        return bool(Config.ENDPOINT and Config.SUBSCRIPTION_KEY)
    except Exception as e:
        logger.error(f"Azure 서비스 확인 실패: {e}")
        return False

@health_router.get("")
async def health_check():
    """기본 헬스체크"""
    return {
        "status": "ok",
        "message": "서버가 정상적으로 작동 중입니다",
        "timestamp": datetime.now().isoformat()
    }

@health_router.get("/detailed")
async def detailed_health_check():
    """상세 헬스체크"""
    db_status = check_database_connection()
    azure_status = check_azure_services()
    
    status = {
        "database": db_status,
        "azure_services": azure_status,
        "timestamp": datetime.now().isoformat()
    }
    
    # 모든 서비스가 정상인지 확인
    all_healthy = db_status and azure_status
    
    if all_healthy:
        return {
            "status": "ok",
            "message": "모든 시스템이 정상 작동 중입니다",
            "data": status
        }
    else:
        return {
            "status": "error", 
            "message": "일부 시스템에 문제가 있습니다",
            "data": status
        }

@health_router.get("/database")
async def database_health():
    """데이터베이스 헬스체크"""
    is_healthy = check_database_connection()
    
    if is_healthy:
        return {
            "status": "ok",
            "message": "데이터베이스가 정상 작동 중입니다"
        }
    else:
        return {
            "status": "error",
            "message": "데이터베이스 연결에 실패했습니다"
        }