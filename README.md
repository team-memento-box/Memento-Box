# Dialog-Service README

이 문서는 FastAPI 기반 음성(STT → GPT → TTS) 챗봇 백엔드를 실행하기 위한 가이드입니다.  
프로젝트는 다음 주요 구성요소로 이루어져 있습니다:

- **`main.py`**: 텍스트 및 음성 전용 엔드포인트(` /chat`, `/chat_audio`) 구현  
- **`openai_client.py`**: Azure Speech SDK 및 Azure OpenAI 호출(STT, GPT, TTS) 로직  
- **`preprocess.py`**: FFmpeg를 활용해 업로드된 WAV 파일을 16kHz·모노·PCM 형식으로 전처리  
- **`database.py`**: SQLAlchemy를 사용한 PostgreSQL 연결 설정 및 모델 정의 (`Message`, `Report`)  
- **`requirements.txt`**: Python 의존성 목록  
- **`Dockerfile`**: 컨테이너 빌드를 위한 설정 (Python 3.10-slim + FFmpeg 설치)

---

## 목차

1. [사전 준비](#사전-준비)  
2. [프로젝트 클론 & 디렉터리 구조](#프로젝트-클론--디렉터리-구조)  
3. [환경 변수 구성](#환경-변수-구성)  
4. [로컬에서 실행하기](#로컬에서-실행하기)  
   1. [Python 가상환경 설정](#python-가상환경-설정)  
   2. [의존성 설치](#의존성-설치)  
   3. [데이터베이스 초기화](#데이터베이스-초기화)  
   4. [서버 실행 (uvicorn)](#서버-실행-uvicorn)  
5. [Docker 컨테이너로 실행하기](#docker-컨테이너로-실행하기)  
   1. [이미지 빌드](#이미지-빌드)  
   2. [컨테이너 실행](#컨테이너-실행)  
6. [API 사용 예시](#api-사용-예시)  
   1. [텍스트 채팅: `/chat`](#텍스트-채팅-chat)  
   2. [음성 채팅: `/chat_audio`](#음성-채팅-chat_audio)  
7. [추가 참고사항](#추가-참고사항)  

---

## 사전 준비

- **Python 3.10 이상** (권장)  
- **PostgreSQL** (예: 로컬 또는 원격)  
- **FFmpeg** (로컬 실행 시 시스템에 설치 필요, Docker를 이용하면 Dockerfile에서 자동 설치됨)  
- **Azure 리소스**  
  - Azure Speech 서비스 (STT/TTS용 키 & 리전)  
  - Azure OpenAI 서비스 (GPT 호출용 엔드포인트 & 키)

---

## 프로젝트 클론 & 디렉터리 구조

```bash
git clone <REPO_URL>
cd dialog-service
