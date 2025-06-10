from dataclasses import dataclass, field
from typing import List, Optional
from datetime import datetime
from fastapi import HTTPException
from azure.storage.blob import BlobServiceClient
from uuid import uuid4

from services.image_analyzer import ImageAnalyzer
from services.chat_system import ChatSystem
from services.voice_system import VoiceSystem
from services.story_and_report_system import StoryGenerator
import os
import uuid

from core.config import settings
from db.database import get_db

@dataclass
class SessionData:
    conversation_id: str
    photo_path: Optional[str] = None
    turns: List[dict] = field(default_factory=list)  # {"question": ..., "answer": ..., "timestamp": ...}
    created_at: datetime = field(default_factory=datetime.now)

class OptimizedDementiaSystem:
    """최적화된 치매 진단 시스템"""
    
    def __init__(self):
        self.sessions: dict[str, SessionData] = {}  # 여기 key가 conv_id
        self.speech_key = os.getenv("AZURE_SPEECH_KEY")

        self.image_analyzer = ImageAnalyzer()
        self.chat_system = ChatSystem()
        self.voice_system = VoiceSystem() if self.speech_key else None
        self.story_generator = StoryGenerator(self.chat_system)
    
    def analyze_and_start_conversation(self, image_path):
        """이미지 분석 및 대화 시작"""
        if not os.path.exists(image_path):
            return None
        

        # 이미지 분석
        analysis_result = self.image_analyzer.analyze_image(image_path)
        if not analysis_result:
            return None
        
        # 대화 설정
        self.chat_system.setup_conversation_context(analysis_result)
    
        # 첫 질문 생성
        initial_question = self.chat_system.generate_initial_question()

        # 첫 질문 TTS
        audio_path = self.voice_system.synthesize_speech(initial_question)
        
        return initial_question, audio_path
    
    def generate_complete_analysis(self, image_path):
        """완전한 분석 생성"""
        print("\n📊 종합 분석 결과 생성 중...")
        
        # 1. 대화 기록 저장 (새로운 폴더 구조)
        conversation_file, analysis_file = self.story_generator.save_conversation_to_file(image_path)
        
        # 2. 추억 스토리 생성
        story, story_file = self.story_generator.generate_story_from_conversation(image_path)
        
        # 3. 콘솔에 요약 출력
        summary = self.story_generator.save_conversation_summary()
        print(summary)
        
        # 4. 스토리 출력
        if story:
            print(f"\n{'='*50}")
            print("📖 생성된 추억 이야기")
            print(f"{'='*50}")
            print(story)
            print(f"{'='*50}")
        
        return {
            'conversation_file': conversation_file,
            'analysis_file': analysis_file,
            'story_file': story_file,
            'story_content': story,
            'summary': summary,
            'conversation_id': self.story_generator.conversation_id
        }
    
    def _run_conversation(self, initial_question, is_voice=False):
        """대화 루프 실행 (음성/텍스트 공통)"""
        
        # if is_voice and self.voice_system:
        #     welcome_msg = "안녕하세요. 사진을 보며 대화해요."
        #     print(f"🤖 {welcome_msg}")
        #     self.voice_system.synthesize_speech(welcome_msg)
            
        #     print(f"🤖 {initial_question}")
        #     self.voice_system.synthesize_speech(initial_question)
        # else:
        #     print(f"🤖 {initial_question}")
        
        # conversation_type = "음성" if is_voice else "텍스트"
        # print(f"\n" + "="*40)
        # print(f"{'🎙️' if is_voice else '💬'} {conversation_type} 대화 시작!")
        # print(f"💡 {'종료라고 말하면' if is_voice else 'exit 또는 종료를 입력하면'} 끝납니다")
        # print("="*40)
        
        # 대답
        should_end = False
        if is_voice and self.voice_system:
            print("🎙️ 말씀해 주세요...")
            # 음성 녹음 시작
            self.chat_system.start_recording()
            user_input = self.voice_system.transcribe_speech()
            # 음성 녹음 중지
            audio_path = self.chat_system.stop_recording()
            
            if user_input == "종료":
                end_msg = "대화를 마치겠습니다. 감사합니다."
                print(f"🤖 {end_msg}")
                self.voice_system.synthesize_speech(end_msg)
                should_end = True
        else:
            user_input = input("\n👤 답변: ").strip()
            if user_input.lower() in ['exit', '종료', 'quit', 'q']:
                print("대화를 종료합니다.")
                should_end = True

        return user_input, audio_path, should_end

        # # AI 응답 (음성 모드일 때는 녹음된 오디오 파일 정보 전달)
        # answer, should_end = self.chat_system.chat_about_image2(user_input, with_audio=is_voice)
        # print(f"🤖 {answer}")
        
        # if is_voice and self.voice_system:
        #     self.voice_system.synthesize_speech(answer)
        
        # if should_end:
        #     end_msg = "대화 시간이 종료되었습니다."
        #     print(f"⏰ {end_msg}")
        #     if is_voice and self.voice_system:
        #         self.voice_system.synthesize_speech(end_msg)
        
        # # 종합 분석 생성
        # analysis_results = self.generate_complete_analysis(image_path)
        
        # if analysis_results['conversation_file']:
        #     print(f"📂 대화기록: {analysis_results['conversation_file']}")
        #     print(f"📊 분석결과: {analysis_results['analysis_file']}")
        #     if analysis_results['story_file']:
        #         print(f"📖 스토리: {analysis_results['story_file']}")
        # return analysis_results
    
    def one_chat_about_image(self, user_query, with_audio=False):
        """대화 처리"""
        user_tokens = len(self.tokenizer.encode(user_query))
        
        # 음성 녹음 시작 (if requested)
        audio_file = None
        if with_audio:
            self.start_recording()
        
        # 대화 턴 저장
        if self.last_question:
            # 음성 녹음 중지 및 파일 저장 (if recording)
            if with_audio:
                audio_file = self.stop_recording()
            
            # conversation_turn = ConversationTurn(
            #     question=self.last_question,
            #     answer=user_query,
            #     timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            #     answer_length=len(user_query.strip()),
            #     audio_file=audio_file if audio_file else ""
            # )
            # self.conversation_turns.append(conversation_turn)
            
        
        self.conversation_history.append({"role": "user", "content": user_query})
        self.token_count += user_tokens
        
        # 토큰 제한 확인
        if self.token_count > self.max_tokens:
            answer = "대화 시간이 다 되었어요. 수고하셨습니다."
            self.conversation_history.append({"role": "assistant", "content": answer})
            return answer, True
        
        # AI 응답 생성
        response = self.client.chat.completions.create(
            model=self.deployment,
            messages=self.conversation_history,
            max_tokens=1024,
            temperature=0.7
        )
        answer = response.choices[0].message.content
        
        self.conversation_history.append({"role": "assistant", "content": answer})
        self.token_count += len(self.tokenizer.encode(answer))
        self.last_question = answer
        
        if self.token_count > self.max_tokens:
            return answer, True
        
        return answer, False
    
    def voice_conversation(self, image_path):
        """음성 대화 실행"""
        if not self.voice_system:
            return None
        return self._run_conversation_loop(image_path, is_voice=True)
    
    def text_conversation(self, image_path):
        """텍스트 대화 실행"""
        return self._run_conversation_loop(image_path, is_voice=False)


