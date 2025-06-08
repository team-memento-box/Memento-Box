from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Form, status, Query, Path
from sqlalchemy.ext.asyncio import AsyncSession
from services.photo_management_service import PhotoManagementService
from services.photo_analysis_service import photo_analysis_service
from schemas.photo import Photo, PhotoCreate, PhotoAnalysis
from db.database import get_db
from typing import List, Optional, Dict
from uuid import UUID, uuid4
import json
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/photos",
    tags=["photos"],
    responses={
        404: {"description": "Not found"},
        500: {"description": "Internal server error"}
    }
)

# 테스트용 더미 가족 ID
TEST_FAMILY_ID = uuid4()

@router.post("/upload", 
    summary="사진 업로드",
    description="""
    새로운 사진을 업로드합니다.
    
    - **file**: 업로드할 이미지 파일 (필수)
    - **title**: 사진 제목
    - **description**: 사진 설명
    - **story_year**: 촬영 연도 (예: "2024")
    - **story_season**: 촬영 계절 (spring/summer/fall/winter)
    - **family_id**: 가족 ID (미입력시 테스트용 ID 사용)
    """,
    status_code=status.HTTP_201_CREATED
)
async def upload_photo(
    file: UploadFile = File(..., description="업로드할 이미지 파일"),
    title: Optional[str] = Form(None, description="사진 제목"),
    description: Optional[str] = Form(None, description="사진 설명"),
    story_year: Optional[str] = Form(None, description="촬영 연도"),
    story_season: Optional[str] = Form(None, description="촬영 계절"),
    story_nudge: Optional[str] = Form(None, description="넛지 데이터 (JSON)"),
    family_id: Optional[UUID] = Form(None, description="가족 ID"),
    db: AsyncSession = Depends(get_db)
):
    try:
        # 테스트용 더미 가족 ID 사용
        family_id = family_id or TEST_FAMILY_ID
        
        # 파일 타입 검증
        if not file.content_type.startswith('image/'):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="이미지 파일만 업로드 가능합니다."
            )
        
        # story_nudge JSON 파싱
        story_nudge_dict = None
        if story_nudge:
            try:
                story_nudge_dict = json.loads(story_nudge)
            except json.JSONDecodeError as e:
                logger.error(f"Invalid story_nudge format: {str(e)}")
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid story_nudge format: {str(e)}"
                )
        
        # 사진 관리 서비스 생성
        photo_service = PhotoManagementService(db)
        
        # 사진 업로드 및 DB 저장
        photo = await photo_service.create_photo(
            file=file,
            title=title or file.filename,
            description=description,
            story_year=story_year or "2024",
            story_season=story_season or "spring",
            story_nudge=story_nudge_dict,
            family_id=family_id
        )
        
        return photo
    except Exception as e:
        logger.error(f"Error in upload_photo: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.get("/", 
    summary="사진 목록 조회",
    description="""
    사진 목록을 조회합니다.
    
    - **family_id**: 특정 가족의 사진만 조회 (선택)
    - **skip**: 건너뛸 항목 수
    - **limit**: 반환할 최대 항목 수
    """,
    response_model=List[dict]
)
async def list_photos(
    family_id: Optional[UUID] = Query(None, description="특정 가족의 사진만 조회"),
    skip: int = Query(0, description="건너뛸 항목 수"),
    limit: int = Query(100, description="반환할 최대 항목 수"),
    db: AsyncSession = Depends(get_db)
):
    try:
        # 테스트용 더미 가족 ID 사용
        family_id = family_id or TEST_FAMILY_ID
        
        photo_service = PhotoManagementService(db)
        photos = await photo_service.get_photos(
            family_id=family_id,
            skip=skip,
            limit=limit
        )
        return photos
    except Exception as e:
        logger.error(f"Error in list_photos: {str(e)}")
        return []

@router.get("/{photo_id}",
    summary="특정 사진 조회",
    description="ID로 특정 사진을 조회합니다."
)
async def get_photo(
    photo_id: int = Path(..., description="조회할 사진 ID"),
    db: AsyncSession = Depends(get_db)
):
    try:
        photo_service = PhotoManagementService(db)
        photo = await photo_service.get_photo(photo_id)
        if not photo:
            return {
                "message": "Photo not found",
                "photo_id": photo_id
            }
        return photo
    except Exception as e:
        logger.error(f"Error in get_photo: {str(e)}")
        return {
            "message": "Error retrieving photo",
            "photo_id": photo_id,
            "error": str(e)
        }

@router.post("/{photo_id}/analyze",
    summary="사진 분석",
    description="""
    사진을 분석하여 다음 정보를 추출합니다:
    
    - 인물 (people)
    - 관계 (relationships)
    - 장소 (location)
    - 분위기 (mood)
    - 주요 객체 (key_objects)
    - 키워드 (keywords)
    - 상황 (situation)
    """
)
async def analyze_photo(
    photo_id: int = Path(..., description="분석할 사진 ID"),
    db: AsyncSession = Depends(get_db)
):
    try:
        photo_service = PhotoManagementService(db)
        photo = await photo_service.get_photo(photo_id)
        
        if not photo:
            return {
                "message": "Photo not found",
                "photo_id": photo_id
            }
            
        # 더미 분석 결과 반환
        analysis_result = {
            "people": ["Person 1", "Person 2"],
            "relationships": "Family members",
            "location": "Indoor setting",
            "mood": "Happy",
            "key_objects": ["Table", "Chair", "Window"],
            "keywords": ["Family", "Indoor", "Happy"],
            "situation": "Family gathering"
        }
        
        await photo_service.update_analysis(photo_id, analysis_result)
        return analysis_result
    except Exception as e:
        logger.error(f"Error in analyze_photo: {str(e)}")
        return {
            "message": "Error analyzing photo",
            "photo_id": photo_id,
            "error": str(e)
        }

@router.delete("/{photo_id}",
    summary="사진 삭제",
    description="특정 사진을 삭제합니다.",
    status_code=status.HTTP_200_OK
)
async def delete_photo(
    photo_id: int = Path(..., description="삭제할 사진 ID"),
    db: AsyncSession = Depends(get_db)
):
    try:
        photo_service = PhotoManagementService(db)
        success = await photo_service.delete_photo(photo_id)
        if success:
            return {"message": "Photo deleted successfully"}
        return {"message": "Photo not found"}
    except Exception as e:
        logger.error(f"Error in delete_photo: {str(e)}")
        return {
            "message": "Error deleting photo",
            "photo_id": photo_id,
            "error": str(e)
        } 