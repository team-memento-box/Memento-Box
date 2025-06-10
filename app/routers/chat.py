from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Form, Response
from fastapi.responses import FileResponse, JSONResponse
from uuid import UUID
from sqlalchemy.orm import Session
from uuid import uuid4
from datetime import datetime, timezone, timedelta
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from db.database import get_db
from services.llm_system import OptimizedDementiaSystem, upload_audio_to_blob
from db.models.user import User
from db.models.turn import Turn
from db.models.conversation import Conversation
from schemas.turn import TurnRequest
from schemas.chat import ConversationCreate, TurnCreate

import uuid
import os
from fastapi import UploadFile


router = APIRouter(
    prefix="/api/chat",
    tags=["llm"]
)
system = OptimizedDementiaSystem()

# 이미지 기반 대화 세션 시작 (질문 생성) 
@router.post("/start")
async def start_chat(image_id: str, db: Session = Depends(get_db)):
    TEMP_DIR = "./temp_images"

    # 나중엔 id로 연동되게 바꾸기
    # image_path = os.path.join(TEMP_DIR, imagepath)
    image_path = os.path.join(TEMP_DIR, "48097797-a0c2-4c26-8e7b-e4220a51578c_스크린샷 2025-05-30 105216.png") # 11111111-1111-1111-1111-111111111111
    
    # [1] Conversation 데이터 생성 & 첫 질문 LLM 생성 및 
    # conversation_data = ConversationCreate(
    #     photo_id = image_id
    # )
    try:
        new_conversation = Conversation(
            id=uuid4(),
            photo_id=image_id,
            # created_at은 자동으로 처리됨 -> 과연
            created_at=datetime.now(timezone(timedelta(hours=9))).replace(tzinfo=None)
        )
        db.add(new_conversation)
        await db.commit()
        await db.refresh(new_conversation)
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"데이터베이스 저장 실패: {str(e)}")
    
    first_question, audio_path = system.analyze_and_start_conversation(image_path)
    conversation_id = new_conversation.id
    
    # [2] audio Blob 저장
    try:
        blob_url = await upload_audio_to_blob(audio_path)
    except:
        blob_url = "블롭 스토리지 에러"
    
    # [3] turn 데이터 추가
    new_turn = Turn(
        id=uuid4(),
        conv_id=conversation_id,
        turn={
            "q_text": first_question,
            "q_voice": blob_url,
            "a_text": None,
            "a_voice": None
        },
        recorded_at=datetime.now()
    )
    db.add(new_turn)
    db.commit()

    return JSONResponse(content={
        "status": "ok",
        "conversation_id": str(conversation_id),
        "question": first_question,
        "audio_url": blob_url
    })

# 답변 받고 Turn DB 업데이트
@router.post("/user_answer")
async def answer_chat(
    conversation_id: UUID = Form(...), 
    db: Session = Depends(get_db)
):
    # 1. 마지막 턴 가져오기
    stmt = select(Turn).where(Turn.conv_id == conversation_id).order_by(Turn.recorded_at.desc())
    result = await db.execute(stmt)
    last_turn = result.scalars().first()

    if not last_turn or not last_turn.turn:
        raise HTTPException(status_code=404, detail="No previous turn found")
    
    question = last_turn.turn.get("q_text")
    user_answer, audio_path, should_end = system._run_conversation(question, is_voice=True)

    # [2] audio Blob 저장
    try:
        blob_url = await upload_audio_to_blob(audio_path)
    except:
        blob_url = "블롭 스토리지 에러"

    # 3. 기존 턴에 유저 응답 업데이트
    updated_turn = last_turn.turn.copy()
    updated_turn["a_text"] = user_answer
    updated_turn["a_voice"] = blob_url

    last_turn.turn = updated_turn
    db.commit()

    
    return JSONResponse(content={
        "answer": user_answer, 
        "audio_url": blob_url, 
        "should_end": should_end
    })

# # 대화 종료 및 분석/요약 생성
# @router.post("/end")
# async def end_chat(conversation_id: UUID = Form(...)):
#     results = system.generate_complete_analysis(conversation_id)
#     return results

# # 음성 → 텍스트 변환	
# @router.post("/audio/stt")
# async def speech_to_text(audio: UploadFile):
#     path = system.save_temp_audio(audio)
#     try:
#         transcription = system.voice_system.transcribe_speech(path)
#         return JSONResponse(content={
#                 "status": "ok",
#                 "transcription": transcription
#             })
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

# # 텍스트 → 음성 변환
# @router.post("/audio/tts")
# async def text_to_speech(text: str = Form(...)):
#     try:
#         audio_bytes = system.voice_system.synthesize_speech(text)

#         if not audio_bytes:
#                 raise HTTPException(status_code=500, detail="TTS 변환 실패")
#         return Response(content=audio_bytes, media_type="audio/mpeg")  # ✔ 바로 mp3 스트리밍
    
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

# # 질답 1쌍 저장 (선택)
# @router.post("/save-turn")
# async def save_turn(turn_data: TurnRequest, db: Session = Depends(get_db)):
#     try:
#         new_turn = Turn(
#             id=uuid4(),
#             conv_id=turn_data.conv_id,
#             turn=turn_data.turn,
#             recorded_at=turn_data.recorded_at
#         )
#         db.add(new_turn)
#         db.commit()
#         return {"status": "success", "message": "Turn saved"}
#     except Exception as e:
#         db.rollback()
#         raise HTTPException(status_code=500, detail=str(e))