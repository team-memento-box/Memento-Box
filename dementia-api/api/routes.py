import os
import uuid
from datetime import datetime
from typing import List
from fastapi import APIRouter, HTTPException, File, UploadFile, Form, Depends
from fastapi.responses import JSONResponse, FileResponse
from sqlalchemy.orm import Session

from database import get_db
from models import *
from image_analyzer import ImageAnalyzer
from chat_system import QuestionGenerator
from voice_system import VoiceSystem
from story_generator import StoryGenerator, AnomalyAnalyzer
from config import Config

# 라우터 생성
router = APIRouter(prefix="/api/v1", tags=["dementia"])

# 시스템 컴포넌트 초기화
image_analyzer = ImageAnalyzer()
question_generator = QuestionGenerator()
voice_system = VoiceSystem()
story_generator = StoryGenerator()
anomaly_analyzer = AnomalyAnalyzer()

# 1. 사진 등록 API
@router.get("/photos")
async def get_photos(db: Session = Depends(get_db)):
    """가족의 업로드된 전체 사진 목록을 위한 메타데이터 불러오기"""
    try:
        photos = db.query(Photo).all()
        
        photo_list = []
        for photo in photos:
            photo_list.append({
                "photoId": photo.id,
                "photoName": photo.photo_name,
                "storyYear": photo.story_year.isoformat() if photo.story_year else None,
                "storySession": photo.story_season,
                "storyNudge": photo.story_nudge,
                "mood": photo.story_nudge.get("mood", "") if photo.story_nudge else "",
                "keywords": photo.story_nudge.get("keywords", []) if photo.story_nudge else [],
                "uploadedAt": photo.uploaded_at.isoformat()
            })
        
        return PhotoListResponse(status="ok", data=photo_list)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 2. 사진 및 설문 업로드
