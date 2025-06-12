import sys
import os

# 현재 파일의 위치 기준 상위 1~2단계를 sys.path에 추가
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.abspath(os.path.join(CURRENT_DIR, ".."))  # or "../.." if needed

sys.path.append(CURRENT_DIR)
sys.path.append(ROOT_DIR)

import uuid
import asyncio
from types import SimpleNamespace
from services.fish_TTS import VoiceConversionService
from services.blob_storage import get_blob_service_client
from pathlib import Path

class FakeDBSession:
    def __init__(self, photo, conversation, turn):
        self.photo = photo
        self.conversation = conversation
        self.turn = turn
        self.call = 0

    async def execute(self, query):
        class Result:
            def __init__(self, obj):
                self.obj = obj
            def scalar_one_or_none(self):
                return self.obj

        # select 순서대로 반환: photo -> conversation -> turn
        self.call += 1
        if self.call == 1:
            return Result(self.photo)
        elif self.call == 2:
            return Result(self.conversation)
        else:
            return Result(self.turn)

    async def commit(self):
        print("[✅] Commit 완료")

    async def rollback(self):
        print("[⛔] Rollback 실행")

async def prepare_test_blob():
    path = Path("services/fish-tmp/순재.wav")
    if not path.exists():
        raise FileNotFoundError("참조 음성 파일이 존재하지 않습니다.")

    blob_service = get_blob_service_client("photo")
    with open(path, "rb") as f:
        content = f.read()

    url, _ = await blob_service.upload_file(content, f"test_ref_{uuid.uuid4()}.wav")
    print("[🔗] 참조 음성 업로드 URL:", url)
    return url

async def test_voice_conversion():
    reference_url = await prepare_test_blob()
    fake_photo_id = uuid.uuid4()

    fake_photo = SimpleNamespace(
        id=fake_photo_id,
        summary_text="성공했나?",
        summary_voice=None
    )
    fake_conversation = SimpleNamespace(id=uuid.uuid4())
    fake_turn = SimpleNamespace(turn={"a_voice": reference_url})

    fake_db = FakeDBSession(fake_photo, fake_conversation, fake_turn)
    service = VoiceConversionService(fake_db)

    print("[🚀] convert_voice() 테스트 시작...")
    result = await service.convert_voice(fake_photo_id)
    print("[🎉] 변화 성공 유무:", result)

if __name__ == "__main__":
    asyncio.run(test_voice_conversion())
