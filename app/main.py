# 250605_1508 코드 추가해도 DB 잘 유지되는지????!!!
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import photo



from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List, Optional
from datetime import datetime

# from models import User
# from database import SessionLocal, engine, Base

from pydantic import BaseModel
from db import User, UserCreate, UserRead, get_db

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 등록
app.include_router(photo.router)

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI with Nginx and PostgreSQL!"}

@app.post("/test_users/", response_model=UserRead)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = User(**user.dict())
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# ✅ 전체 사용자 조회 API
@app.get("/test_users/", response_model=List[UserRead])
def read_users(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    users = db.query(User).offset(skip).limit(limit).all()
    return users