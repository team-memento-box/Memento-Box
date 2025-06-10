import os
import sys
# PYTHONPATH를 /app으로 설정, 다른 디렉토리를 참조하기 전에 다음 라인 명시 필요
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy import create_engine
from db.models.conversation import Conversation
from db.models.turn import Turn
from core.config import settings
from uuid import uuid4
from datetime import datetime, timezone, timedelta

def add_fake_conversation():
    # 동기 DB 엔진 및 세션 생성
    engine = create_engine(settings.SYNC_DATABASE_URL, echo=True)
    SessionLocal = sessionmaker(bind=engine)
    db: Session = SessionLocal()
    try:
        # 가상 photo_id
        photo_id = "4958d511-e135-4754-94c4-b569a528b2a0"
        # 가상 conversation_id
        conversation_id = uuid4()
        # Conversation 생성
        conversation = Conversation(
            id=conversation_id,
            photo_id=photo_id,
            created_at=datetime.now(timezone(timedelta(hours=9))).replace(tzinfo=None)
        )
        db.add(conversation)
        db.commit()

        # Turn 예시 데이터 2개 추가
        turn1 = Turn(
            id=uuid4(),
            conv_id=conversation_id,
            turn={
                "q_text": "이 사진은 언제 찍은 거야?",
                "a_text": "2025년 봄에 찍었어!",
                "q_voice": None,
                "a_voice": None
            },
            recorded_at=datetime.now(timezone(timedelta(hours=9))).replace(tzinfo=None)
        )
        turn2 = Turn(
            id=uuid4(),
            conv_id=conversation_id,
            turn={
                "q_text": "누가 찍었어?",
                "a_text": "아빠가 찍어줬지!",
                "q_voice": None,
                "a_voice": None
            },
            recorded_at=datetime.now(timezone(timedelta(hours=9))).replace(tzinfo=None)
        )
        db.add_all([turn1, turn2])
        db.commit()
        print(f"가상 Conversation 및 Turn 데이터가 추가되었습니다. conversation_id: {conversation_id}")
    finally:
        db.close()

if __name__ == "__main__":
    add_fake_conversation()