from pydantic import BaseSettings

class Settings(BaseSettings):
    ASYNC_DATABASE_URL: str  # .env 파일의 환경변수 이름과 일치

    class Config:
        env_file = ".env"  # 루트 디렉토리에 있는 .env 파일을 읽도록 지정

# 인스턴스를 만들어서 다른 곳에서 불러다 씀
settings = Settings()