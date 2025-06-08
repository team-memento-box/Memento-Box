from fastapi import APIRouter, HTTPException, File, UploadFile, Form, Depends, Response
from fastapi.responses import JSONResponse
from schemas.voice_system import VoiceSystem
import os

router = APIRouter()

@router.post("/api/tts")
async def text_to_speech(question: str = Form(...)):
    """GPT가 생성한 질문을 Azure TTS 기능을 통해 변환하여 어르신에게 자연스러운 의사소통 가능"""
    try:
        vs = VoiceSystem()
        audio_bytes = vs.synthesize_speech(question)

        if not audio_bytes:
            raise HTTPException(status_code=500, detail="TTS 변환 실패")

        return Response(content=audio_bytes, media_type="audio/mpeg")  # ✔ 바로 mp3 스트리밍

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))