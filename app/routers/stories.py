# from fastapi import APIRouter, HTTPException

# from app.schemas.story import ChatRequest
# from schemas.story import Message, StoryRequest, StoryResponse
# from services.story_generator import generate_story

# router = APIRouter()

# # API 엔드포인트
# @router.post("/api/stories", response_model=StoryResponse)
# async def create_story(request: StoryRequest):
#     try:
#         story = generate_story(
#             messages=request.messages,
#             temperature=request.temperature,
#             max_tokens=request.max_tokens,
#             top_p=request.top_p,
#             frequency_penalty=request.frequency_penalty,
#             presence_penalty=request.presence_penalty
#         )

#         return StoryResponse(
#             status="ok",
#             mentionId=request.mentionId,
#             storyText=story
#         )

#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))
    


# @router.post("/chat")
# async def chat_endpoint(chat: ChatRequest):
#     """
#     기존 텍스트 채팅 전용 엔드포인트. JSON body로 messages 리스트를 받고,
#     DB에 저장 → GPT 호출 → 응답(텍스트) 리턴
#     """
#     user_id = chat.user_id
#     messages = chat.messages

#     db = SessionLocal()

#     # 1) 요청으로 들어온 새 메시지들만 DB에 저장
#     for m in messages:
#         db_message = DBMessage(
#             user_id=user_id,
#             role=m.role,
#             content=m.content,
#             timestamp=datetime.utcnow()
#         )
#         db.add(db_message)
#     try:
#         db.commit()
#     except Exception as e:
#         return {"type": "error", "message": f"DB 저장 중 오류: {e}"}

#     # 2) 종료 처리 (마지막 메시지가 “종료”, “그만”, “끝” 중 하나일 때)
#     last_content = messages[-1].content.strip().lower()
#     if last_content in ["종료", "그만", "끝"]:
#         # 2-1) DB에 저장된 user_id의 전체 대화 기록을 시간순으로 불러오기
#         db = SessionLocal()
#         history = (
#             db.query(DBMessage)
#               .filter(DBMessage.user_id == user_id)
#               .order_by(DBMessage.timestamp)
#               .all()
#         )
#         # 2-2) OpenAI에 보낼 메시지 리스트 구성
#         full_chat = []
#         # 시스템 프롬프트
#         full_chat.append({
#             "role": "system",
#             "content": "지금까지 사용자와 나눈 대화를 토대로, 사용자의 관점에서 할머니가 옛날이야기를 하는 느낌의 스크립트를 만들어 주세요."
#         })
#         # DB에서 가져온 모든 메시지를 차례대로 추가
#         for record in history:
#             full_chat.append({
#                 "role": record.role,
#                 "content": record.content
#             })

#         # 2-3) OpenAI 호출 (텍스트 응답: 리포트 생성)
#         try:
#             report = await ask_openai(messages=full_chat)
#         except Exception as ai_err:
#             return {"type": "error", "message": f"OpenAI 호출 오류(리포트 생성): {ai_err}"}

#         # 2-4) 생성된 리포트를 DB에 저장
#         try:
#             db_report = Report(
#                 user_id=user_id,
#                 content=report,
#                 timestamp=datetime.utcnow()
#             )
#             db.add(db_report)
#             db.commit()
#         except Exception as db_report_err:
#             return {"type": "error", "message": f"리포트 DB 저장 중 오류: {db_report_err}"}

#         return {
#             "type": "report",
#             "response": report
#         }

#     # 3) 일반 채팅 로직 (종료 키워드가 아니면)
#     formatted_messages = [{"role": m.role, "content": m.content} for m in messages]
#     try:
#         response_text = await ask_openai(messages=formatted_messages)
#     except Exception as ai_err:
#         return {"type": "error", "message": f"OpenAI 호출 오류(채팅): {ai_err}"}

#     return {
#         "type": "chat",
#         "response": response_text
#     }