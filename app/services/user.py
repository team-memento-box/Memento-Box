from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional, List
from uuid import UUID
from fastapi import HTTPException
from db.models.user import User
from schemas.user import UserCreate, UserUpdate
from datetime import datetime
import uuid

class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db

    
   