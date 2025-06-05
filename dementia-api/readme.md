# 🧠 치매 진단 대화 시스템 FastAPI

이미지 기반 치매 진단을 위한 대화형 AI 시스템의 FastAPI 버전입니다.

## 📁 프로젝트 구조

```
dementia-api/
├── main.py                 # FastAPI 메인 앱
├── config.py              # 설정 관리
├── models.py              # 데이터베이스 및 API 모델
├── database.py            # 데이터베이스 연결
├── image_analyzer.py      # 이미지 분석
├── chat_system.py         # 질문 생성 시스템
├── voice_system.py        # 음성 처리 시스템
├── story_generator.py     # 스토리 생성 및 이상 징후 분석
├── api/
│   ├── __init__.py        # API 패키지 초기화
│   └── routes.py          # API 라우터
├── requirements.txt       # 패키지 의존성
├── .env                   # 환경 변수 (생성 필요)
├── uploads/               # 업로드된 이미지
├── audio_files/           # 음성 파일
└── README.md              # 프로젝트 가이드
```

## 🗄️ 데이터베이스 구조

### 테이블 구조

- **users**: 사용자 정보 (kakao_id, username, family_id 등)
- **families**: 가족 그룹 정보
- **photos**: 업로드된 사진과 메타데이터
- **mentions**: 대화 내역 (질문-답변 쌍들)
- **anomalies_reports**: 이상 징후 리포트

### 관계

- User ↔ Family (다대일)
- Photo ↔ Family (다대일)
- Mention ↔ Photo (다대일)
- AnomalyReport ↔ Mention (일대일)

## 🚀 설치 및 실행

### 1. 환경 설정

```bash
# 가상환경 생성
python -m venv venv

# 가상환경 활성화 (Windows)
venv\Scripts\activate

# 가상환경 활성화 (macOS/Linux)
source venv/bin/activate

# 패키지 설치
pip install -r requirements.txt
```

### 2. 환경 변수 설정

`.env` 파일을 생성하고 다음 내용을 설정:

```env
# Azure OpenAI 설정
gpt-endpoint=https://your-endpoint.openai.azure.com/
gpt-key=your-azure-openai-key

# Azure Speech Service 설정
speech-key=your-azure-speech-key

# 데이터베이스 설정 (기본값: SQLite)
DATABASE_URL=sqlite:///./dementia_system.db
# PostgreSQL 사용시:
# DATABASE_URL=postgresql://username:password@localhost/dbname
```

### 3. 서버 실행

```bash
# 개발 서버 실행
python main.py

# 또는 uvicorn 직접 실행
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

서버가 시작되면 다음 URL에서 접근 가능합니다:

- 메인 페이지: http://localhost:8000
- API 문서: http://localhost:8000/docs
- ReDoc 문서: http://localhost:8000/redoc

## 🔄 API 사용 플로우

### 완전한 대화 세션 예시

```bash
# 1. 사진 업로드
curl -X POST "http://localhost:8000/api/v1/photos/upload" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@family_photo.jpg" \
  -F "photo_name=가족 여행 사진" \
  -F "story_year=2020-07-15" \
  -F "story_season=여름" \
  -F "story_nudge={\"mood\":\"즐거운\",\"keywords\":[\"가족\",\"여행\",\"바다\"]}" \
  -F "family_id=family-123"

# 2. 첫 질문 생성
curl -X POST "http://localhost:8000/api/v1/questions/initial" \
  -H "Content-Type: application/json" \
  -d '{
    "photoId": "photo-uuid",
    "photoName": "가족 여행 사진",
    "storyYear": "2020",
    "storySession": "여름",
    "storyNudge": {"mood": "즐거운", "keywords": ["가족", "여행", "바다"]},
    "mood": "즐거운",
    "keywords": ["가족", "여행", "바다"]
  }'

# 3. 질문을 음성으로 변환 (TTS)
curl -X POST "http://localhost:8000/api/v1/tts" \
  -H "Content-Type: multipart/form-data" \
  -F "question=이 바다 여행에서 가장 기억에 남는 순간은 무엇인가요?"

# 4. 사용자 음성 응답을 텍스트로 변환 (STT)
curl -X POST "http://localhost:8000/api/v1/stt" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@user_response.wav"

# 5. 추가 질문 생성
curl -X POST "http://localhost:8000/api/v1/questions/followup" \
  -H "Content-Type: application/json" \
  -d '{
    "photoId": "photo-uuid",
    "chatHistory": [
      {"role": "assistant", "content": "이 바다 여행에서 가장 기억에 남는 순간은 무엇인가요?"},
      {"role": "user", "content": "아이들과 함께 모래성을 쌓았던 시간이 가장 행복했어요."}
    ]
  }'

# 6. 대화 저장
curl -X POST "http://localhost:8000/api/v1/conversations/save" \
  -H "Content-Type: application/json" \
  -d '{
    "photoId": "photo-uuid",
    "turns": [
      {
        "question": "이 바다 여행에서 가장 기억에 남는 순간은 무엇인가요?",
        "answer": "아이들과 함께 모래성을 쌓았던 시간이 가장 행복했어요.",
        "timestamp": "2025-05-28T15:20:45"
      }
    ]
  }'

# 7. 회상 스토리 생성
curl -X POST "http://localhost:8000/api/v1/stories" \
  -H "Content-Type: application/json" \
  -d '{"mentionId": "mention-uuid"}'

