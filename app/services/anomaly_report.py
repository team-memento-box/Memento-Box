from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional, List
from uuid import UUID
from fastapi import HTTPException
from db.models.anomaly_report import AnomalyReport
from schemas.anomaly_report import AnomalyReportCreate, AnomalyReportUpdate
from datetime import datetime
import uuid

class AnomalyReportService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_report(self, report_in: AnomalyReportCreate) -> AnomalyReport:
        """새로운 이상 보고서를 생성합니다."""
        report = AnomalyReport(
            id=uuid.uuid4(),
            user_id=report_in.user_id,
            photo_id=report_in.photo_id,
            report_type=report_in.report_type,
            description=report_in.description,
            status=report_in.status,
            created_at=datetime.utcnow()
        )
        self.db.add(report)
        await self.db.commit()
        await self.db.refresh(report)
        return report

    async def get_report(self, report_id: UUID) -> Optional[AnomalyReport]:
        """특정 이상 보고서를 조회합니다."""
        result = await self.db.execute(
            select(AnomalyReport).where(AnomalyReport.id == report_id)
        )
        return result.scalar_one_or_none()

    async def get_reports_by_user(self, user_id: UUID) -> List[AnomalyReport]:
        """특정 사용자의 모든 이상 보고서를 조회합니다."""
        result = await self.db.execute(
            select(AnomalyReport).where(AnomalyReport.user_id == user_id)
        )
        return result.scalars().all()

    async def get_reports_by_photo(self, photo_id: UUID) -> List[AnomalyReport]:
        """특정 사진의 모든 이상 보고서를 조회합니다."""
        result = await self.db.execute(
            select(AnomalyReport).where(AnomalyReport.photo_id == photo_id)
        )
        return result.scalars().all()

    async def update_report(self, report_id: UUID, report_in: AnomalyReportUpdate) -> Optional[AnomalyReport]:
        """이상 보고서 정보를 업데이트합니다."""
        report = await self.get_report(report_id)
        if not report:
            return None

        for key, value in report_in.dict(exclude_unset=True).items():
            setattr(report, key, value)

        await self.db.commit()
        await self.db.refresh(report)
        return report

    async def delete_report(self, report_id: UUID) -> bool:
        """이상 보고서를 삭제합니다."""
        report = await self.get_report(report_id)
        if not report:
            return False

        await self.db.delete(report)
        await self.db.commit()
        return True


