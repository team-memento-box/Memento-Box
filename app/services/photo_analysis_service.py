from fastapi import HTTPException
from openai import AzureOpenAI
from typing import Dict, Any, List
import os
import logging
import json
import base64
from openai.types.chat import ChatCompletion
import httpx
from dotenv import load_dotenv

# Configure logging
# logging.basicConfig(level=logging.INFO)
# logger = logging.getLogger(__name__)

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# ─────────────────────────────환경변수─────────────────────────────
API_KEY    = os.getenv("AZURE_OPENAI_KEY")
ENDPOINT   = os.getenv("AZURE_OPENAI_ENDPOINT")
DEPLOYMENT = os.getenv("AZURE_OPENAI_DEPLOYMENT")
API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION")
#──────────────────────────────────────────────────────────


class PhotoAnalysisService:
    def __init__(self):
        try:
            # Azure OpenAI 클라이언트 초기화
            api_key = API_KEY
            api_version = API_VERSION
            azure_endpoint = ENDPOINT
            deployment_name = DEPLOYMENT
            
            # Validate required configuration
            if not all([api_key, azure_endpoint]):
                raise ValueError("Missing required Azure OpenAI configuration")
            
            # logger.info(f"Initializing AzureOpenAI client with endpoint: {azure_endpoint}")
            
            # 커스텀 HTTP 클라이언트 설정
            http_client = httpx.Client(
                base_url=azure_endpoint,
                timeout=60.0
            )
            
            # AzureOpenAI 클라이언트 초기화
            self.client = AzureOpenAI(
                api_key=api_key,
                api_version=api_version,
                azure_endpoint=azure_endpoint,
                http_client=http_client
            )
            self.deployment_name = deployment_name
                
        except Exception as e:
            # logger.error(f"Error initializing PhotoAnalysisService: {str(e)}")
            raise HTTPException(
                status_code=500,
                detail=f"Failed to initialize photo analysis service: {str(e)}"
            )

    async def analyze_photo(self, image_path: str, photo_name: str) -> Dict[str, Any]:
        """사진 분석"""
        try:
            # 이미지 파일을 base64로 인코딩
            with open(image_path, "rb") as image_file:
                image_data = image_file.read()
                image_base64 = base64.b64encode(image_data).decode('utf-8')
            
            system_prompt = """당신은 사진을 분석하는 전문가입니다.
주어진 사진을 분석하여 다음 정보를 추출해주세요:

1. 인물 (people): 사진 속 인물들의 리스트
2. 관계 (relationships): 인물들 간의 관계
3. 장소 (location): 사진이 촬영된 장소
4. 분위기 (mood): 사진의 전반적인 분위기
5. 주요 객체 (key_objects): 사진 속 주요 물체들의 리스트
6. 키워드 (keywords): 사진을 설명하는 주요 키워드들의 리스트
7. 상황 (situation): 사진 속 상황 설명

JSON 형식으로 응답해주세요."""

            try:
                # logger.info(f"Sending request to OpenAI API with model: {self.deployment_name}")
                response: ChatCompletion = self.client.chat.completions.create(
                    model=self.deployment_name,
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": f"사진명: {photo_name}\n이미지 데이터: {image_base64[:100]}..."}
                    ],
                    max_tokens=1000,
                    temperature=0.7,
                    top_p=0.9
                )
                
                # 응답을 파싱하여 딕셔너리로 변환
                analysis_text = response.choices[0].message.content.strip()
                # logger.info("Successfully received response from OpenAI API")
                
                try:
                    analysis_dict = json.loads(analysis_text)
                    return analysis_dict
                except json.JSONDecodeError as e:
                    # logger.error(f"Failed to parse JSON response: {e}")
                    return {
                        "people": [],
                        "relationships": "",
                        "location": "",
                        "mood": "",
                        "key_objects": [],
                        "keywords": [],
                        "situation": "JSON 파싱 중 오류가 발생했습니다."
                    }
                
            except Exception as e:
                # logger.error(f"Error in OpenAI API call: {str(e)}")
                return {
                    "people": [],
                    "relationships": "",
                    "location": "",
                    "mood": "",
                    "key_objects": [],
                    "keywords": [],
                    "situation": f"API 호출 중 오류가 발생했습니다: {str(e)}"
                }
                
        except Exception as e:
            # logger.error(f"Error analyzing photo: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Photo analysis failed: {str(e)}")

# 싱글톤 인스턴스 생성
photo_analysis_service = PhotoAnalysisService() 