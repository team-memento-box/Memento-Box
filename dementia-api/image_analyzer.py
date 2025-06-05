import json
import base64
from openai import AzureOpenAI
from config import Config

class ImageAnalyzer:
    """GPT-4o를 사용한 이미지 분석"""
    
    def __init__(self):
        self.client = AzureOpenAI(
            api_version=Config.API_VERSION,
            azure_endpoint=Config.ENDPOINT,
            api_key=Config.SUBSCRIPTION_KEY,
        )
    
    def analyze_image_for_initial_question(self, image_path: str, story_year: str, story_season: str, story_nudge: dict):
        """이미지를 분석하여 첫 질문 생성을 위한 정보 추출"""
        try:
            with open(image_path, "rb") as image_file:
                base64_image = base64.b64encode(image_file.read()).decode('utf-8')
        except Exception:
            return None
        
        # story_nudge에서 키워드 추출
        keywords = story_nudge.get("keywords", [])
        mood = story_nudge.get("mood", "")
        
        try:
            response = self.client.chat.completions.create(
                model=Config.DEPLOYMENT,
                messages=[{
                    "role": "user",
                    "content": [{
                        "type": "text",
                        "text": f"""이미지를 분석해서 다음 정보를 JSON으로 답해주세요:
- 주요 인물들과 그들의 관계
- 배경과 장소
- 시대적 특징 (연도: {story_year}, 계절: {story_season})
- 분위기와 감정
- 주요 객체들
- 키워드 관련 요소: {keywords}
- 전체적인 상황 설명

JSON 형태:
{{
    "people": ["인물1", "인물2"],
    "relationships": "가족, 친구 등",
    "location": "장소",
    "time_period": "시대적 특징",
    "mood": "분위기",
    "key_objects": ["객체1", "객체2"],
    "keyword_elements": ["키워드 관련 요소"],
    "situation": "전체 상황 설명"
}}"""
                    }, {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}
                    }]
                }],
                max_tokens=1000,
                temperature=0.3
            )
            
            response_text = response.choices[0].message.content
            
            # JSON 추출
            if "```json" in response_text:
                json_start = response_text.find("```json") + 7
                json_end = response_text.find("```", json_start)
                response_text = response_text[json_start:json_end].strip()
            elif "{" in response_text:
                json_start = response_text.find("{")
                json_end = response_text.rfind("}") + 1
                response_text = response_text[json_start:json_end]
            
            analysis_result = json.loads(response_text)
            
            # mood와 keywords 추가
            analysis_result["mood"] = mood or analysis_result.get("mood", "")
            analysis_result["keywords"] = keywords
            
            return analysis_result
            
        except Exception as e:
            return None