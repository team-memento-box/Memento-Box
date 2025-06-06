from fastapi import APIRouter, HTTPException
import requests
from core.config import settings

router = APIRouter()

@router.post("/process")
async def process_fish_speech(audio_data: bytes):
    try:
        response = requests.post(
            f"{settings.FISH_SPEECH_URL}/process",
            data=audio_data,
            headers={"Content-Type": "audio/wav"}
        )
        response.raise_for_status()
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Fish speech processing failed: {str(e)}")

@router.get("/status")
async def get_status():
    try:
        response = requests.get(f"{settings.FISH_SPEECH_URL}/status")
        response.raise_for_status()
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Fish speech service status check failed: {str(e)}") 