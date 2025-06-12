import os
import uuid
import requests
import io
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
from datetime import datetime
import traceback  # 디버깅용

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

            # 4. Fish-Speech API 호출 (파일 대신 BytesIO 사용)
            audio_file = io.BytesIO(reference_voice_data)
            audio_file.seek(0)  # 🔧 반드시 파일 시작 위치로 이동

            files = {
                'reference_wav': (f"{photo_id}.wav", audio_file, 'audio/wav')
            }
            data = {
                'text': conversation.summary_text,
                'prompt_text': conversation.summary_text
            }

            response = requests.post(
                "http://fish-speech:5000/infer",
                files=files,
                data=data
            )

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
            conversation.summary_voice = voice_url  # 또는 {"url": ..., "blob_name": ...} 필요에 따라

            await self.db.commit()
            return True

        except HTTPException as he:
            await self.db.rollback()
            raise he  # 기존 예외 그대로 전달
    

        except Exception as e:
            await self.db.rollback()
            print("[⛔] 예외 발생:", e)
            traceback.print_exc()
            raise HTTPException(status_code=500, detail=str(e))