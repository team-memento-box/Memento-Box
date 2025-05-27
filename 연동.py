import requests
# 하고싶은거
text = """
이 사진은 내가 스무 살 때, 처음 서울 구경 갔을 때 찍은 거야.
저기 옆에 있는 친구는 순이, 참 말도 많고 웃음도 많던 아이였지.
그날 남대문시장에서 산 하늘색 원피스를 아직도 기억해.
사진 속 나는 참 해맑은데, 그땐 세상이 다 설레고 신기했지.
요즘도 이 사진 보면 가끔 그 시절 냄새가 나는 것 같아.
""" 
prompt_text = "이건 예시 프롬프트입니다."
wav_path = "test.wav"  # 로컬에 있는 참고 음성 파일

files = {"file": open(wav_path, "rb")}
data = {
    "text": text,
    "prompt_text": prompt_text
}

res = requests.post("http://20.41.115.128:8000/synthesize", data=data, files=files)

with open("result.wav", "wb") as f:
    f.write(res.content)

print("✅ 결과 저장 완료: result.wav")
