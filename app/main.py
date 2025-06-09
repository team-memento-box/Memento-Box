from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# from routers import photo, user_create, conv_tts, conv_stt, photo_router
from datetime import timezone, timedelta
import pytz
# from routers import photo, user, family, conversation, turn, anomaly_report
from routers import chat

app = FastAPI(
    title="Memento Box API",
    description="가족 추억을 저장하고 공유하는 서비스",
    version="1.0.0"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 타임존 설정
KST = timezone(timedelta(hours=9))
app.state.timezone = KST

# 라우터 등록
# app.include_router(photo.router)
# app.include_router(user_create.router)
# app.include_router(conv_tts.router)
# app.include_router(conv_stt.router)
# app.include_router(photo_router.router)
app.include_router(chat.router, prefix="/api/chat", tags=["llm"])


# app.include_router(photo.router, prefix="/api/v1", tags=["photos"])
# app.include_router(user.router, prefix="/api/v1", tags=["users"])
# app.include_router(family.router, prefix="/api/v1", tags=["families"])
# app.include_router(conversation.router, prefix="/api/v1", tags=["conversations"])
# app.include_router(turn.router, prefix="/api/v1", tags=["turns"])
# app.include_router(anomaly_report.router, prefix="/api/v1", tags=["anomaly_reports"])

@app.get("/")
def read_root():
    return {"message": "Welcome to Memento Box API!"}