async def upload_audio_to_blob(audio_path: str) -> str:
    """
    Uploads a wav audio file to Azure Blob Storage and returns the URL.
    """
    storage_key = os.getenv("AZURE_BLOBSTORAGE_KEY")
    storage_account = os.getenv("AZURE_BLOBSTORAGE_ACCOUNT")
    container_name = "talking-voice"
    AZURE_STORAGE_CONNECTION_STRING=f"DefaultEndpointsProtocol=https;AccountName={storage_account};AccountKey={storage_key};EndpointSuffix=core.windows.net"

    try:
        # Replace this with your actual Azure Blob Storage connection string
        connect_str = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
        blob_service_client = BlobServiceClient.from_connection_string(connect_str)

        original_filename = os.path.basename(audio_path)

        # Container name
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=f"{uuid4()}_{original_filename}")

        # Upload the file
        with open(audio_path, "rb") as data:
            blob_client.upload_blob(data, overwrite=True)

        return blob_client.url

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Azure Blob upload failed: {str(e)}")


# async def upload_audio_to_blob(file_path: str, original_filename: str, blob_service_client) -> str:
#     """
#     Azure Blob Storage에 wav 오디오 파일을 업로드하고 주소를 반환합니다.
#     """
#     blob_name = f"{uuid.uuid4()}_{original_filename}"
#     try:
#         # BlobStorageService 인스턴스일 경우
#         if hasattr(blob_service_client, 'container_client'):
#             blob_client = blob_service_client.container_client.get_blob_client(blob_name)
#             with open(file_path, "rb") as data:
#                 blob_client.upload_blob(data, overwrite=True)
#                 return blob_client.url
#         else:
#             # (기존 비동기 BlobServiceClient 사용 케이스가 있다면 여기에 추가)
#             raise Exception('지원하지 않는 blob_service_client 타입입니다.')
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Blob Storage 업로드 실패: {str(e)}")

# async def save_audio_to_db(photo_data: PhotoCreate, db: AsyncSession) -> Photo:
#     """
#     사진 메타데이터를 데이터베이스에 저장합니다.
#     """
#     try:
#         photo = Photo(
#             name=photo_data.name,
#             url=photo_data.url,
#             year=photo_data.year,
#             season=photo_data.season,
#             description=photo_data.description,
#             summary_text=photo_data.summary_text,
#             summary_voice=photo_data.summary_voice,
#             family_id=photo_data.family_id,
#             uploaded_at=datetime.now(timezone(timedelta(hours=9))).replace(tzinfo=None)
#         )
        
#         db.add(photo)
#         await db.commit()
#         await db.refresh(photo)
#         return photo
#     except Exception as e:
#         await db.rollback()
#         raise HTTPException(status_code=500, detail=f"데이터베이스 저장 실패: {str(e)}")