from fastapi import APIRouter, HTTPException
import requests
from core.config import settings

router = APIRouter()

@router.post("/chat")
async def chat(message: str):
    try:
        response = requests.post(
            f"{settings.DIALOGUE_URL}/chat",
            json={"message": message}
        )
        response.raise_for_status()
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Dialogue processing failed: {str(e)}")

@router.get("/status")
async def get_status():
    try:
        response = requests.get(f"{settings.DIALOGUE_URL}/status")
        response.raise_for_status()
        return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Dialogue service status check failed: {str(e)}") 