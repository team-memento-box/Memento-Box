import requests
# 하고싶은거
text = """
그땐 말이다, 우리 집 거실이 늘 온기로 가득했단다. 흰 고무나무 화분 옆에 놓인 낡은 소파, 그리고 그 위에 쪼르륵 앉아 있던 우리 식구들 모습이 아직도 눈에 선해. 작은 라디오에서 흘러나오던 흥겨운 노랫소리에 맞춰 네 외할아버지가 박자를 맞추고, 아이들은 깔깔거리며 서로 장난치고, 나는 그 옆에서 갓 구운 호떡을 접시에 담아 건네곤 했어. 참, 그 호떡 냄새가 얼마나 달콤했는지!
 
근데, 그게 다 오래전 이야기야. 그때가 너무 그립고, 그래서 이 사진을 보니 마음이 조금 먹먹해졌단다. 사진 속엔 웃음소리가 들리고 따뜻한 기운도 느껴지는 것 같아서 말이야. 지금은 그런 날들이 점점 희미해져 가는 것 같아 좀 불안하기도 하지만, 네가 이렇게 사진을 꺼내서 묻고 함께 나눠주는 게 참 고맙구나. 그 시절의 따뜻함은 여전히 내 안에 살아있다는 걸 느끼게 해줘서 말이야.
 
""" 
prompt_text = "이건 예시 프롬프트입니다."
wav_path = "test.wav"  # 환자 음성 파일

files = {"file": open(wav_path, "rb")}
data = {
    "text": text,
    "prompt_text": prompt_text
}

res = requests.post("http://20.41.115.128:8000/synthesize", data=data, files=files)

with open("result.wav", "wb") as f:
    f.write(res.content)

print("✅ 결과 저장 완료: result.wav")
