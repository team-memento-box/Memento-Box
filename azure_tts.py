import requests

# 🔐 Azure Speech 키와 지역 설정
SPEECH_KEY = "GG4wOUABvgwI2Im4ZFlBfX4H7N13tLCtJ8g6UHn2w5SV8n3A5HttJQQJ99BEACYeBjFXJ3w3AAAYACOGdyy5"
REGION = "eastus"  # 예: koreacentral

# 📥 TTS 요청 파라미터
text = "안녕하세요, Azure 음성 합성입니다."
voice = "ko-KR-SunHiNeural"  # 여성 음성 예시

# 1. Access Token 요청
def get_access_token():
    url = f"https://{REGION}.api.cognitive.microsoft.com/sts/v1.0/issueToken"
    headers = {
        "Ocp-Apim-Subscription-Key": SPEECH_KEY
    }
    res = requests.post(url, headers=headers)
    res.raise_for_status()
    return res.text

# 2. TTS 요청 → 음성 파일 생성
def synthesize_speech(text, voice="ko-KR-SunHiNeural", output_path="azure_tts.wav"):
    token = get_access_token()
    tts_url = f"https://{REGION}.tts.speech.microsoft.com/cognitiveservices/v1"

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/ssml+xml",
        "X-Microsoft-OutputFormat": "riff-16khz-16bit-mono-pcm",  # WAV 포맷
        "User-Agent": "AzureTTSClient"
    }

    ssml = f"""
    <speak version='1.0' xml:lang='ko-KR'>
        <voice xml:lang='ko-KR' xml:gender='Female' name='{voice}'>
            {text}
        </voice>
    </speak>
    """

    res = requests.post(tts_url, headers=headers, data=ssml.encode("utf-8"))
    res.raise_for_status()

    with open(output_path, "wb") as f:
        f.write(res.content)
    print(f"✅ 음성 저장 완료: {output_path}")

# ▶ 사용 예시
synthesize_speech("오늘도 좋은 하루 되세요!", voice="ko-KR-SunHiNeural")
