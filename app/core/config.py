from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional
from functools import lru_cache

class Settings(BaseSettings):
    # API 설정
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Memento Box API System"
    
    # 데이터베이스 설정
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str
    DATABASE_URL: str = ""  # Empty string as default
    ASYNC_DATABASE_URL: str = ""  # Empty string as default
    SYNC_DATABASE_URL: str = ""  # Empty string as default
    
    # Azure OpenAI 설정
    AZURE_OPENAI_API_KEY: str
    AZURE_OPENAI_ENDPOINT: str
    AZURE_OPENAI_API_VERSION: str = "2024-02-15-preview"
    AZURE_OPENAI_DEPLOYMENT_NAME: str = "gpt-4o"
    
    # Azure Speech 설정
    AZURE_SPEECH_KEY: str
    AZURE_SPEECH_REGION: str
    
    # Azure Blob Storage 설정
    AZURE_STORAGE_CONNECTION_STRING: Optional[str] = None
    AZURE_STORAGE_CONTAINER_NAME: Optional[str] = None
    
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

    def model_post_init(self, __context) -> None:
        """Initialize computed fields after model initialization"""
        self.DATABASE_URL = f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@db/{self.POSTGRES_DB}"
        self.ASYNC_DATABASE_URL = f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@db/{self.POSTGRES_DB}"
        self.SYNC_DATABASE_URL = f"postgresql+psycopg2://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@db/{self.POSTGRES_DB}"

@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    return Settings()

# 인스턴스를 만들어서 다른 곳에서 불러다 씀
settings = get_settings()