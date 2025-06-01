# Dialog-Service README

이 문서는 FastAPI 기반 음성(STT → GPT → TTS) 챗봇 백엔드를 실행하기 위한 가이드라인임  
프로젝트는 다음 주요 구성요소로 이루어져 있음:

- **`main.py`**: 텍스트 및 음성 전용 엔드포인트(` /chat`, `/chat_audio`) 구현  
- **`openai_client.py`**: Azure Speech SDK 및 Azure OpenAI 호출(STT, GPT, TTS) 로직  
- **`preprocess.py`**: FFmpeg를 활용해 업로드된 WAV 파일을 16kHz·모노·PCM 형식으로 전처리  
- **`database.py`**: SQLAlchemy를 사용한 PostgreSQL 연결 설정 및 모델 정의 (`Message`, `Report`)  
- **`requirements.txt`**: Python 의존성 목록  
- **`Dockerfile`**: 컨테이너 빌드를 위한 설정 (Python 3.10-slim + FFmpeg 설치)


---

## 사전 준비

- ~~**Python 3.10 이상**~~(어차피 docker써서 상관없음)
- **PostgreSQL** (예: 로컬 또는 원격)  
- **FFmpeg** (로컬 실행 시 시스템에 설치 필요, Docker를 이용하면 Dockerfile에서 자동 설치됨)  
- **Azure 리소스**  
  - Azure Speech 서비스 (STT/TTS용 키 & 리전)  
  - Azure OpenAI 서비스 (GPT 호출용 엔드포인트 & 키)

---

## 프로젝트 클론

```bash
git clone --single-branch --branch dockertest https://github.com/team-memento-box/Memento-Box.git
```
---
## 환경 변수 구성

```bash
# PostgreSQL 연결 URL
DATABASE_URL=postgresql://<DB_USER>:<DB_PASSWORD>@<DB_HOST>:<DB_PORT>/<DB_NAME>

# Azure OpenAI
AZURE_OPENAI_KEY=<YOUR_AZURE_OPENAI_KEY>
AZURE_OPENAI_ENDPOINT=<YOUR_AZURE_OPENAI_ENDPOINT_URL>   # 예: https://<리소스이름>.openai.azure.com/openai/deployments/<DEPLOYMENT_NAME>/chat/completions?api-version=2023-05-15

# Azure Speech (STT/TTS)
AZURE_SPEECH_KEY=<YOUR_AZURE_SPEECH_KEY>
AZURE_SPEECH_REGION=<YOUR_AZURE_SPEECH_REGION>          # 예: koreacentral
```

## 실행
### 컨테이너 실행
```bash
cd docker-project
docker-compose up --build
```
### 결과 확인(SwaggerUI)
swaggerui로 확인 가능
- `http://localhost:6060/docs` : gpt 대화 및 db저장
- `http://localhost:8000/docs` : webserver(리포트 저장된 db 기반 음성 스토리텔링 추론)
이후에 8000번 port에 합칠 예정


# 주의사항
- gpu 리소스 없을 경우 fish-speech 모델 추론 속도가 매우 느릴 수 있음
- gpt와 대화 tts 결과는 따로 저장안됨(swaggerui에서 걍 다운받으셈)
- 스토리텔링.wav 파일은 `shared/output_wav`에 저장(파일명은 uuid)
