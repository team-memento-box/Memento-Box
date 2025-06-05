from openai import AzureOpenAI
from config import Config
from typing import List, Dict, Any

class QuestionGenerator:
    """질문 생성 시스템"""
    
    def __init__(self):
        self.client = AzureOpenAI(
            api_version=Config.API_VERSION,
            azure_endpoint=Config.ENDPOINT,
            api_key=Config.SUBSCRIPTION_KEY,
        )
    
    def generate_initial_question(self, photo_analysis: Dict[str, Any], photo_name: str, story_year: str, story_season: str) -> str:
        """첫 질문 생성"""
        
        people = photo_analysis.get("people", [])
        relationships = photo_analysis.get("relationships", "")
        location = photo_analysis.get("location", "")
        mood = photo_analysis.get("mood", "")
        key_objects = photo_analysis.get("key_objects", [])
        keywords = photo_analysis.get("keywords", [])
        situation = photo_analysis.get("situation", "")
        
        system_prompt = f"""당신은 치매 환자와 대화하는 요양보호사입니다. 
어르신의 추억을 자연스럽게 끌어내는 첫 질문을 만들어주세요.

사진 정보:
- 사진명: {photo_name}
- 연도: {story_year}
- 계절: {story_season}
- 인물: {', '.join(people)}
- 관계: {relationships}
- 장소: {location}
- 분위기: {mood}
- 주요 객체: {', '.join(key_objects)}
- 키워드: {', '.join(keywords)}
- 상황: {situation}

규칙:
1. 친근하고 따뜻한 말투
2. 50자 이내의 간단한 질문
3. 사진 속 특정 요소에 대해 물어보기
4. 어르신의 기억을 자극할 수 있는 질문
5. 질문만 답변하고 다른 말은 하지 마세요"""

        try:
            response = self.client.chat.completions.create(
                model=Config.DEPLOYMENT,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": "어르신께 첫 질문을 해주세요."}
                ],
                max_tokens=Config.MAX_TOKENS,
                temperature=Config.TEMPERATURE,
                top_p=Config.TOP_P,
                frequency_penalty=Config.FREQUENCY_PENALTY,
                presence_penalty=Config.PRESENCE_PENALTY
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            return "이 사진에 대해 말씀해 주시겠어요?"
    
    def generate_followup_question(self, chat_history: List[Dict[str, str]]) -> str:
        """추가 질문 생성"""
        
        # 대화 히스토리를 문자열로 변환
        conversation_text = ""
        for turn in chat_history:
            role = turn.get("role", "")
            content = turn.get("content", "")
            if role == "assistant":
                conversation_text += f"질문: {content}\n"
            elif role == "user":
                conversation_text += f"답변: {content}\n"
        
        system_prompt = """당신은 치매 환자와 대화하는 요양보호사입니다.
지금까지의 대화를 바탕으로 자연스러운 후속 질문을 만들어주세요.

규칙:
1. 이전 답변에 공감하면서 시작
2. 관련된 새로운 질문으로 연결
3. 50자 이내의 간단한 질문
4. 친근하고 따뜻한 말투
5. 어르신의 더 깊은 기억을 이끌어내는 질문
6. 질문만 답변하고 다른 말은 하지 마세요"""

        try:
            response = self.client.chat.completions.create(
                model=Config.DEPLOYMENT,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"대화 내역:\n{conversation_text}\n\n다음 질문을 해주세요."}
                ],
                max_tokens=Config.MAX_TOKENS,
                temperature=Config.TEMPERATURE,
                top_p=Config.TOP_P,
                frequency_penalty=Config.FREQUENCY_PENALTY,
                presence_penalty=Config.PRESENCE_PENALTY
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            return "더 자세히 말씀해 주시겠어요?"