# services/db_service.py
import uuid
from typing import List
from model import Turn  # 위에서 정의한 Turn 모델

def save_conversation_to_db(photo_id: uuid.UUID, turns: List[Turn]) -> uuid.UUID:
    # 실제 DB 저장 로직
    # 예: photo_id에 해당하는 Conversation 테이블에 저장
    # 각 turn을 Loop 돌면서 QuestionAnswer 테이블에 저장 등...

    # 저장된 mention ID 생성해서 반환 (실제로는 DB에서 받아옴)
    mention_id = uuid.uuid4()

    # 예시용 print
    print(f"저장된 photo_id: {photo_id}")
    for t in turns:
        print(f"Q: {t.question}, A: {t.answer}, at {t.timestamp}, type: {t.question_type}")

    return mention_id
