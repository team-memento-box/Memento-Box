from fastapi import FastAPI, HTTPException
import azure.cognitiveservices.speech as speechsdk
import os
import io
import wave
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI()

# Azure Speech 설정
speech_key = os.getenv("AZURE_SPEECH_KEY")
speech_region = os.getenv("AZURE_SPEECH_REGION")

if not speech_key or not speech_region:
    raise ValueError("AZURE_SPEECH_KEY and AZURE_SPEECH_REGION must be set in environment variables")

@app.post("/process")
async def process_audio(audio_data: bytes):
    try:
        # 오디오 데이터를 임시 WAV 파일로 저장
        with wave.open("temp.wav", "wb") as wav_file:
            wav_file.setnchannels(1)  # mono
            wav_file.setsampwidth(2)  # 16-bit
            wav_file.setframerate(16000)  # 16kHz
            wav_file.writeframes(audio_data)

        # Azure Speech 설정
        speech_config = speechsdk.SpeechConfig(
            subscription=speech_key,
            region=speech_region
        )
        
        # 오디오 설정
        audio_config = speechsdk.audio.AudioConfig(filename="temp.wav")
        
        # Speech Recognizer 생성
        speech_recognizer = speechsdk.SpeechRecognizer(
            speech_config=speech_config,
            audio_config=audio_config
        )
        
        # 음성 인식 실행
        result = speech_recognizer.recognize_once_async().get()
        
        # 임시 파일 삭제
        os.remove("temp.wav")
        
        if result.reason == speechsdk.ResultReason.RecognizedSpeech:
            return {"text": result.text}
        else:
            return {"text": ""}
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/status")
async def get_status():
    return {"status": "healthy"} 