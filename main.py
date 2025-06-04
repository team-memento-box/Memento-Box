from fastapi import FastAPI, Header, HTTPException, Path, File, UploadFile, Form
from pydantic import BaseModel, Field
from typing import List, Optional, Dict
from uuid import UUID
from datetime import date, datetime, timedelta
import os
import shutil
from fastapi.responses import JSONResponse
from model import *

app = FastAPI()

# ====== 예시용 데이터 (실제 DB 연동 필요) ======
photos_db = {
    UUID("a1b2c3d4-e5f6-7890-1234-56789abcdef0"): {
        "photoId": "a1b2c3d4-e5f6-7890-1234-56789abcdef0",
        "photoName": "할머니와 바닷가",
        "storyYear": "1975",
        "storySeason": "여름",
        "storyNudge": {
            "mood": "기쁨",
            "keywords": ["바다", "추억"]
        },
        "uploadedAt": "2025-06-01T14:23:45Z"
    }
}

# ✅ 더미 데이터
dummy_photos = [
    {
        "id": 1,
        "family_id": 1,
        "image_url": "https://example.com/photo1.jpg",
        "recorded_at": "2025-05-16T10:00:00",
        "uploaded_at": "2025-05-16"
    },
    {
        "id": 2,
        "family_id": 1,
        "image_url": "https://example.com/photo2.jpg",
        "recorded_at": "2025-05-16T11:00:00",
        "uploaded_at": "2025-05-16"
    },
    {
        "id": 3,
        "family_id": 1,
        "image_url": "https://example.com/photo3.jpg",
        "recorded_at": "2025-05-17T11:00:00",
        "uploaded_at": "2025-05-17"
    }
]



# ====== JWT 검증 함수 (간단 예시) ======
def verify_jwt(token: str) -> bool:
    if token == "valid_token_example":
        return True
    return False

# ====== 라우터 ======
@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI on VM!"}

#----------------

@app.post("/predict")
def predict(item: Item):
    return {"received": item.name, "doubled": item.value * 2}

#----------------

@app.get("/api/v1/photos/{photoId}", response_model=PhotoResponse)
def get_photo(
    photoId: UUID = Path(..., description="Photo UUID"),
    authorization: Optional[str] = Header(None)
):
    if authorization is None or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Unauthorized: Missing or invalid token")
    token = authorization.split(" ")[1]
    if not verify_jwt(token):
        raise HTTPException(status_code=401, detail="Unauthorized: Invalid token")

    photo = photos_db.get(photoId)
    if not photo:
        raise HTTPException(status_code=404, detail="Photo not found")

    return photo

#----------------

# ✅ API 구현 (DB 대신 더미 리스트에서 필터링)
@app.get("/api/v1/photos/{uploaded_at}", response_model=List[PhotoSchema])
def get_photos_by_uploaded_at(uploaded_at: date = Path(..., description="예: 2025-05-16")):
    filtered_photos = [
        photo for photo in dummy_photos
        if photo["uploaded_at"] == uploaded_at.isoformat()
    ]
    # recorded_at 기준 정렬
    filtered_photos.sort(key=lambda x: x["recorded_at"])
    return filtered_photos

#----------------

@app.get("/api/recent_photos")
def get_recent_photos():
    today = datetime.today()
    one_week_ago = today - timedelta(days=7)

    # TODO: 여기를 나중에 DB에서 불러오는 코드로 변경할 것
    # ex) photos = db.query(Photo).filter(Photo.date >= one_week_ago).order_by(Photo.date.desc()).all()
    dummy_data = [
        {
            "name": "김땡땡",
            "role": "딸",
            "content": "새로운 사진 추가",
            "image_url": "https://your-server.com/photos/2.png",
            "date": "2025-06-03"
        },
        {
            "name": "서봉봉",
            "role": "엄마",
            "content": "새로운 대화 생성",
            "image_url": "https://your-server.com/photos/3.png",
            "date": "2025-05-30"
        },
    ]

    # 필터링 (최근 7일)
    recent_photos = [
        item for item in dummy_data
        if datetime.strptime(item["date"], "%Y-%m-%d") >= one_week_ago
    ]

    # 날짜 기준 내림차순 정렬
    recent_photos.sort(key=lambda x: x["date"], reverse=True)
    return recent_photos

#----------------
# 첫 질문 생성
from services.openai_service import create_initial_question

@app.post("/api/v1/questions/initial", response_model=QuestionResponse)
def generate_initial_question(photo: PhotoInfo):
    try:
        # dict로 변환해 서비스 함수에 전달
        question = create_initial_question(photo.dict())

        return {
            "status": "200",
            "question": question
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

#----------------
# 대화 관리 (대화 저장)
from services.db_service import save_conversation_to_db  # 실제 DB 저장 로직

@app.post("/api/v1/conversations/save", response_model=ConversationSaveResponse)
def save_conversation(data: ConversationSaveRequest):
    try:
        # DB 저장 함수 호출 (mentionId 반환)
        mention_id = save_conversation_to_db(photo_id=data.photoId, turns=data.turns)

        return {
            "status": "200",
            "mentionId": mention_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

#----------------
# 사용자 응답 음성 파일 저장
# 오디오 파일 저장 경로
AUDIO_SAVE_DIR = "audio_responses"
os.makedirs(AUDIO_SAVE_DIR, exist_ok=True)

@app.post("/api/v1/answers/audio")
async def upload_audio_answer(
    file: UploadFile = File(...),
    photoId: UUID = Form(...)
):
    try:
        # 파일 확장자 체크
        if not file.filename.endswith(".wav"):
            raise HTTPException(status_code=400, detail="Only .wav files are supported.")
        
        # 저장 경로 생성
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{timestamp}.wav"
        file_path = os.path.join(AUDIO_SAVE_DIR, filename)
        
        # 파일 저장
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        return JSONResponse(content={
            "status": "ok",
            "audioPath": f"{AUDIO_SAVE_DIR}/{filename}"
        })
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))