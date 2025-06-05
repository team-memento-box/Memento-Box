import os
from fastapi import UploadFile
from datetime import datetime
import shutil
from typing import Optional

UPLOAD_DIR = "uploads"

async def save_upload_file(upload_file: UploadFile) -> Optional[str]:
    try:
        # 업로드 디렉토리가 없으면 생성
        os.makedirs(UPLOAD_DIR, exist_ok=True)
        
        # 파일명 생성 (timestamp + original filename)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{timestamp}_{upload_file.filename}"
        file_path = os.path.join(UPLOAD_DIR, filename)
        
        # 파일 저장
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(upload_file.file, buffer)
            
        return filename
    except Exception as e:
        print(f"Error saving file: {str(e)}")
        return None
    finally:
        upload_file.file.close() 