from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import Optional, List
from uuid import UUID
from fastapi import HTTPException, UploadFile
from db.models.turn import Turn
from schemas.turn import TurnCreate, TurnUpdate
from services.blob_storage import get_blob_service_client
import os
import uuid
from datetime import datetime

class TurnService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_turn(
        self,
        q_voice: UploadFile,
        a_voice: UploadFile,
        q_text: str,
        a_text: str,
        conv_id: UUID
    ) -> Turn:
        """질문과 답변 음성 파일을 업로드하고 메타데이터를 저장합니다."""
        if not q_voice.content_type.startswith('audio/') or not a_voice.content_type.startswith('audio/'):
            raise HTTPException(status_code=400, detail="음성 파일만 업로드 가능합니다.")

        temp_q_path = None
        temp_a_path = None
        try:
            # 임시 파일로 저장
            os.makedirs("uploads", exist_ok=True)
            
            # 질문 음성 파일 저장
            temp_q_path = f"uploads/{uuid.uuid4()}_{q_voice.filename}"
            with open(temp_q_path, "wb") as buffer:
                content = await q_voice.read()
                buffer.write(content)

            # 답변 음성 파일 저장
            temp_a_path = f"uploads/{uuid.uuid4()}_{a_voice.filename}"
            with open(temp_a_path, "wb") as buffer:
                content = await a_voice.read()
                buffer.write(content)

            # Blob Storage에 업로드
            blob_service_client = get_blob_service_client("talking-voice")
            
            # 질문 음성 업로드
            with open(temp_q_path, "rb") as f:
                q_voice_url, _ = await blob_service_client.upload_file(f.read(), q_voice.filename)
            
            # 답변 음성 업로드
            with open(temp_a_path, "rb") as f:
                a_voice_url, _ = await blob_service_client.upload_file(f.read(), a_voice.filename)

            # DB에 메타데이터 저장
            turn_data = {
                "q_text": q_text,
                "a_text": a_text,
                "q_voice": q_voice_url,
                "a_voice": a_voice_url
            }
            
            turn = Turn(
                conv_id=conv_id,
                turn=turn_data,
                recorded_at=datetime.utcnow()
            )
            
            self.db.add(turn)
            await self.db.commit()
            await self.db.refresh(turn)
            
            return turn

        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
        finally:
            # 임시 파일 삭제
            if temp_q_path and os.path.exists(temp_q_path):
                os.remove(temp_q_path)
            if temp_a_path and os.path.exists(temp_a_path):
                os.remove(temp_a_path)

    async def get_turns_by_conversation(self, conv_id: UUID) -> List[Turn]:
        """특정 대화의 모든 턴을 조회합니다."""
        result = await self.db.execute(
            select(Turn).where(Turn.conv_id == conv_id)
        )
        return result.scalars().all()

    async def get_turn(self, turn_id: UUID) -> Optional[Turn]:
        """특정 턴의 상세 정보를 조회합니다."""
        result = await self.db.execute(
            select(Turn).where(Turn.id == turn_id)
        )
        return result.scalar_one_or_none()

    async def delete_turn(self, turn_id: UUID) -> bool:
        """특정 턴을 삭제합니다."""
        turn = await self.get_turn(turn_id)
        if not turn:
            return False
        
        # Blob Storage에서 파일 삭제
        blob_service_client = get_blob_service_client("voice")
        turn_data = turn.turn
        if turn_data.get("q_voice"):
            await blob_service_client.delete_file(turn_data["q_voice"].split("/")[-1])
        if turn_data.get("a_voice"):
            await blob_service_client.delete_file(turn_data["a_voice"].split("/")[-1])
        
        # DB에서 삭제
        await self.db.delete(turn)
        await self.db.commit()
        return True

    