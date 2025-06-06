from fastapi import APIRouter, Depends, File, UploadFile, HTTPException
from sqlalchemy.orm import Session
from typing import Optional
import os

from db.database import get_db
from db.models.models import DementiaTest
from services.voice_service import voice_service
from services.image_service import image_service
from services.story_service import story_service
from services.chat_service import chat_service
from core.config import settings

router = APIRouter()

@router.post("/test")
async def create_test(
    user_id: int,
    voice_file: Optional[UploadFile] = File(None),
    image_file: Optional[UploadFile] = File(None),
    story_text: Optional[str] = None,
    chat_text: Optional[str] = None,
    db: Session = Depends(get_db)
):
    try:
        scores = {}
        
        # Voice analysis
        if voice_file:
            voice_path = os.path.join(settings.AUDIO_DIR, voice_file.filename)
            with open(voice_path, "wb") as buffer:
                buffer.write(await voice_file.read())
            scores["voice_analysis_score"] = await voice_service.analyze_voice(voice_path)
            
        # Image analysis
        if image_file:
            image_path = os.path.join(settings.UPLOAD_DIR, image_file.filename)
            with open(image_path, "wb") as buffer:
                buffer.write(await image_file.read())
            scores["image_analysis_score"] = await image_service.analyze_image(image_path)
            
        # Story analysis
        if story_text:
            scores["story_analysis_score"] = await story_service.analyze_story(story_text)
            
        # Chat analysis
        if chat_text:
            scores["chat_analysis_score"] = await chat_service.analyze_chat(chat_text)
            
        # Calculate overall score
        if scores:
            overall_score = sum(scores.values()) / len(scores)
            scores["overall_score"] = overall_score
            
            # Create test record
            test = DementiaTest(user_id=user_id, **scores)
            db.add(test)
            db.commit()
            db.refresh(test)
            
            return test
        else:
            raise HTTPException(status_code=400, detail="No test data provided")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/story-prompt")
async def get_story_prompt():
    return {"prompt": await story_service.generate_story_prompt()} 