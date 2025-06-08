from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Form, status, Query, Path
from sqlalchemy.ext.asyncio import AsyncSession
from services.photo_management_service import PhotoManagementService
from services.photo_analysis_service import photo_analysis_service
from schemas.photo import Photo, PhotoCreate
from schemas.photo_analysis import PhotoAnalysis
from db.database import get_db
from typing import List, Optional, Dict
from uuid import UUID, uuid4
import json
import logging
from datetime import datetime

router = APIRouter()

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
                # logger.error(f"Invalid story_nudge format: {str(e)}")
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
        # logger.error(f"Error in upload_photo: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )