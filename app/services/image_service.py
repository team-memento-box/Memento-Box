from fastapi import HTTPException
from PIL import Image
import numpy as np
from core.config import settings
import os

class ImageService:
    def __init__(self):
        self.upload_dir = settings.UPLOAD_DIR
        os.makedirs(self.upload_dir, exist_ok=True)

    async def analyze_image(self, image_path: str) -> float:
        try:
            # 이미지 로드 및 전처리
            image = Image.open(image_path)
            image = image.convert('RGB')
            
            # 이미지 분석 (예시: 선명도, 대칭성 등 체크)
            img_array = np.array(image)
            
            # 선명도 체크
            clarity = np.std(img_array)
            clarity_score = min(clarity / 100, 1.0)
            
            # 대칭성 체크
            width = img_array.shape[1]
            left_half = img_array[:, :width//2]
            right_half = np.fliplr(img_array[:, width//2:])
            symmetry = np.mean(np.abs(left_half - right_half))
            symmetry_score = 1.0 - min(symmetry / 255, 1.0)
            
            # 최종 점수 계산
            final_score = (clarity_score + symmetry_score) / 2
            return final_score
            
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Image analysis failed: {str(e)}")

image_service = ImageService() 