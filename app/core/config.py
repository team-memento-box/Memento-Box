from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    # API 설정
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Memento Box API System"
    
    # 데이터베이스 설정
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str
    DATABASE_URL: str = "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DB}"
    ASYNC_DATABASE_URL: str = "postgresql+asyncpg://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DB}"
    SYNC_DATABASE_URL: str = "postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DB}"
    
    # 외부 서비스 URL
    FISH_SPEECH_URL: str = "http://fish-speech:5000"
    DIALOGUE_URL: str = "http://dialogue:5001"
    
    # Azure OpenAI 설정
    AZURE_OPENAI_API_KEY: str
    AZURE_OPENAI_ENDPOINT: str
    AZURE_OPENAI_API_VERSION: str = "2025-01-01-preview"
    AZURE_OPENAI_DEPLOYMENT_NAME: str = "gpt-4o"
    
    # Azure Speech 설정
    AZURE_SPEECH_KEY: str
    AZURE_SPEECH_REGION: str
    
    # Azure Blob Storage 설정
    AZURE_BLOBSTORAGE_KEY: Optional[str] = None
    
    # 파일 업로드 설정
    UPLOAD_DIR: str = "uploads"
    AUDIO_DIR: str = "audio_files"
    STATIC_DIR: str = "static"
    MAX_UPLOAD_SIZE: int = 100 * 1024 * 1024  # 100MB
    
    model_config = SettingsConfigDict(
        case_sensitive=True,
        env_file=".env",
        extra="allow"
    )

# 인스턴스를 만들어서 다른 곳에서 불러다 씀
settings = Settings()