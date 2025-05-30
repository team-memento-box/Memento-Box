from fastapi import FastAPI
from openai_client import ask_openai
from database import SessionLocal, Message as DBMessage, Report, init_db
from datetime import datetime
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI()
init_db()

# Pydantic 모델 정의
class Message(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    user_id: Optional[str] = "anonymous"
    messages: List[Message]

@app.post("/chat")
async def chat_endpoint(chat: ChatRequest):
    user_id = chat.user_id
    messages = chat.messages

    db = SessionLocal()

    # 1. 메시지 저장
    for m in messages:
        db_message = DBMessage(
            user_id=user_id,
            role=m.role,
            content=m.content,
            timestamp=datetime.utcnow()
        )
        db.add(db_message)
    db.commit()

    # 2. 종료 처리
    if messages[-1].content.strip().lower() in ["종료", "그만", "끝"]:
        full_chat = [{"role": m.role, "content": m.content} for m in messages]
        full_chat.insert(0, {
            "role": "system",
            "content": "지금까지 사용자와 너가 나눈 대화를 토대로 사용자의 입장에서 할머니가 옛날이야기를 하는 느낌으로 스크립트 만들어줘"
        })

        report = await ask_openai(full_chat)

        db_report = Report(
            user_id=user_id,
            content=report,
            timestamp=datetime.utcnow()
        )
        db.add(db_report)
        db.commit()

        return {
            "type": "report",
            "response": report
        }

    # 3. 일반 응답
    formatted_messages = [{"role": m.role, "content": m.content} for m in messages]
    response = await ask_openai(formatted_messages)

    return {
        "type": "chat",
        "response": response
    }
