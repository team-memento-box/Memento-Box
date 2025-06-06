import azure.cognitiveservices.speech as speechsdk
from fastapi import HTTPException
import os
from core.config import settings

class VoiceService:
    def __init__(self):
        self.speech_key = settings.AZURE_SPEECH_KEY
        self.speech_region = settings.AZURE_SPEECH_REGION
        if not self.speech_key or not self.speech_region:
            raise ValueError("Azure Speech credentials are not set")

    async def analyze_voice(self, audio_file_path: str) -> float:
        try:
            # Azure Speech 설정
            speech_config = speechsdk.SpeechConfig(
                subscription=self.speech_key,
                region=self.speech_region
            )
            
            # 오디오 설정
            audio_config = speechsdk.audio.AudioConfig(filename=audio_file_path)
            
            # Speech Recognizer 생성
            speech_recognizer = speechsdk.SpeechRecognizer(
                speech_config=speech_config,
                audio_config=audio_config
            )
            
            # 음성 인식 실행
            result = speech_recognizer.recognize_once_async().get()
            
            if result.reason == speechsdk.ResultReason.RecognizedSpeech:
                # 음성 분석 점수 계산 (예시: 단어 수, 발음 명확도 등)
                words = result.text.split()
                word_count = len(words)
                clarity_score = 1.0 if word_count > 5 else word_count / 5
                return clarity_score
            else:
                return 0.0
                
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Voice analysis failed: {str(e)}")

voice_service = VoiceService() 