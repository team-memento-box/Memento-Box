from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import FileResponse
import shutil
import requests
import uuid
import os
import time
from sqlalchemy import create_engine, desc
from sqlalchemy.orm import sessionmaker
from models import Base, Report  # Report 모델은 dialog-service의 DB schema와 동일하게 정의해야 함

app = FastAPI()

# PostgreSQL 연결 설정 (환경 변수나 설정 파일로 관리해도 됨)
#DATABASE_URL = "postgresql://user:password@db:5432/ttsdb"
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)

@app.post("/upload")
async def upload(
    user_id: str = Form(...),
    prompt_text: str = Form(""),
    file: UploadFile = File(...)
):
    filename = f"{uuid.uuid4().hex}.wav"
    input_path = f"/app/input_wav/{filename}"
    output_path = f"/app/output_wav/{filename}"

    # 1. 파일 저장
    with open(input_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 2. DB에서 가장 최근 리포트 가져오기
    try:
        db = SessionLocal()
        report = db.query(Report).filter(Report.user_id == user_id).order_by(desc(Report.timestamp)).first()
    finally:
        db.close()

    if not report:
        return {
            "status": "error",
            "message": f"No report found for user_id={user_id}"
        }

    # 3. fish-speech에 추론 요청
    response = requests.post("http://fish-speech:5000/infer", json={
        "text": report.content,
        "reference_wav": filename,
        "prompt_text": prompt_text
    })

    result = response.json()

    if result.get("status") == "success" and os.path.exists(output_path):
        return FileResponse(output_path, media_type="audio/wav", filename=filename)
    else:
        return {
            "status": "error",
            "message": result.get("message", "inference failed or took too long."),
            "filename": filename
        }
