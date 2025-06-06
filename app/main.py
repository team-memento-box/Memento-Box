# 250605_1508 코드 추가해도 DB 잘 유지되는지????!!!
from fastapi import FastAPI, Header, HTTPException, Path, File, UploadFile, Form, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, JSONResponse
from datetime import date, datetime, timedelta
import os
import shutil
from pathlib import Path
from uuid import UUID, uuid4

from services.blob_storage import BlobStorageService 
from sqlalchemy.ext.asyncio import AsyncSession
from db.models.mention import Mention
from db.database import get_db

from routers import photo, audio_upload, user_create

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
app.include_router(audio_upload.router)
app.include_router(user_create.router)

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI with Nginx and PostgreSQL!"}
