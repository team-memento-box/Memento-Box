from fastapi import FastAPI, File, Form, UploadFile
from fastapi.responses import StreamingResponse
from fish_module import init_engine, run_tts
from preprocessing import preprocess_wav_directory
from pathlib import Path
import io
import os

app = FastAPI()
engine = init_engine()

@app.post("/infer")
async def infer(
    reference_wav: UploadFile = File(...),
    text: str = Form(...),
    prompt_text: str = Form("")
):
    # 1. 경로 설정
    input_dir = Path("/beforepreprocess")
    output_dir = Path("/afterpreprocess")
    model_output_dir = Path("/modeloutput")

    # 2. 파일 저장
    input_path = input_dir / reference_wav.filename
    with open(input_path, "wb") as f:
        f.write(await reference_wav.read())

    try:
        # 3. 전처리 실행
        preprocess_wav_directory(str(input_dir), str(output_dir))

        # 4. 전처리된 파일 찾기
        processed_path = next(output_dir.glob("*.wav"), None)
        if not processed_path or not processed_path.exists():
            raise FileNotFoundError("전처리된 .wav 파일을 찾을 수 없습니다.")

        # 5. 추론
        audio_data = run_tts(engine, text, str(processed_path), prompt_text)

        # 6. 결과 저장
        output_path = model_output_dir / "output.wav"
        with open(output_path, "wb") as f:
            f.write(audio_data)

        # 7. 응답
        return StreamingResponse(io.BytesIO(audio_data), media_type="audio/wav")

    except Exception as e:
        return {"status": "error", "message": str(e)}
    finally:
        # 클린업: 입력 파일, 전처리 파일 삭제
        if input_path.exists():
            input_path.unlink(missing_ok=True)
        for f in output_dir.glob("*.wav"):
            f.unlink(missing_ok=True)
