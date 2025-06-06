# routers/audio_upload.py
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from fastapi.responses import JSONResponse
from uuid import uuid4
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from db.database import get_db
from db.models.mention import Mention
from services.blob_storage import BlobStorageService

router = APIRouter()

@router.post("/api/answers/audio")
async def upload_audio_answer(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    try:
        if not file.filename.endswith(".wav"):
            raise HTTPException(status_code=400, detail="Only .wav files are supported.")

        file_data = await file.read()
        blob_service = BlobStorageService()
        blob_url, blob_name = await blob_service.upload_file(file_data, file.filename)

        mention = Mention(
            id=uuid4(),
            conv_id=uuid4(),  # 임시 ID, 실제 연결 필요 시 교체
            question_answer={
                "q_text": "임시 질문",
                "a_text": "임시 답변",
                "q_voice": None,
                "a_voice": blob_url
            },
            recorded_at=datetime.now()
        )

        db.add(mention)

        return JSONResponse(content={
            "status": "ok",
            "blob_url": blob_url,
            "blob_name": blob_name,
            "mention_id": str(mention.id)
        })

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")
