from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Form
from typing import List, Optional, Dict, Any
import os
import uuid
from datetime import datetime
from db.database import get_db
from db.models.turn import Turn
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from schemas.turn import TurnCreate, TurnAllResponse
from services.blob_storage import get_blob_service_client
from core.auth import get_current_user
from db.models.user import User
import json
from services.turn import TurnService

router = APIRouter(
    prefix="/api/turns",
    tags=["turns"]
)

@router.post("/upload", response_model=TurnAllResponse)
async def upload_turn(
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
        turn_data = {
            "q_text": q_text,
            "a_text": a_text,
            "q_voice": q_voice_url,
            "a_voice": a_voice_url
        }
        
        turn_service = TurnService(db)
        turn = await turn_service.create_turn(
            q_voice=q_voice,
            a_voice=a_voice,
            q_text=q_text,
            a_text=a_text,
            conv_id=conv_id
        )
        
        return TurnAllResponse.from_orm(turn)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        # 임시 파일 삭제
        if temp_q_path and os.path.exists(temp_q_path):
            os.remove(temp_q_path)
        if temp_a_path and os.path.exists(temp_a_path):
            os.remove(temp_a_path)

@router.get("/", response_model=List[TurnAllResponse])
async def list_turns(
    conv_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    특정 대화의 모든 턴을 조회합니다.
    """
    turn_service = TurnService(db)
    turns = await turn_service.get_turns_by_conversation(conv_id)
    return turns

@router.get("/{turn_id}", response_model=TurnAllResponse)
async def get_turn(
    turn_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    특정 턴의 상세 정보를 조회합니다.
    """
    turn_service = TurnService(db)
    turn = await turn_service.get_turn(turn_id)
    if not turn:
        raise HTTPException(status_code=404, detail="턴을 찾을 수 없습니다.")
    return turn

@router.delete("/{turn_id}")
async def delete_turn(
    turn_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    특정 턴을 삭제합니다.
    """
    turn_service = TurnService(db)
    success = await turn_service.delete_turn(turn_id)
    if not success:
        raise HTTPException(status_code=404, detail="턴을 찾을 수 없습니다.")
    return {"message": "턴이 삭제되었습니다."}