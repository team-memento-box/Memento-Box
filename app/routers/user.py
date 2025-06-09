from fastapi import APIRouter, Depends, HTTPException
from typing import List
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from db.database import get_db
from services.user import UserService
from schemas.user import UserCreate, UserUpdate, UserResponse
from core.auth import get_current_user
from db.models.user import User

router = APIRouter(
    prefix="/api/users",
    tags=["users"]
)

