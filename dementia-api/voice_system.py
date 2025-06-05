import azure.cognitiveservices.speech as speechsdk
import requests
import os
import uuid
from pathlib import Path
from config import Config

class VoiceSystem:
    """음성 입출력 시스템"""
    
    def __init__(self):
        self.speech_key = Config.SPEECH_KEY
        self.region = Config.SPEECH_REGION
        
        # STT 설정
        self.speech_config = speechsdk.SpeechConfig(subscription=self.speech_key, region=self.region)
        self.speech_config.speech_recognition_language = "ko-KR"
        
        # TTS 설정
        self.tts_voice = "ko-KR-SunHiNeural"
        
        # 오디오 폴더
        self.audio_dir = Path(Config.AUDIO_DIR)
        self.audio_dir.mkdir(exist_ok=True)
    
    def transcribe_audio_file(self, file_path: str) -> str:
        """업로드된 음성 파일을 텍스트로 변환"""
        try:
            audio_config = speechsdk.audio.AudioConfig(filename=file_path)
            speech_recognizer = speechsdk.SpeechRecognizer(
                speech_config=self.speech_config,
                audio_config=audio_config
            )
            
            result = speech_recognizer.recognize_once()
            
            if result.reason == speechsdk.ResultReason.RecognizedSpeech:
                return result.text.strip()
            else:
                return ""
                
        except Exception as e:
            return ""
    
    def get_access_token(self):
        """Azure Speech Service 액세스 토큰 요청"""
        url = f"https://{self.region}.api.cognitive.microsoft.com/sts/v1.0/issueToken"
        headers = {"Ocp-Apim-Subscription-Key": self.speech_key}
        try:
            res = requests.post(url, headers=headers)
            res.raise_for_status()
            return res.text
        except Exception:
            return None
    
    def text_to_speech(self, text: str) -> str:
        """텍스트를 음성으로 변환하고 파일로 저장"""
        if not text.strip():
            return None
            
        try:
            token = self.get_access_token()
            if not token:
                return None
                
            tts_url = f"https://{self.region}.tts.speech.microsoft.com/cognitiveservices/v1"
            
            headers = {
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/ssml+xml",
                "X-Microsoft-OutputFormat": "riff-16khz-16bit-mono-pcm",
                "User-Agent": "DementiaAnalysisSystem"
            }
            
            ssml = f"""
            <speak version='1.0' xml:lang='ko-KR'>
                <voice xml:lang='ko-KR' xml:gender='Female' name='{self.tts_voice}'>
                    {text}
                </voice>
            </speak>
            """
            
            res = requests.post(tts_url, headers=headers, data=ssml.encode("utf-8"))
            res.raise_for_status()
            
            # 음성 파일 저장
            file_id = str(uuid.uuid4())
            output_path = self.audio_dir / f"tts_{file_id}.wav"
            
            with open(output_path, "wb") as f:
                f.write(res.content)
            
            return str(output_path)
            
        except Exception as e:
            return None
    
    def save_uploaded_audio(self, audio_file, photo_id: str) -> str:
        """업로드된 음성 파일 저장"""
        try:
            file_extension = audio_file.filename.split('.')[-1] if '.' in audio_file.filename else 'wav'
            file_id = str(uuid.uuid4())
            file_path = self.audio_dir / f"{photo_id}_{file_id}.{file_extension}"
            
            with open(file_path, "wb") as f:
                content = audio_file.file.read()
                f.write(content)
            
            return str(file_path)
            
        except Exception as e:
            return None