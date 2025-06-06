from fastapi import HTTPException
import openai
from core.config import settings

class StoryService:
    def __init__(self):
        self.api_key = settings.AZURE_OPENAI_API_KEY
        self.endpoint = settings.AZURE_OPENAI_ENDPOINT
        if not self.api_key or not self.endpoint:
            raise ValueError("Azure OpenAI credentials are not set")
            
        openai.api_type = "azure"
        openai.api_version = settings.AZURE_OPENAI_API_VERSION
        openai.api_base = self.endpoint
        openai.api_key = self.api_key

    async def analyze_story(self, story_text: str) -> float:
        try:
            response = openai.ChatCompletion.create(
                engine=settings.AZURE_OPENAI_DEPLOYMENT_NAME,
                messages=[
                    {"role": "system", "content": "You are a dementia analysis expert. Analyze the following story for signs of dementia (coherence, memory, logical flow) and provide a score between 0 and 1, where 1 indicates high likelihood of dementia."},
                    {"role": "user", "content": story_text}
                ],
                temperature=0.3,
                max_tokens=150
            )
            
            # Extract score from response
            analysis = response.choices[0].message.content
            try:
                score = float(analysis.strip())
                return min(max(score, 0), 1)  # Ensure score is between 0 and 1
            except ValueError:
                return 0.5  # Default score if parsing fails
                
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Story analysis failed: {str(e)}")

    async def generate_story_prompt(self) -> str:
        prompts = [
            "어제 있었던 일을 이야기해주세요.",
            "가장 기억에 남는 여행에 대해 이야기해주세요.",
            "어린 시절의 추억을 들려주세요.",
            "가장 좋아하는 음식과 그 이유를 설명해주세요.",
            "가족과 함께한 특별한 순간을 이야기해주세요."
        ]
        import random
        return random.choice(prompts)

story_service = StoryService() 