from fastapi import APIRouter, UploadFile, File
from fastapi.responses import JSONResponse
import tempfile
import os
from core.config import settings
import logging
import wave
import requests
import json

# 로깅 설정
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/speech",
    tags=["speech"]
)

@router.post("/speech-to-text")
async def test_speech(audio: UploadFile = File(...)):
    try:
        logger.debug(f"음성 파일 수신: {audio.filename}, Content-Type: {audio.content_type}")
        
        # 임시 파일로 오디오 저장
        with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as temp_file:
            content = await audio.read()
            temp_file.write(content)
            temp_file_path = temp_file.name
            logger.debug(f"임시 파일 생성: {temp_file_path}, 크기: {len(content)} bytes")

        # WAV 파일 포맷 확인
        try:
            with wave.open(temp_file_path, 'rb') as wav_file:
                n_channels = wav_file.getnchannels()
                sample_width = wav_file.getsampwidth()
                frame_rate = wav_file.getframerate()
                n_frames = wav_file.getnframes()
                duration = n_frames / frame_rate
                
                logger.debug(f"WAV 파일 포맷 정보:")
                logger.debug(f"- 채널 수: {n_channels} (mono=1, stereo=2)")
                logger.debug(f"- 샘플 폭: {sample_width} bytes (16bit=2)")
                logger.debug(f"- 샘플 레이트: {frame_rate} Hz")
                logger.debug(f"- 프레임 수: {n_frames}")
                logger.debug(f"- 재생 시간: {duration:.2f}초")
        except Exception as e:
            logger.error(f"WAV 파일 포맷 확인 중 오류: {str(e)}")
            return JSONResponse(
                status_code=400,
                content={
                    "status": "error",
                    "error": "올바르지 않은 WAV 파일 형식입니다."
                }
            )

        # Azure Speech REST API 호출
        logger.debug("Azure Speech REST API 호출 시작")
        url = f"https://{settings.AZURE_SPEECH_REGION}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1"
        
        headers = {
            'Ocp-Apim-Subscription-Key': settings.AZURE_SPEECH_KEY,
            'Content-Type': 'audio/wav;codecs=audio/pcm;rate=16000',
            'Accept': 'application/json'
        }

        params = {
            'language': 'ko-KR'
        }

        with open(temp_file_path, 'rb') as audio_file:
            response = requests.post(url, headers=headers, params=params, data=audio_file)
            
        logger.debug(f"REST API 응답 상태 코드: {response.status_code}")
        logger.debug(f"REST API 응답 내용: {response.text}")
        
        # 임시 파일 삭제
        os.unlink(temp_file_path)
        logger.debug("임시 파일 삭제 완료")

        if response.status_code == 200:
            result = response.json()
            logger.info(f"음성 인식 성공: {result.get('DisplayText', '')}")
            return JSONResponse(content={
                "status": "success",
                "text": result.get('DisplayText', ''),
                "confidence": result.get('NBest', [{}])[0].get('Confidence', 0)
            })
        else:
            error_message = f"음성 인식 실패: {response.text}"
            logger.warning(error_message)
            return JSONResponse(
                status_code=400,
                content={
                    "status": "error",
                    "error": error_message
                }
            )

    except Exception as e:
        logger.error(f"음성 인식 중 오류 발생: {str(e)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "error": f"음성 인식 중 오류가 발생했습니다: {str(e)}"
            }
        ) 