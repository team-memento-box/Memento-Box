# from fastapi import APIRouter, HTTPException
# from pydantic import BaseModel
# from typing import List, Literal
# import uuid

# from schemas.story import Message, StoryRequest, StoryResponse
# from services.story_and_report_system import StoryGenerator

# story_generator = StoryGenerator()


# # GPT 호출 함수 (여기선 더미 응답 사용)
# def generate_story(messages: List[Message], **params) -> str:
#     # 2. 추억 스토리 생성
#     story, story_file = story_generator.generate_story_from_conversation(image_path)

#     return (
#         "그날은 햇살이 따뜻했고, 바닷바람이 부드럽게 얼굴을 감싸던 하루였습니다. "
#         "저는 남편과 함께 해변을 걸으며, 오래된 기억 속의 소중한 순간을 떠올렸어요..."
#     )


# def generate_complete_analysis(image_path):
#         """완전한 분석 생성"""
#         print("\n📊 종합 분석 결과 생성 중...")
        
#         # 1. 대화 기록 저장 (새로운 폴더 구조)
#         conversation_file, analysis_file = story_generator.save_conversation_to_file(image_path)
        
#         # 2. 추억 스토리 생성
#         story, story_file = story_generator.generate_story_from_conversation(image_path)
        
#         # 3. 콘솔에 요약 출력
#         summary = story_generator.save_conversation_summary()
#         # print(summary)
        
#         # 4. 스토리 출력
#         if story:
#             print(f"\n{'='*50}")
#             print("📖 생성된 추억 이야기")
#             print(f"{'='*50}")
#             print(story)
#             print(f"{'='*50}")
        
#         return {
#             'conversation_file': conversation_file,
#             'analysis_file': analysis_file,
#             'story_file': story_file,
#             'story_content': story,
#             'summary': summary,
#             'conversation_id': story_generator.conversation_id
#         }