from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Form
from typing import List, Optional
import os
import uuid
from datetime import datetime
from db.database import get_db
from db.models.turn import Turn
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from schemas.mention import MentionCreate, MentionResponse, QuestionAnswer
from services.blob_storage import get_blob_service_client
from core.auth import get_current_user
from db.models.user import User
import json

router = APIRouter(
    prefix="/api/mentions",
    tags=["mentions"]
)

@router.post("/upload", response_model=MentionResponse)
async def upload_mention(
    q_voice: UploadFile = File(...),
    a_voice: UploadFile = File(...),
    q_text: str = Form(...),
    a_text: str = Form(...),
    conv_id: uuid.UUID = Form(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    질문과 답변 음성 파일을 업로드하고 메타데이터를 저장합니다.
    """
    # 음성 파일 타입 검사
    if not q_voice.content_type.startswith('audio/') or not a_voice.content_type.startswith('audio/'):
        raise HTTPException(status_code=400, detail="음성 파일만 업로드 가능합니다.")

    temp_q_path = None
    temp_a_path = None
    try:
        # 임시 파일로 저장
        os.makedirs("uploads", exist_ok=True)
        
        # 질문 음성 파일 저장
        temp_q_path = f"uploads/{uuid.uuid4()}_{q_voice.filename}"
        with open(temp_q_path, "wb") as buffer:
            content = await q_voice.read()
            buffer.write(content)

        # 답변 음성 파일 저장
        temp_a_path = f"uploads/{uuid.uuid4()}_{a_voice.filename}"
        with open(temp_a_path, "wb") as buffer:
            content = await a_voice.read()
            buffer.write(content)

        # Blob Storage에 업로드
        blob_service_client = get_blob_service_client("talking-voice")
        
        # 질문 음성 업로드
        with open(temp_q_path, "rb") as f:
            q_voice_url, _ = await blob_service_client.upload_file(f.read(), q_voice.filename)
        
        # 답변 음성 업로드
        with open(temp_a_path, "rb") as f:
            a_voice_url, _ = await blob_service_client.upload_file(f.read(), a_voice.filename)

        # DB에 메타데이터 저장
        question_answer = QuestionAnswer(
            q_text=q_text,
            a_text=a_text,
            q_voice=q_voice_url,
            a_voice=a_voice_url
        )
        
        mention_data = MentionCreate(
            conv_id=conv_id,
            question_answer=question_answer,
            recorded_at=datetime.utcnow()
        )
        
        # DB에 저장
        mention = Mention(**mention_data.model_dump())
        db.add(mention)
        await db.commit()
        await db.refresh(mention)
        
        return MentionResponse.from_orm(mention)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        # 임시 파일 삭제
        if temp_q_path and os.path.exists(temp_q_path):
            os.remove(temp_q_path)
        if temp_a_path and os.path.exists(temp_a_path):
            os.remove(temp_a_path)

@router.get("/", response_model=List[MentionResponse])
async def list_mentions(
    conv_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    특정 대화의 모든 멘션을 조회합니다.
    """
    result = await db.execute(
        select(Mention).where(Mention.conv_id == conv_id)
    )
    mentions = result.scalars().all()
    return mentions

@router.get("/{mention_id}", response_model=MentionResponse)
async def get_mention(
    mention_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    특정 멘션의 상세 정보를 조회합니다.
    """
    result = await db.execute(
        select(Mention).where(Mention.id == mention_id)
    )
    mention = result.scalar_one_or_none()
    if not mention:
        raise HTTPException(status_code=404, detail="멘션을 찾을 수 없습니다.")
    return mention

@router.delete("/{mention_id}")
async def delete_mention(
    mention_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    특정 멘션을 삭제합니다.
    """
    result = await db.execute(
        select(Mention).where(Mention.id == mention_id)
    )
    mention = result.scalar_one_or_none()
    
    if not mention:
        raise HTTPException(status_code=404, detail="멘션을 찾을 수 없습니다.")
    
    # Blob Storage에서 파일 삭제
    blob_service_client = get_blob_service_client("voice")
    question_answer = mention.question_answer
    if question_answer.get("q_voice"):
        await blob_service_client.delete_file(question_answer["q_voice"].split("/")[-1])
    if question_answer.get("a_voice"):
        await blob_service_client.delete_file(question_answer["a_voice"].split("/")[-1])
    
    # DB에서 삭제
    await db.delete(mention)
    await db.commit()
    
    return {"message": "멘션이 삭제되었습니다."}