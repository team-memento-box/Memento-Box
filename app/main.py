from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import timezone, timedelta
import pytz
from routers import auth, user, family, photo, conversation, turn #, anomaly_report

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
app.include_router(auth.router)
app.include_router(user.router)
app.include_router(family.router)
app.include_router(photo.router)
app.include_router(conversation.router)
app.include_router(turn.router)
# app.include_router(anomaly_report.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to Memento Box API!"}