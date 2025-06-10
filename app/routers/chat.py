from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Form, Response
from fastapi.responses import FileResponse, JSONResponse
from uuid import UUID
from sqlalchemy.orm import Session
from uuid import uuid4
from datetime import datetime
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from db.database import get_db
from services.llm_system import OptimizedDementiaSystem
from db.models.user import User
from db.models.turn import Turn
from db.models.conversation import Conversation
from schemas.turn import TurnRequest

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

    # def save_temp_image(image: UploadFile) -> str:
    #     if not os.path.exists(TEMP_DIR):
    #         os.makedirs(TEMP_DIR)

    #     file_id = str(uuid.uuid4())
    #     filename = f"{file_id}_{image.filename}"
    #     path = os.path.join(TEMP_DIR, filename)

    #     with open(path, "wb") as f:
    #         contents = image.file.read()
    #         f.write(contents)

    #     return path

    # 나중엔 id로 연동되게 바꾸기
    # image_path = os.path.join(TEMP_DIR, imagepath)
    image_path = os.path.join(TEMP_DIR, "48097797-a0c2-4c26-8e7b-e4220a51578c_스크린샷 2025-05-30 105216.png")
    # 11111111-1111-1111-1111-111111111111
    conversation_id, first_question = system.analyze_and_start_conversation(image_path)

    # conv도 새로 생성됐으니 DB에 추가해주기
    new_conversation = Conversation(
        id = conversation_id,
        photo_id = image_id, # 여기도 나중에 변경
        created_at = datetime.now(),
    )
    db.add(new_conversation)
    db.commit()

    # 첫 질문은 세션에 임시 저장 (Turn 테이블에는 질의응답 쌍이 완성될 때 저장)

    return JSONResponse(content={
        "status": "ok",
        "conversation_id": str(conversation_id),
        "question": first_question
    })

# 답변 받고 Turn DB 업데이트
@router.post("/user_answer")
async def answer_chat(
    conversation_id: UUID = Form(...),
    current_question: str = Form(...),  # 현재 질문
    user_answer: str = Form(...),  # 사용자 답변
    audio_path: str = Form(None),  # 음성 파일 경로 (선택적)
    db: Session = Depends(get_db)
):
    # 1. 종료 키워드 체크
    should_end = system.check_end_keywords(user_answer)
    
    # 2. 질의응답 쌍을 하나의 Turn으로 저장
    qa_turn = Turn(
        id=uuid4(),
        conv_id=conversation_id,
        turn={
            "q_text": current_question,
            "q_voice": None,  # 추후 TTS 파일 경로
            "a_text": user_answer,
            "a_voice": audio_path
        },
        recorded_at=datetime.now()
    )
    db.add(qa_turn)
    db.commit()

    # 3. 종료가 아닌 경우 다음 질문 생성
    next_question = None
    if not should_end:
        next_question = system.generate_next_question(current_question, user_answer)

    return {
        "user_answer": user_answer, 
        "should_end": should_end,
        "next_question": next_question if not should_end else None
    }

# 강제 대화 종료 (프런트에서 종료 버튼 클릭 시)
@router.post("/force-end")
async def force_end_chat(
    conversation_id: UUID = Form(...), 
    current_question: str = Form(None),  # 현재 진행 중인 질문 (있다면)
    db: Session = Depends(get_db)
):
    """프런트에서 강제 종료 버튼을 눌렀을 때 사용"""
    
    # 현재 진행 중인 질문이 있다면 답변 null로 저장
    if current_question and current_question.strip():
        # 사용자가 답변하지 않은 질문을 답변 null로 저장
        force_end_turn = Turn(
            id=uuid4(),
            conv_id=conversation_id,
            turn={
                "q_text": current_question,
                "q_voice": None,
                "a_text": None,  # 답변하지 않았으므로 null 처리
                "a_voice": None
            },
            recorded_at=datetime.now()
        )
        db.add(force_end_turn)
        db.commit()
        
        print(f"🔚 강제 종료: 미답변 질문을 null 처리하여 저장했습니다. (conversation_id: {conversation_id})")
    
    # 기존 end 로직 호출
    return await end_chat(conversation_id, db)

