import os
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()

class Config:
    """시스템 설정"""
    # Azure OpenAI 설정
    ENDPOINT = os.getenv("gpt-endpoint")
    DEPLOYMENT = "gpt-4o"
    SUBSCRIPTION_KEY = os.getenv("gpt-key")
    API_VERSION = "2024-02-15-preview"
    
    # Azure Speech 설정
    SPEECH_KEY = os.getenv("speech-key")
    SPEECH_REGION = "eastus"
    
    # 데이터베이스 설정
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./dementia_system.db")
    
    # 파일 저장 경로
    UPLOAD_DIR = "uploads"
    AUDIO_DIR = "audio_files"
    
    # GPT 설정
    MAX_TOKENS = 300
    TEMPERATURE = 0.5
    TOP_P = 1.0
    FREQUENCY_PENALTY = 0
    PRESENCE_PENALTY = 0