import json
from datetime import datetime
from openai import AzureOpenAI
from config import Config
from typing import List, Dict, Any

class StoryGenerator:
    """회상 스토리 생성 시스템"""
    
    def __init__(self):
        self.client = AzureOpenAI(
            api_version=Config.API_VERSION,
            azure_endpoint=Config.ENDPOINT,
            api_key=Config.SUBSCRIPTION_KEY,
        )
    
    def generate_story_from_conversation(self, conversation_data: List[Dict[str, Any]]) -> str:
        """대화 내용을 바탕으로 회상 스토리 생성"""
        
        # 대화 내용을 문자열로 변환
        conversation_text = ""
        for turn in conversation_data:
            question = turn.get("question", "")
            answer = turn.get("answer", "")
            conversation_text += f"질문: {question}\n답변: {answer}\n\n"
        
        system_prompt = """당신은 어르신의 추억을 바탕으로 따뜻한 회상 스토리를 작성하는 작가입니다.

대화 내용을 바탕으로 어르신의 1인칭 시점에서 추억 스토리를 작성해주세요.

규칙:
1. 어르신의 목소리로 작성 (1인칭)
2. 따뜻하고 감성적인 톤
3. 구체적인 감정과 감각 묘사 포함
4. 15-20줄 정도의 적당한 길이
5. 손자/손녀에게 들려주는 어투
6. 대화에서 언급된 구체적인 내용들을 포함
7. 시간의 흐름과 감정의 변화를 자연스럽게 표현"""

        try:
            response = self.client.chat.completions.create(
                model=Config.DEPLOYMENT,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"다음 대화를 바탕으로 회상 스토리를 작성해주세요:\n\n{conversation_text}"}
                ],
                max_tokens=1000,
                temperature=0.8,
                top_p=0.9
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            return "추억 스토리를 생성할 수 없습니다."

class AnomalyAnalyzer:
    """이상 징후 분석 시스템"""
    
    def __init__(self):
        self.client = AzureOpenAI(
            api_version=Config.API_VERSION,
            azure_endpoint=Config.ENDPOINT,
            api_key=Config.SUBSCRIPTION_KEY,
        )
    
    def analyze_conversation_anomalies(self, conversation_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """대화 내용에서 이상 징후 분석"""
        
        # 대화 내용을 문자열로 변환
        conversation_text = ""
        for turn in conversation_data:
            question = turn.get("question", "")
            answer = turn.get("answer", "")
            timestamp = turn.get("timestamp", "")
            conversation_text += f"[{timestamp}] 질문: {question}\n답변: {answer}\n\n"
        
        system_prompt = """당신은 치매 전문 의료진입니다. 대화 내용을 분석하여 인지 기능 이상 징후를 판단해주세요.

다음 항목들을 체크해주세요:
1. 기억력 문제 (최근 일, 과거 일 기억 어려움)
2. 언어 능력 저하 (단어 찾기 어려움, 반복)
3. 판단력 저하 (비논리적 답변, 시간/장소 혼란)
4. 감정 변화 (우울감, 무력감, 불안감)
5. 반복적 행동/말
6. 집중력 저하 (질문과 관련 없는 답변)

JSON 형태로 답변:
{
    "severity": "none/mild/moderate/severe",
    "anomalies": [
        {
            "type": "memory_loss/language_difficulty/judgment_impairment/emotional_change/repetitive_behavior/attention_deficit",
            "evidence": "구체적 증거",
            "severity": "mild/moderate/severe"
        }
    ],
    "overall_assessment": "전반적 평가",
    "recommendations": "권장사항"
}"""

        try:
            response = self.client.chat.completions.create(
                model=Config.DEPLOYMENT,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"다음 대화를 분석해주세요:\n\n{conversation_text}"}
                ],
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
            
            return json.loads(response_text)
            
        except Exception as e:
            return {
                "severity": "none",
                "anomalies": [],
                "overall_assessment": "분석을 완료할 수 없습니다.",
                "recommendations": "전문의 상담을 권장합니다."
            }
    
    def analyze_audio_anomalies(self, audio_path: str, transcription: str) -> Dict[str, Any]:
        """음성 파일에서 이상 징후 분석"""
        
        # 현재는 텍스트만 분석하지만, 향후 음성 특징 분석도 추가 가능
        system_prompt = """당신은 치매 전문 의료진입니다. 음성 인식 결과를 분석하여 언어적 이상 징후를 판단해주세요.

다음 항목들을 체크해주세요:
1. 발음 문제
2. 말의 속도 (너무 빠르거나 느림)
3. 단어 찾기 어려움
4. 문장 구조 문제
5. 의미 없는 반복

JSON 형태로 답변:
{
    "severity": "none/mild/moderate/severe",
    "speech_anomalies": [
        {
            "type": "pronunciation/speed/word_finding/structure/repetition",
            "evidence": "구체적 증거",
            "severity": "mild/moderate/severe"
        }
    ],
    "transcription_quality": "good/fair/poor",
    "recommendations": "권장사항"
}"""

        try:
            response = self.client.chat.completions.create(
                model=Config.DEPLOYMENT,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"음성 인식 결과: {transcription}"}
                ],
                max_tokens=500,
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
            
            return json.loads(response_text)
            
        except Exception as e:
            return {
                "severity": "none",
                "speech_anomalies": [],
                "transcription_quality": "poor",
                "recommendations": "음성 분석을 완료할 수 없습니다."
            }