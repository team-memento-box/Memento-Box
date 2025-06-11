from pydantic import BaseModel
from uuid import UUID
from typing import List, Optional, Any
from datetime import datetime

class AnomalyReportResponse(BaseModel):
    reportId: UUID
    convId: UUID
    anomalyReport: Optional[str]
    anomalyTurn: Optional[Any]  # JSON 형태로 받음

class AnomalyReportListResponse(BaseModel):
    status: str = "ok"
    data: List[AnomalyReportResponse]

class AnomalyReportDetailResponse(BaseModel):
    status: str = "ok"
    mentionId: UUID
    severity: str
    event_interval: str
    created_at: datetime
