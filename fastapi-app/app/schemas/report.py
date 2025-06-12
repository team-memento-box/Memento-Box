from pydantic import BaseModel, Field
from uuid import UUID
from typing import List, Optional, Any
from datetime import datetime

class AnomalyReportResponse(BaseModel):
    reportId: UUID
    convId: UUID
    anomalyReport: Optional[str] = Field(default=None, description="이상 보고서 내용")
    anomalyTurn: Optional[Any] = Field(default=None, description="이상이 발생한 대화 턴")
    created_at: Optional[datetime] = Field(default=None, description="리포트 생성 시간")
    imageUrl: Optional[str] = Field(default=None, description="대화가 발생한 이미지 URL")

class AnomalyReportListResponse(BaseModel):
    status: str = Field(default="ok", description="응답 상태")
    data: List[AnomalyReportResponse] = Field(description="이상 보고서 목록")