import os
import uuid
import requests
from pathlib import Path
from typing import Optional
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import desc
from db.models.photo import Photo
from db.models.conversation import Conversation
from db.models.turn import Turn
from services.blob_storage import BlobStorageService, get_blob_service_client
import datetime

class VoiceConversionService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.blob_storage = get_blob_service_client("summary-voice")  # voice 컨테이너 사용

    async def convert_voice(self, photo_id: uuid.UUID) -> bool:
        """
        사진의 요약 텍스트를 음성으로 변환합니다.
        """
        try:
            # 1. Photo 정보 조회
            result = await self.db.execute(
                select(Photo).where(Photo.id == photo_id)
            )
            photo = result.scalar_one_or_none()
            
            if not photo or not photo.summary_text:
                raise HTTPException(status_code=404, detail="Photo or summary text not found")

            # 2. 가장 최근 Conversation과 Turn의 음성 가져오기
            result = await self.db.execute(
                select(Conversation)
                .where(Conversation.photo_id == photo_id)
                .order_by(desc(Conversation.created_at))
                .limit(1)
            )
            latest_conversation = result.scalar_one_or_none()
            
            if not latest_conversation:
                raise HTTPException(status_code=404, detail="No conversation found for this photo")

            # 해당 Conversation의 가장 최근 Turn 가져오기
            result = await self.db.execute(
                select(Turn)
                .where(Turn.conv_id == latest_conversation.id)
                .order_by(desc(Turn.recorded_at))
                .limit(1)
            )
            latest_turn = result.scalar_one_or_none()
            
            if not latest_turn or not latest_turn.turn.get('a_voice'):
                raise HTTPException(status_code=404, detail="Reference voice not found")

            # 3. Blob Storage에서 참조 음성 파일 다운로드
            reference_voice_url = latest_turn.turn['a_voice']
            response = requests.get(reference_voice_url)
            if response.status_code != 200:
                raise HTTPException(status_code=500, detail="Failed to download reference voice")
            
            reference_voice_data = response.content

            # 4. Fish-Speech API 호출
            temp_wav_path = f"/fish-tmp/{photo_id}.wav"
            with open(temp_wav_path, "wb") as f:
                f.write(reference_voice_data)

            with open(temp_wav_path, "rb") as f:
                files = {
                    'reference_wav': (f"{photo_id}.wav", f, 'audio/wav')
                }
                data = {
                    'text': photo.summary_text,
                    'prompt_text': ''
                }

                response = requests.post(
                    "http://fish-speech:5000/infer",
                    files=files,
                    data=data
                )

            os.remove(temp_wav_path)  # 임시 파일 삭제

            if response.status_code != 200 or b"RIFF" not in response.content[:4]:
                raise HTTPException(status_code=500, detail="Voice conversion failed")

            # 5. Blob Storage 업로드
            timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
            filename = f"summary_voice_{photo_id}_{timestamp}.wav"

            voice_url, blob_name = await self.blob_storage.upload_file(
                response.content,
                filename
            )

            # 6. Photo 객체에 저장
            photo.summary_voice = {"url": voice_url, "blob_name": blob_name}
            await self.db.commit()

        except Exception as e:
            await self.db.rollback()
            raise HTTPException(status_code=500, detail=str(e))

# """
# 로컬환경 테스트
# """
# import uuid
# import aiohttp
# import asyncio
# from pathlib import Path

# from services.blob_storage import get_blob_service_client

# # 로컬 테스트용 설정
# TEST_AUDIO_PATH = "./test_samples/sample_ref.wav"  # 로컬에 있는 짧은 음성
# SUMMARY_TEXT = "이것은 테스트용 요약 문장입니다."
# PHOTO_ID = uuid.uuid4()  # 임시 ID로 테스트
# FISH_SPEECH_API_URL = "http://localhost:5000/infer"  # fish_main.py 서버 주소

# # Blob 업로드용 서비스 초기화
# blob_client = get_blob_service_client("voice")


# async def test_voice_conversion():
#     print("[1] 로컬 테스트 음성 파일 존재 여부 확인")
#     if not Path(TEST_AUDIO_PATH).exists():
#         raise FileNotFoundError("테스트용 음성 파일이 존재하지 않습니다.")

#     print("[2] 음성 + 요약 텍스트를 fish-speech로 전송")
#     async with aiohttp.ClientSession() as session:
#         with open(TEST_AUDIO_PATH, "rb") as f:
#             files = {"reference_wav": f}
#             data = {"text": SUMMARY_TEXT, "prompt_text": ""}
#             form = aiohttp.FormData()
#             form.add_field("reference_wav", f, filename="sample.wav", content_type="audio/wav")
#             form.add_field("text", SUMMARY_TEXT)
#             form.add_field("prompt_text", "")

#             async with session.post(FISH_SPEECH_API_URL, data=form) as response:
#                 if response.status != 200:
#                     raise Exception(f"TTS API 호출 실패: {response.status}, {await response.text()}")
#                 print("[3] 음성 변환 성공")
#                 audio_data = await response.read()

#     print("[4] Blob Storage에 업로드 시도")
#     filename = f"test_summary_voice_{PHOTO_ID}.wav"
#     voice_url, blob_name = await blob_client.upload_file(audio_data, filename)
#     print("[5] 업로드 성공")
#     print(" - URL:", voice_url)
#     print(" - Blob Name:", blob_name)


# if __name__ == "__main__":
#     asyncio.run(test_voice_conversion())
