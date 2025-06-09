from pydantic import BaseModel, ConfigDict
from typing import Optional, Dict, Any
from uuid import UUID

class AnomalyReportBase(BaseModel):
    """
    이상현상 리포트 기본 스키마
    """
    conv_id: UUID
    anomaly_report: Optional[str] = None
    anomaly_turn: Optional[Dict[str, Any]] = None

class AnomalyReportCreate(AnomalyReportBase):
    """
    이상현상 리포트 생성 스키마
    """
    pass

class AnomalyReportResponse(AnomalyReportBase):
    """
    이상현상 리포트 응답 스키마
    """
    id: UUID
    
    model_config = ConfigDict(from_attributes=True)