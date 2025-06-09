# from pydantic import BaseModel
# from typing import List, Literal
# import uuid

# # 메시지 포맷
# class Message(BaseModel):
#     role: Literal["system", "user", "assistant"]
#     content: str

# # 요청 바디 스키마
# class StoryRequest(BaseModel):
#     mentionId: uuid.UUID
#     messages: List[Message]
#     temperature: float = 0.5
#     max_tokens: int = 300
#     top_p: float = 1.0
#     frequency_penalty: float = 0
#     presence_penalty: float = 0

# # 응답 스키마
# class StoryResponse(BaseModel):
#     status: str
#     mentionId: uuid.UUID
#     storyText: str