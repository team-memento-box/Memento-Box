# 250605_1508 코드 추가해도 DB 잘 유지되는지????!!!
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import photo, user_create, conv_tts, conv_stt, photo_router

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 등록
app.include_router(photo.router)
app.include_router(user_create.router)
app.include_router(conv_tts.router)
app.include_router(conv_stt.router)
app.include_router(photo_router.router)

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI with Nginx and PostgreSQL!"}