# 대화 종료 및 분석/요약 생성
@router.post("/end")
async def end_chat(conversation_id: UUID = Form(...), db: Session = Depends(get_db)):
    # 1. conversation_id로 모든 Turn 데이터 가져오기
    stmt = select(Turn).where(Turn.conv_id == conversation_id).order_by(Turn.recorded_at.asc())
    result = await db.execute(stmt)
    turns = result.scalars().all()
    
    if not turns:
        raise HTTPException(status_code=404, detail="No turns found for this conversation")
    
    # 2. Turn 데이터를 스토리 생성에 사용할 수 있는 형태로 변환
    results = system.generate_complete_analysis_from_turns(turns, conversation_id)
    return results



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

# 🧪 테스트용 엔드포인트들
@router.post("/test/upload-image")
async def upload_test_image(image: UploadFile = File(...)):
    """테스트용 이미지 업로드"""
    TEMP_DIR = "./temp_images"
    
    if not os.path.exists(TEMP_DIR):
        os.makedirs(TEMP_DIR)
    
    # 파일 저장
    file_id = str(uuid.uuid4())
    filename = f"{file_id}_{image.filename}"
    file_path = os.path.join(TEMP_DIR, filename)
    
    with open(file_path, "wb") as f:
        content = await image.read()
        f.write(content)
    
    return {
        "status": "success",
        "file_id": file_id,
        "filename": filename,
        "path": file_path,
        "message": "이미지가 업로드되었습니다. 이제 /start 엔드포인트에서 이 file_id를 사용하세요."
    }

@router.get("/test/conversations")
async def get_conversations(db: Session = Depends(get_db)):
    """모든 대화 목록 조회"""
    stmt = select(Conversation).order_by(Conversation.created_at.desc())
    result = await db.execute(stmt)
    conversations = result.scalars().all()
    
    return {
        "conversations": [
            {
                "id": str(conv.id),
                "photo_id": conv.photo_id,
                "created_at": conv.created_at.isoformat()
            }
            for conv in conversations
        ]
    }

@router.get("/test/turns/{conversation_id}")
async def get_turns(conversation_id: UUID, db: Session = Depends(get_db)):
    """특정 대화의 모든 턴 조회"""
    stmt = select(Turn).where(Turn.conv_id == conversation_id).order_by(Turn.recorded_at.asc())
    result = await db.execute(stmt)
    turns = result.scalars().all()
    
    return {
        "conversation_id": str(conversation_id),
        "turns": [
            {
                "id": str(turn.id),
                "turn": turn.turn,
                "recorded_at": turn.recorded_at.isoformat()
            }
            for turn in turns
        ]
    }

@router.post("/test/quick-chat")
async def quick_chat_test(
    image_id: str = Form("test-image-001"),
    user_messages: str = Form("안녕하세요, 이 사진 정말 좋네요, 종료")  # 쉼표로 구분된 메시지들
):
    """빠른 대화 테스트 (여러 메시지를 한번에 처리)"""
    messages = [msg.strip() for msg in user_messages.split(",")]
    
    # 대화 시작
    conversation_id, first_question = system.analyze_and_start_conversation("./temp_images/test.jpg")
    
    results = {
        "conversation_id": str(conversation_id),
        "first_question": first_question,
        "turns": []
    }
    
    current_question = first_question
    
    # 각 메시지 처리
    for i, user_answer in enumerate(messages):
        # 종료 키워드 체크
        should_end = system.check_end_keywords(user_answer)
        
        # Turn 저장 (실제 DB 저장은 생략)
        turn_data = {
            "question": current_question,
            "answer": user_answer,
            "should_end": should_end
        }
        
        results["turns"].append(turn_data)
        
        if should_end:
            break
            
        # 다음 질문 생성
        try:
            next_question = system.generate_next_question(current_question, user_answer)
            current_question = next_question
            turn_data["next_question"] = next_question
        except:
            break
    
    return results