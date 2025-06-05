import os
from config import Config
from image_analyzer import ImageAnalyzer
from chat_system import ChatSystem
from voice_system import VoiceSystem
from story_generator import StoryGenerator

class OptimizedDementiaSystem:
    """최적화된 치매 진단 시스템"""
    
    def __init__(self):
        self.image_analyzer = ImageAnalyzer()
        self.chat_system = ChatSystem()
        self.voice_system = VoiceSystem() if Config.SPEECH_KEY else None
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
        
        return initial_question
    
    def process_user_message(self, message):
        """사용자 메시지 처리"""
        return self.chat_system.chat_about_image(message)
    
    def generate_complete_analysis(self, image_path):
        """완전한 분석 생성"""
        # 1. 대화 기록 저장
        conversation_file, analysis_file = self.story_generator.save_conversation_to_file(image_path)
        
        # 2. 추억 스토리 생성
        story, story_file = self.story_generator.generate_story_from_conversation(image_path)
        
        # 3. 요약 생성
        summary = self.story_generator.save_conversation_summary()
        
        return {
            'conversation_file': conversation_file,
            'analysis_file': analysis_file,
            'story_file': story_file,
            'story_content': story,
            'summary': summary,
            'conversation_id': self.story_generator.conversation_id
        }
    
    def reset_conversation(self):
        """대화 상태 초기화"""
        self.chat_system.reset_conversation()
        self.story_generator = StoryGenerator(self.chat_system)
    
    def get_conversation_status(self):
        """현재 대화 상태 반환"""
        return {
            'turn_count': len(self.chat_system.conversation_turns),
            'token_count': self.chat_system.token_count,
            'max_tokens': self.chat_system.MAX_TOKENS,
            'conversation_id': self.story_generator.conversation_id
        }