@router.post("/photos/upload")
async def upload_photo(
    file: UploadFile = File(...),
    photo_name: str = Form(...),
    story_year: str = Form(...),
    story_season: str = Form(...),
    story_nudge: str = Form(...),  # JSON string
    family_id: str = Form(...),
    db: Session = Depends(get_db)
):
    """보호자가 업로드한 전체 사진을 대화 기반으로 질의응답을 위한 PostgreSQL 저장 데이터 등록"""
    try:
        # 파일 저장
        upload_dir = Config.UPLOAD_DIR
        os.makedirs(upload_dir, exist_ok=True)
        
        photo_id = str(uuid.uuid4())
        file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
        file_path = os.path.join(upload_dir, f"{photo_id}.{file_extension}")
        
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        # story_nudge JSON 파싱
        import json
        story_nudge_dict = json.loads(story_nudge)
        
        # 데이터베이스에 저장
        photo_obj = Photo(
            id=photo_id,
            photo_name=photo_name,
            photo_url=file_path,
            story_year=datetime.fromisoformat(story_year),
            story_season=story_season,
            story_nudge=story_nudge_dict,
            family_id=family_id
        )
        
        db.add(photo_obj)
        db.commit()
        
        return JSONResponse(content={
            "status": "ok",
            "data": {
                "photoId": photo_id,
                "uploadedAt": photo_obj.uploaded_at.isoformat()
            }
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 3. 사진 및 설문 불러오기
@router.get("/photos/{photoId}")
async def get_photo(photoId: str, db: Session = Depends(get_db)):
    """사진 및 설문 메타데이터를 불러와서 GPT와 데이터 간의 Headers를 통해 접근 확인"""
    try:
        photo = db.query(Photo).filter(Photo.id == photoId).first()
        if not photo:
            raise HTTPException(status_code=404, detail="Photo not found")
        
        return JSONResponse(content={
            "photoId": photo.id,
            "photoName": photo.photo_name,
            "storyYear": photo.story_year.isoformat() if photo.story_year else None,
            "storySession": photo.story_season,
            "storyNudge": photo.story_nudge,
            "mood": photo.story_nudge.get("mood", "") if photo.story_nudge else "",
            "keywords": photo.story_nudge.get("keywords", []) if photo.story_nudge else []
        })
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 4. 첫 질문 생성
@router.post("/questions/initial")
async def generate_initial_question(request: InitialQuestionRequest, db: Session = Depends(get_db)):
    """업로드된 사진을 기반으로 LLM 첫 질문 생성"""
    try:
        # 사진 정보 가져오기
        photo = db.query(Photo).filter(Photo.id == request.photoId).first()
        if not photo:
            raise HTTPException(status_code=404, detail="Photo not found")
        
        # 이미지 분석
        analysis_result = image_analyzer.analyze_image_for_initial_question(
            photo.photo_url,
            request.storyYear,
            request.storySession,
            request.storyNudge
        )
        
        if not analysis_result:
            raise HTTPException(status_code=500, detail="Image analysis failed")
        
        # 첫 질문 생성
        question = question_generator.generate_initial_question(
            analysis_result,
            request.photoName,
            request.storyYear,
            request.storySession
        )
        
        return QuestionResponse(status="ok", question=question)
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 5. TTS (대화 첫 번째)
@router.post("/tts")
async def text_to_speech(question: str = Form(...)):
    """GPT가 생성한 질문을 Azure TTS 기능을 통해 변환하여 어르신에게 자연스러운 의사소통 가능"""
    try:
        audio_path = voice_system.text_to_speech(question)
        
        if not audio_path:
            raise HTTPException(status_code=500, detail="TTS conversion failed")
        
        return JSONResponse(content={
            "status": "ok",
            "audioUrl": f"https://yourdomain.com/audio/{os.path.basename(audio_path)}"
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 6. STT (음성 사용자)
@router.post("/stt")
async def speech_to_text(file: UploadFile = File(...)):
    """사용자의 음성 파일을 text로 변환"""
    try:
        # 임시 파일 저장
        temp_path = f"/tmp/{file.filename}"
        with open(temp_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        # STT 처리
        transcription = voice_system.transcribe_audio_file(temp_path)
        
        # 임시 파일 삭제
        os.remove(temp_path)
        
        return JSONResponse(content={
            "status": "ok",
            "transcription": transcription
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 7. 추가 질문 생성
@router.post("/questions/followup")
async def generate_followup_question(request: FollowupQuestionRequest):
    """지금까지 대화한 데이터를 더 깊이 있는 GPT 어르신에 대한 숨은 요구를 찾는 다음 질문 1개 생성"""
    try:
        question = question_generator.generate_followup_question(request.chatHistory)
        
        return QuestionResponse(status="ok", question=question)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 8. 대화 관리 (대화 저장)
@router.post("/conversations/save")
async def save_conversation(request: ConversationSaveRequest, db: Session = Depends(get_db)):
    """어르신 사진에 대한 질문-답변 전체 데이터 DB에 정리 저장"""
    try:
        mention_id = str(uuid.uuid4())
        
        # Mention 객체 생성
        mention = Mention(
            id=mention_id,
            photo_id=request.photoId,
            question_answer=request.turns
        )
        
        db.add(mention)
        db.commit()
        
        return ConversationResponse(status="ok", mentionId=mention_id)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 9. 사용자 음성 분석 및 이상 징후
@router.post("/answers/audio")
async def analyze_audio(
    file: UploadFile = File(...),
    photoId: str = Form(...),
    db: Session = Depends(get_db)
):
    """어르신이 학습 음성(WAV 파일 등록) or questionText에 대화로 나온 실제 개선 사항을 녹음기와 음성으로 상세하기"""
    try:
        # 음성 파일 저장
        audio_path = voice_system.save_uploaded_audio(file, photoId)
        if not audio_path:
            raise HTTPException(status_code=500, detail="Audio file save failed")
        
        # STT 처리
        transcription = voice_system.transcribe_audio_file(audio_path)
        
        # 음성 이상 징후 분석
        analysis_result = anomaly_analyzer.analyze_audio_anomalies(audio_path, transcription)
        
        return JSONResponse(content={
            "status": "ok",
            "audioPath": audio_path,
            "transcription": transcription,
            "analysis": analysis_result
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 10. 대화 조회
@router.get("/conversations/{mentionId}")
async def get_conversation(mentionId: str, db: Session = Depends(get_db)):
    """대화 내역 조회"""
    try:
        mention = db.query(Mention).filter(Mention.id == mentionId).first()
        if not mention:
            raise HTTPException(status_code=404, detail="Conversation not found")
        
        return ConversationDetailResponse(
            status="ok",
            mentionId=mentionId,
            turns=mention.question_answer
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 11. 회상 스토리 생성
@router.post("/stories")
async def generate_story(request: StoryGenerationRequest, db: Session = Depends(get_db)):
    """특정 사진의 대화 내역(mentionId)을 기반으로 GPT가 어르신 눈과 거시적으로 회상 스토리 자동 생성"""
    try:
        mention = db.query(Mention).filter(Mention.id == request.mentionId).first()
        if not mention:
            raise HTTPException(status_code=404, detail="Conversation not found")
        
        # 스토리 생성
        story_text = story_generator.generate_story_from_conversation(mention.question_answer)
        
        return StoryResponse(
            status="ok",
            mentionId=request.mentionId,
            storyText=story_text
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 12. 리포트 작성
@router.post("/reports/anomalies")
async def generate_anomaly_report(request: ReportRequest, db: Session = Depends(get_db)):
    """특정 사진의 대화 내역(mentionId)을 기반으로 GPT가 어르신 중 이상 징후가 감지되는 리포트 생성"""
    try:
        mention = db.query(Mention).filter(Mention.id == request.mentionId).first()
        if not mention:
            raise HTTPException(status_code=404, detail="Conversation not found")
        
        # 이상 징후 분석
        analysis_result = anomaly_analyzer.analyze_conversation_anomalies(mention.question_answer)
        
        # 리포트 저장
        report_id = str(uuid.uuid4())
        severity = analysis_result.get("severity", "none")
        
        # event_interval 계산 (첫 번째와 마지막 대화의 시간 간격)
        turns = mention.question_answer
        if len(turns) >= 2:
            start_time = turns[0].get("timestamp", "")
            end_time = turns[-1].get("timestamp", "")
            event_interval = f"{start_time} - {end_time}"
        else:
            event_interval = "단일 대화"
        
        anomaly_report = AnomalyReport(
            id=report_id,
            mention_id=request.mentionId,
            event_interval=event_interval,
            family_id=mention.photo.family_id
        )
        
        db.add(anomaly_report)
        db.commit()
        
        return ReportResponse(
            status="ok",
            mentionId=request.mentionId,
            severity=severity,
            event_interval=event_interval,
            created_at=anomaly_report.id  # 실제로는 created_at 필드 추가 필요
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 13. 음성 데이터 조회
@router.get("/answers/audio-files/{photoId}")
async def get_audio_files(photoId: str):
    """음성 데이터 조회"""
    try:
        # 해당 photoId의 음성 파일들 검색
        audio_dir = Config.AUDIO_DIR
        audio_files = []
        
        for filename in os.listdir(audio_dir):
            if filename.startswith(photoId):
                file_path = os.path.join(audio_dir, filename)
                file_stats = os.stat(file_path)
                audio_files.append({
                    "filename": filename,
                    "filePath": file_path,
                    "fileSize": file_stats.st_size,
                    "duration": 0  # 실제 구현에서는 오디오 길이 계산 필요
                })
        
        return JSONResponse(content={
            "status": "ok",
            "files": audio_files
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 14. 회상 스토리 조회
@router.get("/stories/{mentionId}")
async def get_story(mentionId: str, db: Session = Depends(get_db)):
    """회상 스토리 조회"""
    try:
        mention = db.query(Mention).filter(Mention.id == mentionId).first()
        if not mention:
            raise HTTPException(status_code=404, detail="Story not found")
        
        # 저장된 스토리가 있으면 반환, 없으면 새로 생성
        story_text = story_generator.generate_story_from_conversation(mention.question_answer)
        
        return StoryResponse(
            status="ok",
            mentionId=mentionId,
            storyText=story_text
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 15. 모델 추론 (오디오 파일 저장)
@router.post("/audio-files/save")
async def save_audio_file(file: UploadFile = File(...)):
    """모델 추론을 위한 오디오 파일 저장"""
    try:
        # 파일 저장
        file_id = str(uuid.uuid4())
        file_path = voice_system.save_uploaded_audio(file, file_id)
        
        if not file_path:
            raise HTTPException(status_code=500, detail="Audio file save failed")
        
        return JSONResponse(content={
            "status": "ok",
            "filePath": file_path,
            "fileSize": len(await file.read())
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 16. 모델 추론 (스토리 오디오)
@router.post("/stories/audio")
async def generate_story_audio(mentionId: str = Form(...), db: Session = Depends(get_db)):
    """TTS 메타데이터 저장"""
    try:
        mention = db.query(Mention).filter(Mention.id == mentionId).first()
        if not mention:
            raise HTTPException(status_code=404, detail="Mention not found")
        
        # 스토리 생성
        story_text = story_generator.generate_story_from_conversation(mention.question_answer)
        
        # TTS 변환
        audio_path = voice_system.text_to_speech(story_text)
        
        return JSONResponse(content={
            "status": "ok",
            "message": "스토리 메타데이터가 성공적으로 업데이트되었습니다."
        })
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 17. 이상 탐지 모델 리포트
@router.get("/reports/anomalies/{mentionId}")
async def get_anomaly_report(mentionId: str, db: Session = Depends(get_db)):
    """이상 탐지 모델 리포트 조회"""
    try:
        report = db.query(AnomalyReport).filter(AnomalyReport.mention_id == mentionId).first()
        if not report:
            raise HTTPException(status_code=404, detail="Report not found")
        
        return JSONResponse(content={
            "status": "ok",
            "mentionId": mentionId,
            "severity": "none",  # 실제 구현에서는 분석 결과에서 가져오기
            "event_interval": report.event_interval,
            "created_at": "2025-05-28T15:27:30"  # 실제로는 report.created_at
        })
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))