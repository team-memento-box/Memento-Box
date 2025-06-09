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

    


