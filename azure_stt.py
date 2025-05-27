import azure.cognitiveservices.speech as speechsdk

def transcribe_speech(audio_path: str, speech_key: str, region: str) -> str:
    speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=region)
    speech_config.speech_recognition_language = "ko-KR"  # ✅ 한국어 설정

    audio_config = speechsdk.audio.AudioConfig(filename=audio_path)

    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_config)

    print("🎙️ STT 실행 중...")
    result = speech_recognizer.recognize_once()

    if result.reason == speechsdk.ResultReason.RecognizedSpeech:
        print("📝 인식된 텍스트:", result.text)
        return result.text
    else:
        print("❌ 음성 인식 실패:", result.reason)
        return ""

# 예시 실행
speech_key = "GG4wOUABvgwI2Im4ZFlBfX4H7N13tLCtJ8g6UHn2w5SV8n3A5HttJQQJ99BEACYeBjFXJ3w3AAAYACOGdyy5"
region = "eastus"
prompt_audio_path = "azure_tts.wav"

prompt_text = transcribe_speech(prompt_audio_path, speech_key, region)
