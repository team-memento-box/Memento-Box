import os
import uuid
import json
from core.auth import get_current_user
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Form, Query
from typing import List, Optional, Dict, Any
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import joinedload

from db.database import get_db
from db.models.user import User
from db.models.photo import Photo
from db.models.conversation import Conversation
from db.models.anomaly_report import AnomalyReport
from schemas.anomaly_report import AnomalyReportResponse, AnomalyReportListResponse, AnomalyReportDetailResponse
from services.get_reports import get_anomaly_reports

router = APIRouter(
    prefix="/api/reports",
    tags=["photos"]
)


@router.get(
    "/",
    response_model=AnomalyReportListResponse,
    summary="가족의 이상 대화 리포트 목록 조회",
    description="현재 로그인한 사용자의 가족(family_id)에 속한 모든 이상 대화 리포트를 조회합니다. 최신 순 정렬"
)
async def get_family_anomaly_reports(
    current_user: User = Depends(get_current_user),  # 사용자 인증 정보
    db: AsyncSession = Depends(get_db)
):
    reports = await get_anomaly_reports(db, current_user.family_id)

    return reports

@router.get(
    "/{report_id}",
    response_model=AnomalyReportDetailResponse,
    summary="이상 대화 리포트 단건 조회",
    description="현재 로그인한 사용자의 가족(family_id)에 속한 특정 이상 대화 리포트를 조회합니다."
)
async def get_anomaly_report_detail(
    report_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    try:
        stmt = (
            select(AnomalyReport)
            .join(AnomalyReport.conversation)
            .join(Conversation.photo)
            .where(
                AnomalyReport.id == report_id,
                Photo.family_id == current_user.family_id
            )
            .options(joinedload(AnomalyReport.conversation))
        )

        result = await db.execute(stmt)
        report = result.scalar_one_or_none()

        if not report:
            raise HTTPException(status_code=404, detail="리포트를 찾을 수 없거나 접근 권한이 없습니다.")

        return AnomalyReportDetailResponse(
            status="ok",
            mentionId=report.id,
            severity="none",  # 예시: 고정 값 또는 추출 방식 변경 가능
            event_interval=report.anomaly_report or "내용 없음",  # anomaly_report를 그대로 사용
            created_at=report.conversation.created_at
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"리포트 조회 실패: {str(e)}")
