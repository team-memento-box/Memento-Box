from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException,Body
from sqlalchemy.ext.asyncio import AsyncSession
from db.database import get_db
from services.blob_storage import get_blob_service_client
from sqlalchemy.future import select
from services.fish_TTS import VoiceConversionService
from db.models.conversation import Conversation
import requests
import io
from datetime import datetime
import uuid
from services.blob_storage import get_blob_service_client
from fastapi.responses import StreamingResponse
from pathlib import Path
router = APIRouter(prefix="/fish", tags=["fish-speech"])

@router.post("/convert")
async def convert_summary_voice(
    conversation_id: str = Body(...),
    a_voice_url: str = Body(...),
    summary_text: str = Body(...),
    db: AsyncSession = Depends(get_db)
):
    # 1. a_voice 파일 다운로드
    voice_response = requests.get(a_voice_url)
    if voice_response.status_code != 200:
        raise HTTPException(status_code=500, detail="Failed to download a_voice")
    audio_file = io.BytesIO(voice_response.content)
    audio_file.seek(0)

    # 2. Fish-Speech API 호출
    files = {
        'reference_wav': ('ref.wav', audio_file, 'audio/wav')
    }
    data = {
        'text': summary_text,  # 비워도 됨
        'prompt_text': summary_text
    }
    response = requests.post(
        "http://fish-speech:5000/infer",
        files=files,
        data=data
    )
    print("Fish-Speech 응답 status:", response.status_code)
    print("Fish-Speech 응답 content-type:", response.headers.get("content-type"))
    print("Fish-Speech 응답 content(앞부분):", response.content[:100])
    if response.status_code != 200 or b"RIFF" not in response.content[:4]:
        raise HTTPException(status_code=500, detail="Fish-Speech 변환 실패")

    # 3. Blob Storage 업로드
    blob_storage = get_blob_service_client("summary-voice")
    filename = f"summary_voice_{conversation_id}_{datetime.utcnow().strftime('%Y%m%d%H%M%S')}.wav"
    voice_url, blob_name = await blob_storage.upload_file(response.content, filename)

    # 4. Conversation에 저장
    result = await db.execute(
        select(Conversation).where(Conversation.id == conversation_id)
    )
    conversation = result.scalar_one_or_none()
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    conversation.summary_voice = voice_url
    await db.commit()

    return {"status": "success", "url": voice_url, "blob_name": blob_name}