from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import FileResponse
import shutil
import requests
import uuid
import os
import time

app = FastAPI()

@app.post("/upload")
async def upload(
    text: str = Form(...),
    prompt_text: str = Form(""),
    file: UploadFile = File(...)
):
    filename = f"{uuid.uuid4().hex}.wav"
    input_path = f"/app/input_wav/{filename}"
    output_path = f"/app/output_wav/{filename}"

    # 1. 파일 저장
    with open(input_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 2. fish-speech에 추론 요청
    response = requests.post("http://fish-speech:5000/infer", json={
        "text": text,
        "reference_wav": filename,
        "prompt_text": prompt_text
    })

    result = response.json()

    if result.get("status") == "success" and os.path.exists(output_path):
        return FileResponse(output_path, media_type="audio/wav", filename=filename)
    else:
        return {
            "status": "error",
            "message": result.get("message", "inference failed or took too long."),
            "filename": filename
        }
