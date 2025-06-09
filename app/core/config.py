from pydantic_settings import BaseSettings
import secrets

class Settings(BaseSettings):
    # PostgreSQL 설정
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str
    
    # 데이터베이스 URL
    ASYNC_DATABASE_URL: str
    SYNC_DATABASE_URL: str
    
    # JWT 설정
    SECRET_KEY: str
    
    # Azure Blob Storage 설정
    AZURE_BLOBSTORAGE_ACCOUNT: str
    AZURE_BLOBSTORAGE_KEY: str

    # Azure Speech 서비스 설정
    AZURE_SPEECH_ENDPOINT: str
    AZURE_SPEECH_KEY: str
    AZURE_SPEECH_REGION: str

    # JWT 인증 설정
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    class Config:
        env_file = ".env"  # 루트 디렉토리에 있는 .env 파일을 읽도록 지정
        extra = 'allow'  # 추가 필드 허용

# 인스턴스를 만들어서 다른 곳에서 불러다 씀
settings = Settings()