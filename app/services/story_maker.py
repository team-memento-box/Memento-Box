from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Literal
import uuid

# GPT 호출 함수 (여기선 더미 응답 사용)
def generate_story(messages: List[Message], **params) -> str:
    # 실제 OpenAI API 연동 로직이 들어갈 자리입니다.
    return (
        "그날은 햇살이 따뜻했고, 바닷바람이 부드럽게 얼굴을 감싸던 하루였습니다. "
        "저는 남편과 함께 해변을 걸으며, 오래된 기억 속의 소중한 순간을 떠올렸어요..."
    )