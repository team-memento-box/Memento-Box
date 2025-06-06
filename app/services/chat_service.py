from fastapi import HTTPException
import openai
from core.config import settings

class ChatService:
    def __init__(self):
        self.api_key = settings.AZURE_OPENAI_API_KEY
        self.endpoint = settings.AZURE_OPENAI_ENDPOINT
        if not self.api_key or not self.endpoint:
            raise ValueError("Azure OpenAI credentials are not set")
            
        openai.api_type = "azure"
        openai.api_version = settings.AZURE_OPENAI_API_VERSION
        openai.api_base = self.endpoint
        openai.api_key = self.api_key

    async def analyze_chat(self, chat_text: str) -> float:
        try:
            response = openai.ChatCompletion.create(
                engine=settings.AZURE_OPENAI_DEPLOYMENT_NAME,
                messages=[
                    {"role": "system", "content": "You are a dementia analysis expert. Analyze the following chat for signs of dementia and provide a score between 0 and 1, where 1 indicates high likelihood of dementia."},
                    {"role": "user", "content": chat_text}
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
            raise HTTPException(status_code=500, detail=f"Chat analysis failed: {str(e)}")

chat_service = ChatService() 