# 8. 이상 징후 분석 리포트 생성
curl -X POST "http://localhost:8000/api/v1/reports/anomalies" \
  -H "Content-Type: application/json" \
  -d '{"mentionId": "mention-uuid"}'
```

## 📋 주요 API 엔드포인트

### 📸 사진 관리

| Method | Endpoint                   | 설명           |
| ------ | -------------------------- | -------------- |
| GET    | `/api/v1/photos`           | 사진 목록 조회 |
| POST   | `/api/v1/photos/upload`    | 사진 업로드    |
| GET    | `/api/v1/photos/{photoId}` | 사진 정보 조회 |

### ❓ 질문 생성

| Method | Endpoint                     | 설명           |
| ------ | ---------------------------- | -------------- |
| POST   | `/api/v1/questions/initial`  | 첫 질문 생성   |
| POST   | `/api/v1/questions/followup` | 추가 질문 생성 |

### 🎤 음성 처리

| Method | Endpoint                | 설명             |
| ------ | ----------------------- | ---------------- |
| POST   | `/api/v1/tts`           | 텍스트→음성 변환 |
| POST   | `/api/v1/stt`           | 음성→텍스트 변환 |
| POST   | `/api/v1/answers/audio` | 음성 분석        |

### 💬 대화 관리

| Method | Endpoint                            | 설명      |
| ------ | ----------------------------------- | --------- |
| POST   | `/api/v1/conversations/save`        | 대화 저장 |
| GET    | `/api/v1/conversations/{mentionId}` | 대화 조회 |

### 📖 스토리 & 분석

| Method | Endpoint                                | 설명                  |
| ------ | --------------------------------------- | --------------------- |
| POST   | `/api/v1/stories`                       | 스토리 생성           |
| GET    | `/api/v1/stories/{mentionId}`           | 스토리 조회           |
| POST   | `/api/v1/reports/anomalies`             | 이상 징후 리포트 생성 |
| GET    | `/api/v1/reports/anomalies/{mentionId}` | 리포트 조회           |

## 🔧 주요 기능

### 🖼️ 이미지 분석

- GPT-4V를 사용한 사진 내용 상세 분석
- 인물, 배경, 시대적 특징, 감정 등 추출
- 메타데이터와 결합한 맞춤형 정보 생성

### 💬 개인화 대화 시스템

- 사진 분석 결과 기반 첫 질문 생성
- 대화 흐름에 따른 자연스러운 후속 질문
- 치매 환자 특성을 고려한 친근한 말투

### 🎤 음성 처리

- Azure Speech Service 기반 TTS/STT
- 실시간 음성 인식 및 변환
- 음성 품질 분석 및 이상 징후 탐지

### 📊 분석 및 평가

- 대화 내용 기반 인지 기능 평가
- 감정 상태 및 언어 능력 분석
- 이상 징후 자동 탐지 및 리포트 생성

### 📖 자동 스토리 생성

- 대화 내용을 바탕으로 한 회상 스토리 자동 생성
- 1인칭 어르신 관점의 감성적 내러티브
- 가족과 공유 가능한 추억 기록

## 🗄️ 데이터베이스 설정

### SQLite (기본설정)

개발 및 테스트용으로 SQLite를 기본 사용합니다.

```env
DATABASE_URL=sqlite:///./dementia_system.db
```

### PostgreSQL (운영환경 권장)

```env
DATABASE_URL=postgresql://username:password@localhost:5432/dementia_db
```

PostgreSQL 설정:

```sql
-- 데이터베이스 생성
CREATE DATABASE dementia_db;
CREATE USER dementia_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE dementia_db TO dementia_user;
```

## 🔐 보안 고려사항

### API 보안

- 환경 변수로 민감 정보 관리
- CORS 설정으로 도메인 제한 (운영환경)
- 파일 업로드 크기 및 타입 검증
- 인증/인가 시스템 구현 권장

### 데이터 보안

- 개인정보 암호화 저장
- 음성 파일 접근 권한 관리
- 대화 내용 익명화 처리
- GDPR 준수 데이터 삭제 정책

## 🐛 트러블슈팅

### 일반적인 문제들

**1. Azure 서비스 연결 오류**

```bash
# 환경 변수 확인
echo $gpt_endpoint
echo $gpt_key

# Azure 서비스 상태 확인
curl -H "Ocp-Apim-Subscription-Key: $gpt_key" "$gpt_endpoint/deployments"
```

**2. 데이터베이스 연결 문제**

```bash
# SQLite 파일 권한 확인
ls -la dementia_system.db

# PostgreSQL 연결 테스트
psql $DATABASE_URL -c "SELECT version();"
```

**3. 파일 업로드 오류**

```bash
# 업로드 디렉토리 권한 확인
chmod 755 uploads/
chmod 755 audio_files/

# 디스크 공간 확인
df -h
```

**4. 음성 처리 오류**

- Azure Speech Service 할당량 확인
- 오디오 파일 형식 확인 (WAV, MP3 지원)
- 파일 크기 제한 확인 (최대 25MB)

## 📈 성능 최적화

### 파일 관리

- 이미지 크기 최적화 (권장: 2MB 이하)
- 오디오 파일 압축 (16kHz, 16bit 권장)
- 정기적인 임시 파일 정리

### 데이터베이스 최적화

- 인덱스 설정으로 조회 성능 향상
- 대화 데이터 파티셔닝
- 주기적인 백업 및 정리

### API 응답 시간

- GPT 응답 시간 최적화를 위한 토큰 제한
- 이미지 분석 결과 캐싱
- 병렬 처리를 통한 응답 속도 개선
