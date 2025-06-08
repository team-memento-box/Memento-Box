from fastapi import APIRouter, UploadFile, HTTPException, File
from fastapi.responses import JSONResponse
import os
from schemas.voice_system import VoiceSystem
from schemas.chat_system import ChatSystem

voice_system = VoiceSystem()
chat_system = ChatSystem()

router = APIRouter()

# 6. STT (음성 사용자)
@router.post("/api/stt")
async def speech_to_text(file: UploadFile = File(...)):
    """사용자의 음성 파일(.wav)을 text로 변환"""
    try:
        # STT 처리
        transcription = voice_system.transcribe_speech_wav2(file)
        
        return JSONResponse(content={
            "status": "ok",
            "transcription": transcription
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))