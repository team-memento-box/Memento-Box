import json
import base64
import os
import tiktoken
import random
from dataclasses import dataclass
from typing import List, Optional, Dict, Any
from dotenv import load_dotenv
from openai import AzureOpenAI
from datetime import datetime
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from PIL import Image
import numpy as np

# 환경 변수 로드
load_dotenv()

@dataclass
class StrangeResponse:
    """이상한 답변을 저장하는 데이터 클래스"""
    question: str
    answer: str
    timestamp: str
    severity: str  # "mild", "moderate", "severe"
    question_type: str = "normal"  # "keyword", "cognitive", "normal"

@dataclass
class ConversationTurn:
    """대화 턴을 저장하는 데이터 클래스"""
    question: str
    answer: str
    timestamp: str
    question_type: str = "normal"  # "keyword", "cognitive", "normal"

class ImageAnalysisGPT:
    """GPT-4o를 사용한 이미지 분석 클래스"""
    def __init__(self):
        # Azure OpenAI 관련 설정
        self.endpoint = os.getenv("gpt-endpoint")
        self.deployment = "gpt-4o"
        self.subscription_key = os.getenv("gpt-key")
        self.api_version = "2024-12-01-preview"
        
        if not self.endpoint or not self.subscription_key:
            raise ValueError("Please set the gpt-endpoint and gpt-key in the environment variables.")
        
        # LLM 클라이언트 초기화
        self.client = AzureOpenAI(
            api_version=self.api_version,
            azure_endpoint=self.endpoint,
            api_key=self.subscription_key,
        )
    
    def encode_image_to_base64(self, image_path):
        """이미지를 base64로 인코딩"""
        try:
            with open(image_path, "rb") as image_file:
                return base64.b64encode(image_file.read()).decode('utf-8')
        except FileNotFoundError:
            print(f"Error: 이미지 파일을 찾을 수 없습니다: {image_path}")
            return None
        except Exception as e:
            print(f"이미지 인코딩 오류: {e}")
            return None
    
    def analyze_image_with_gpt(self, image_path):
        """GPT-4o를 사용하여 이미지 분석"""
        # 이미지를 base64로 인코딩
        base64_image = self.encode_image_to_base64(image_path)
        if not base64_image:
            return None
        
        try:
            response = self.client.chat.completions.create(
                model=self.deployment,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "text",
                                "text": """이 이미지를 자세히 분석해서 다음 정보를 JSON 형식으로 제공해주세요:

1. caption: 이미지의 전체적인 설명 (구체적으로 그리고 한편의 이야기처럼)
2. dense_captions: 이미지의 세부적인 요소들을 여러 문장으로 설명 (배열 형태)
3. mood: 이미지에서 느껴지는 분위기나 감정
4. time_period: 추정되는 시대나 시기
5. key_objects: 주요 객체들 (배열 형태)
6. people_description: 사람이 있다면 그들에 대한 설명
7. people_count: 사진 속 사람 수 (숫자로)
8. time_of_day: 촬영 시간대 (낮/밤/저녁 등)

다음과 같은 JSON 형식으로 답해주세요:
{
    "caption": "전체 이미지 설명",
    "dense_captions": ["세부사항1", "세부사항2", "세부사항3"],
    "mood": "분위기 설명",
    "time_period": "추정 시대",
    "key_objects": ["객체1", "객체2", "객체3"],
    "people_description": "사람들에 대한 설명",
    "people_count": 2,
    "time_of_day": "낮"
}"""
                            },
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{base64_image}"
                                }
                            }
                        ]
                    }
                ],
                max_tokens=1000,
                temperature=0.3
            )
            
            # 응답에서 JSON 추출
            response_text = response.choices[0].message.content
            
            # JSON 부분만 추출 (```json으로 감싸져 있을 수 있음)
            if "```json" in response_text:
                json_start = response_text.find("```json") + 7
                json_end = response_text.find("```", json_start)
                response_text = response_text[json_start:json_end].strip()
            elif "{" in response_text:
                json_start = response_text.find("{")
                json_end = response_text.rfind("}") + 1
                response_text = response_text[json_start:json_end]
            
            analysis_result = json.loads(response_text)
            
            # 결과 출력
            print(f"\nCaption: {analysis_result.get('caption', 'N/A')}")
            print(f"Mood: {analysis_result.get('mood', 'N/A')}")
            print(f"Time Period: {analysis_result.get('time_period', 'N/A')}")
            print(f"People Count: {analysis_result.get('people_count', 'N/A')}")
            print(f"Time of Day: {analysis_result.get('time_of_day', 'N/A')}")
            print("\nDense Captions:")
            for caption in analysis_result.get('dense_captions', []):
                print(f"- {caption}")
            
            return analysis_result
            
        except json.JSONDecodeError as e:
            print(f"JSON 파싱 오류: {e}")
            print(f"원본 응답: {response_text}")
            return None
        except Exception as e:
            print(f"이미지 분석 오류: {e}")
            return None


class IntegratedLLMDescription:
    def __init__(self):
        # Azure OpenAI 관련 설정
        self.endpoint = os.getenv("gpt-endpoint")
        self.deployment = "gpt-4o"
        self.subscription_key = os.getenv("gpt-key")
        self.api_version = "2024-12-01-preview"
        
        if not self.endpoint or not self.subscription_key:
            raise ValueError("Please set the gpt-endpoint and gpt-key in the environment variables.")
        
        # LLM 클라이언트 초기화
        self.client = AzureOpenAI(
            api_version=self.api_version,
            azure_endpoint=self.endpoint,
            api_key=self.subscription_key,
        )
        
        # 대화 기록 초기화
        self.conversation_history = []
        
        # 토큰 카운터 초기화
        self.tokenizer = tiktoken.get_encoding("cl100k_base")  # GPT-4o용 토크나이저
        self.token_count = 0
        self.MAX_TOKENS = 4000  # 최대 토큰 제한
        
        # 이상한 답변 추적
        self.strange_responses = []
        self.strange_response_count = 0
        self.last_question = ""  # 마지막 질문 저장
        self.last_question_type = "normal"  # 마지막 질문 타입
        
        # 대화 기록 추적 (파일 저장용)
        self.conversation_turns = []
        
        # 실시간 대화 시스템 관련 변수
        self.turn_count = 0
        self.image_analysis_result = None  # 이미지 분석 결과 저장
        
        # 키워드 기반 질문
        self.KEYWORD_QUESTIONS = {
            "남편": "남편에게 전하고 싶은 말이 있나요?",
            "아내": "아내분과의 좋은 추억이 또 있나요?",
            "손자": "요즘 손자는 학교 잘 다니나요?",
            "손녀": "손녀는 요즘 뭘 하며 지내나요?",
            "아들": "아들은 요즘 어떻게 지내나요?",
            "딸": "딸과의 추억 중에 특별한 게 있나요?",
            "엄마": "어머님은 어떤 분이셨어요?",
            "아버지": "아버님은 어떤 분이셨나요?",
            "친구": "그 친구분과는 자주 만나셨나요?",
            "여행": "그때 여행이 즐거우셨나요?",
            "집": "그 집에서 살 때가 그리우시나요?",
        }
        
        # 인지 능력 검사 질문 (동적 생성)
        self.base_cognitive_questions = [
            "이 사진에는 몇 명이 있는지 기억나세요?",
            "사진이 낮에 찍힌 것 같나요, 밤인가요?",
            "이 사진에서 가장 눈에 띄는 것이 무엇인가요?",
        ]
        
    def _count_tokens(self, text: str) -> int:
        """문자열의 토큰 수 계산"""
        return len(self.tokenizer.encode(text))
    
    def _count_message_tokens(self, messages: List[Dict[str, Any]]) -> int:
        """대화 메시지 목록의 총 토큰 수 계산"""
        total = 0
        for message in messages:
            total += self._count_tokens(message.get("content", ""))
        return total
    
    def _evaluate_response_relevance(self, question: str, answer: str, question_type: str = "normal") -> Dict[str, Any]:
        """답변이 질문과 얼마나 관련성이 있는지 LLM으로 평가"""
        
        # 질문 타입에 따른 평가 기준 조정
        if question_type == "cognitive":
            evaluation_criteria = """
특별히 이 질문은 인지 능력을 테스트하는 질문입니다. 다음을 중점적으로 평가해주세요:
- 질문에서 요구하는 구체적인 정보를 제공했는지 (예: 숫자, 시간대 등)
- 현실 인식 능력이 적절한지
- 시공간 지남력이 유지되고 있는지
"""
        elif question_type == "keyword":
            evaluation_criteria = """
이 질문은 특정 키워드를 기반으로 한 감정적 연결 질문입니다. 다음을 평가해주세요:
- 질문의 대상(사람이나 상황)에 대한 적절한 반응인지
- 감정적 연결성이 있는지
- 기억과 관련된 적절한 내용인지
"""
        else:
            evaluation_criteria = """
일반적인 대화 질문입니다. 다음을 평가해주세요:
- 질문과 답변의 일반적인 관련성
- 대화의 자연스러운 흐름
"""
        
        evaluation_prompt = f"""
다음 질문과 답변을 분석해서 답변이 얼마나 적절한지 평가해주세요.

질문: {question}
답변: {answer}
질문 타입: {question_type}

{evaluation_criteria}

평가 기준:
1. 질문과 답변의 관련성
2. 답변의 일관성
3. 맥락적 적절성

다음 JSON 형식으로만 답해주세요:
{{
    "is_strange": true/false,
    "severity": "normal/mild/moderate/severe",
    "reason": "평가 이유를 간단히 설명"
}}

severity 기준:
- normal: 완전히 적절한 답변
- mild: 약간 벗어났지만 이해 가능
- moderate: 상당히 엉뚱하지만 완전히 무관하지는 않음
- severe: 완전히 무관하거나 비논리적인 답변
"""
        
        try:
            response = self.client.chat.completions.create(
                model=self.deployment,
                messages=[
                    {"role": "system", "content": "당신은 치매 환자의 답변을 평가하는 의료 전문가입니다. 객관적이고 정확하게 평가해주세요."},
                    {"role": "user", "content": evaluation_prompt}
                ],
                max_tokens=256,
                temperature=0.1,  # 일관된 평가를 위해 낮은 temperature
                top_p=1.0,
            )
            
            evaluation_text = response.choices[0].message.content
            
            # JSON 부분만 추출
            if "```json" in evaluation_text:
                json_start = evaluation_text.find("```json") + 7
                json_end = evaluation_text.find("```", json_start)
                evaluation_text = evaluation_text[json_start:json_end].strip()
            elif "{" in evaluation_text:
                json_start = evaluation_text.find("{")
                json_end = evaluation_text.rfind("}") + 1
                evaluation_text = evaluation_text[json_start:json_end]
            
            evaluation_json = json.loads(evaluation_text)
            return evaluation_json
            
        except (json.JSONDecodeError, Exception) as e:
            print(f"답변 평가 중 오류 발생: {e}")
            # 기본값 반환
            return {
                "is_strange": False,
                "severity": "normal",
                "reason": "평가 실패"
            }
    
    def _store_strange_response(self, question: str, answer: str, severity: str, reason: str, question_type: str = "normal"):
        """이상한 답변을 저장 (콘솔 출력 제거)"""
        strange_response = StrangeResponse(
            question=question,
            answer=answer,
            timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            severity=severity,
            question_type=question_type
        )
        
        self.strange_responses.append(strange_response)
        self.strange_response_count += 1
    
    def _generate_dynamic_cognitive_questions(self):
        """이미지 분석 결과를 바탕으로 동적 인지 질문 생성"""
        if not self.image_analysis_result:
            return self.base_cognitive_questions
        
        dynamic_questions = []
        
        # 사람 수 관련 질문
        people_count = self.image_analysis_result.get('people_count', 0)
        if people_count > 0:
            dynamic_questions.append(f"이 사진에는 몇 명이 있는지 기억나세요?")
        
        # 시간대 관련 질문
        time_of_day = self.image_analysis_result.get('time_of_day', '')
        if time_of_day:
            dynamic_questions.append(f"사진이 낮에 찍힌 것 같나요, 밤인가요?")
        
        # 주요 객체 관련 질문
        key_objects = self.image_analysis_result.get('key_objects', [])
        if key_objects:
            obj = random.choice(key_objects)
            dynamic_questions.append(f"이 사진에서 {obj}이(가) 보이시나요?")
        
        # 기본 질문과 합쳐서 반환
        all_questions = self.base_cognitive_questions + dynamic_questions
        return all_questions
    
    def setup_conversation_context(self, analysis_result, user_description="", user_description_date=""):
        """대화 컨텍스트 설정 (통합 버전)"""
        self.image_analysis_result = analysis_result  # 이미지 분석 결과 저장
        
        caption = analysis_result.get("caption", "")
        dense_captions = analysis_result.get("dense_captions", [])
        mood = analysis_result.get("mood", "")
        time_period = analysis_result.get("time_period", "")
        key_objects = analysis_result.get("key_objects", [])
        people_description = analysis_result.get("people_description", "")
        
        # 상세 캡션 텍스트 포맷팅
        dense_captions_text = "\n".join([f"- {dc}" for dc in dense_captions])
        key_objects_text = ", ".join(key_objects)
        
        # 통합된 시스템 메시지 설정
        system_message = f"""너는 노인과 대화하는 요양보호사야. 노인과 특정 이미지에 대해서 질의응답을 주고받아. 
노인은 치매 증상이 갑자기 나타날 수도 있어. 반복되는 말에도 똑같이 대답해줘야 해. 
친절하고 어른을 공경하는 말투여야 해. 그리고 공감을 잘 해야 해. 예의도 지켜. 
너는 주로 질문을 하는 쪽이고, 노인은 대답을 해줄거야. 대답에 대한 리액션과 함께 적절히 대화를 이어 가.
노인의 발언이 끝나면 그와 관련된 공감 문장을 먼저 말한 후, 자연스럽게 그 기억에 대해 더 물어보는 꼬리 질문을 덧붙여.

=== 이미지 분석 결과 ===
주요 설명(Caption): {caption}
분위기/감정: {mood}
추정 시대: {time_period}
주요 객체들: {key_objects_text}
인물 설명: {people_description}

세부 요소들:
{dense_captions_text}

=== 대화 가이드라인 ===
1. 어르신들(특히 치매 환자)과 대화한다고 가정하고 친근하고 따뜻하게 대화하세요.
2. 이미지에 대한 흥미로운 질문을 먼저 던져 대화를 시작하세요.
3. 사용자가 엉뚱한 답변을 해도 자연스럽게 이어가며 친절하게 이끌어주세요.
4. 그때 당시의 감정이나 경험에 대해 물어보며 추억을 되살려주세요.

=== 대화 전략 ===
문제 상황별 해결 방법:

▪ 질문을 이해하지 못할 경우:
  - 질문을 단순화하여 재구성
  - 선택지를 제공하여 답하기 쉽게 만들기
  - 예시나 맥락을 함께 제공

▪ 엉뚱한 대답을 할 경우:
  - 대답을 수용하면서 자연스럽게 주제로 유도
  - 대답의 일부분이라도 연결점을 찾아 이어가기

▪ 대답을 못할 경우:
  - 심리적 부담 없이 넘어가기
  - "기억이 안 나셔도 괜찮다"고 안심시키기

이미지의 시각적 요소들을 생생하게 묘사하며, 그때의 감정과 상황에 대해 궁금해하는 손자/손녀의 마음으로 대화하세요."""
        
        # 대화 기록 초기화 및 토큰 수 계산
        self.conversation_history = [{"role": "system", "content": system_message}]
        self.token_count = self._count_tokens(system_message)
        
        return system_message
    
    def generate_initial_question(self):
        """첫 질문 생성 함수"""
        response = self.client.chat.completions.create(
            model=self.deployment,
            messages=self.conversation_history + [
                {"role": "user", "content": "이 옛날 사진에 대해 어르신에게 물어볼 첫 질문을 만들어주세요. 간단하고 기억하기 쉬우며, 감정적으로 연결될 수 있는 질문이어야 합니다."}
            ],
            max_tokens=512,
            temperature=0.8,
            top_p=1.0,
        )
        
        initial_question = response.choices[0].message.content
        
        # 질문 추가 및 토큰 수 업데이트
        self.conversation_history.append({"role": "assistant", "content": initial_question})
        self.token_count += self._count_tokens(initial_question)
        
        # 마지막 질문 저장
        self.last_question = initial_question
        self.last_question_type = "normal"
        
        return initial_question
    
    def _get_next_question_type_and_content(self, user_input):
        """다음 질문의 타입과 내용을 결정하는 통합 로직"""
        self.turn_count += 1
        
        # 1. 키워드 기반 질문 체크 (우선순위 1)
        for keyword, question in self.KEYWORD_QUESTIONS.items():
            if keyword in user_input:
                return "keyword", question
        
        # 2. 인지 능력 검사 질문 (3턴마다, 우선순위 2)
        if self.turn_count > 0 and self.turn_count % 3 == 0:
            cognitive_questions = self._generate_dynamic_cognitive_questions()
            question = random.choice(cognitive_questions)
            return "cognitive", question
        
        # 3. 일반 대화 계속 (우선순위 3)
        return "normal", None
    
    def chat_about_image(self, user_query):
        """사용자 질문에 대한 응답 생성 (통합 버전)"""
        # 토큰 제한 확인
        user_tokens = self._count_tokens(user_query)
        
        # 사용자 답변의 적절성 평가 (이전 질문이 있는 경우)
        if self.last_question:
            evaluation = self._evaluate_response_relevance(
                self.last_question, 
                user_query, 
                self.last_question_type
            )
            
            if evaluation.get("is_strange", False):
                severity = evaluation.get("severity", "mild")
                reason = evaluation.get("reason", "관련성 부족")
                
                # 이상한 답변 저장
                self._store_strange_response(
                    question=self.last_question,
                    answer=user_query,
                    severity=severity,
                    reason=reason,
                    question_type=self.last_question_type
                )
        
        # 대화 턴 저장 (질문-답변 쌍)
        if self.last_question:
            conversation_turn = ConversationTurn(
                question=self.last_question,
                answer=user_query,
                timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                question_type=self.last_question_type
            )
            self.conversation_turns.append(conversation_turn)
        
        # 사용자 입력 추가
        self.conversation_history.append({"role": "user", "content": user_query})
        self.token_count += user_tokens
        
        # 토큰 제한 초과 확인
        if self.token_count > self.MAX_TOKENS:
            answer = "죄송합니다, 나중에 다시 얘기해요. 지금은 잠시 쉬어야 할 것 같아요. 만약 더 많은 대화를 원한다면 MEMENTO BOX Premium을 사용해보세요."
            self.conversation_history.append({"role": "assistant", "content": answer})
            return answer, True, "normal"  # True는 대화 종료 신호
        
        # 다음 질문 타입과 내용 결정
        next_question_type, special_question = self._get_next_question_type_and_content(user_query)
        
        if special_question:
            # 특별 질문 (키워드 기반 또는 인지 검사)
            answer = special_question
            question_type = next_question_type
        else:
            # 일반 LLM 응답 생성
            response = self.client.chat.completions.create(
                model=self.deployment,
                messages=self.conversation_history,
                max_tokens=1024,
                temperature=0.7,
                top_p=1.0,
            )
            answer = response.choices[0].message.content
            question_type = "normal"
        
        # 응답 추가 및 토큰 수 업데이트
        self.conversation_history.append({"role": "assistant", "content": answer})
        self.token_count += self._count_tokens(answer)
        
        # 다음 평가를 위해 현재 AI 응답을 질문으로 저장
        self.last_question = answer
        self.last_question_type = question_type
        
        # 토큰 제한 초과 확인 (응답 후)
        if self.token_count > self.MAX_TOKENS:
            return answer, True, question_type  # 대화 종료 신호
        
        return answer, False, question_type  # 대화 계속
    
    def generate_mobile_report(self, image_path, output_dir="reports"):
        """모바일 화면에 최적화된 리포트 생성 (개선된 버전)"""
        
        # 한글 폰트 설정 (시스템에 있는 한글 폰트 찾기)
        try:
            # Windows
            font_path = "C:/Windows/Fonts/malgun.ttf"
            if not os.path.exists(font_path):
                # macOS
                font_path = "/System/Library/Fonts/AppleGothic.ttf"
                if not os.path.exists(font_path):
                    # Linux (Ubuntu)
                    font_path = "/usr/share/fonts/truetype/nanum/NanumGothic.ttf"
            
            if os.path.exists(font_path):
                font_prop = fm.FontProperties(fname=font_path)
                plt.rcParams['font.family'] = font_prop.get_name()
            else:
                # 기본 폰트 사용
                plt.rcParams['font.family'] = 'DejaVu Sans'
        except:
            plt.rcParams['font.family'] = 'DejaVu Sans'
        
        plt.rcParams['axes.unicode_minus'] = False
        
        # 리포트 디렉토리 생성
        os.makedirs(output_dir, exist_ok=True)
        
        # 전체 답변 횟수 계산
        total_responses = len(self.conversation_turns)
        
        if total_responses == 0:
            print("대화가 진행되지 않았습니다.")
            return None
        
        # 심각도별 분류
        severity_counts = {"mild": 0, "moderate": 0, "severe": 0}
        question_type_counts = {"normal": 0, "keyword": 0, "cognitive": 0}
        
        for response in self.strange_responses:
            severity_counts[response.severity] += 1
        
        for turn in self.conversation_turns:
            question_type_counts[turn.question_type] += 1
        
        # 위험도 점수 계산
        risk_score = (severity_counts['mild'] * 1 + 
                     severity_counts['moderate'] * 3 + 
                     severity_counts['severe'] * 5)
        max_risk_score = self.strange_response_count * 5 if self.strange_response_count > 0 else 1
        risk_percentage = (risk_score / max_risk_score * 100) if max_risk_score > 0 else 0
        
        # 모바일 화면에 최적화된 세로형 레이아웃 생성
        fig = plt.figure(figsize=(9, 16), facecolor='#f8f9fa')  # 더 깔끔한 배경색
        
        # 전체 타이틀 추가
        fig.suptitle('통합 치매 진단 대화 분석 리포트', fontsize=18, fontweight='bold', y=0.98, color='#2c3e50')
        
        # 1. 상단: 원본 이미지 표시
        ax1 = plt.subplot2grid((8, 2), (0, 0), colspan=2, rowspan=1)
        try:
            img = Image.open(image_path)
            # 이미지 크기 조정 (모바일 화면에 맞게)
            img.thumbnail((500, 300), Image.Resampling.LANCZOS)
            ax1.imshow(img)
            ax1.axis('off')
            # 이미지 테두리 추가
            for spine in ax1.spines.values():
                spine.set_visible(True)
                spine.set_linewidth(2)
                spine.set_color('#34495e')
        except Exception as e:
            ax1.text(0.5, 0.5, f'이미지 로드 실패\n{os.path.basename(image_path)}', 
                    ha='center', va='center', fontsize=12, 
                    bbox=dict(boxstyle="round,pad=0.5", facecolor="#e74c3c", alpha=0.8, edgecolor='none'))
            ax1.set_xlim(0, 1)
            ax1.set_ylim(0, 1)
            ax1.axis('off')
        
        # 2. 왼쪽: 주요 수치 표시
        ax2 = plt.subplot2grid((8, 2), (1, 0), rowspan=2)
        ax2.axis('off')
        
        # 수치 정보 텍스트 (더 깔끔하게)
        stats_text = f"""[통합 대화 분석 결과]

▪ 전체 답변: {total_responses}회
▪ 이상 답변: {self.strange_response_count}회 ({(self.strange_response_count/total_responses*100):.1f}%)
▪ 위험도: {risk_percentage:.1f}% ({risk_score}/{max_risk_score}점)

대화 타입별 분류:
  ● 일반: {question_type_counts['normal']}회
  ● 키워드: {question_type_counts['keyword']}회
  ● 인지검사: {question_type_counts['cognitive']}회

심각도별 분류:
  ● 경미: {severity_counts['mild']}회
  ● 보통: {severity_counts['moderate']}회  
  ● 심각: {severity_counts['severe']}회"""
        
        ax2.text(0.05, 0.95, stats_text, fontsize=11, va='top', 
                bbox=dict(boxstyle="round,pad=0.8", facecolor="#ecf0f1", alpha=0.9, 
                         edgecolor='#bdc3c7', linewidth=1.5))
        
        # 3. 오른쪽: 상세 기록 예시
        ax3 = plt.subplot2grid((8, 2), (1, 1), rowspan=2)
        ax3.axis('off')
        
        # 상세 기록 예시 텍스트
        detail_examples = "[상세 기록 예시]\n\n"
        
        if self.strange_response_count > 0:
            # 최대 3개 예시만 표시
            examples_to_show = min(3, len(self.strange_responses))
            for i, response in enumerate(self.strange_responses[:examples_to_show]):
                severity_symbol = {"mild": "●", "moderate": "●", "severe": "●"}
                severity_name = {"mild": "경미", "moderate": "보통", "severe": "심각"}
                type_name = {"normal": "일반", "keyword": "키워드", "cognitive": "인지"}
                
                detail_examples += f"{severity_symbol[response.severity]} [{severity_name[response.severity]}][{type_name[response.question_type]}]\n"
                detail_examples += f"Q: {response.question[:20]}...\n"
                detail_examples += f"A: {response.answer[:20]}...\n\n"
            
            if len(self.strange_responses) > 3:
                detail_examples += f"... 외 {len(self.strange_responses) - 3}건 더"
        else:
            detail_examples += "✓ 이상 답변이 감지되지\n    않았습니다.\n\n정상적인 대화가\n진행되었습니다."
        
        ax3.text(0.05, 0.95, detail_examples, fontsize=10, va='top',
                bbox=dict(boxstyle="round,pad=0.8", facecolor="#fff3cd" if self.strange_response_count > 0 else "#d4edda", 
                         alpha=0.9, edgecolor='#ffeaa7' if self.strange_response_count > 0 else '#c3e6cb', linewidth=1.5))
        
        # 4. 왼쪽: 전체 대화 분석 바 그래프
        ax4 = plt.subplot2grid((8, 2), (3, 0), rowspan=2)
        
        categories = ['정상\n답변', '이상\n답변']
        counts = [total_responses - self.strange_response_count, self.strange_response_count]
        colors = ['#27ae60', '#e74c3c']  # 더 선명한 색상
        
        bars1 = ax4.bar(categories, counts, color=colors, alpha=0.8, width=0.6, edgecolor='white', linewidth=2)
        ax4.set_title('대화 분석', fontsize=13, fontweight='bold', pad=15, color='#2c3e50')
        ax4.set_ylabel('답변 횟수', fontsize=11, color='#34495e')
        
        # 바 위에 숫자 표시 (더 깔끔하게)
        for bar, count in zip(bars1, counts):
            height = bar.get_height()
            ax4.text(bar.get_x() + bar.get_width()/2., height + 0.2,
                    f'{count}회', ha='center', va='bottom', fontsize=11, fontweight='bold', color='#2c3e50')
        
        # 그래프 스타일링
        ax4.set_ylim(0, max(counts) * 1.3)
        ax4.grid(axis='y', alpha=0.2, linestyle='--')
        ax4.spines['top'].set_visible(False)
        ax4.spines['right'].set_visible(False)
        ax4.tick_params(colors='#34495e')
        
        # 5. 오른쪽: 심각도별 이상 답변 바 그래프
        ax5 = plt.subplot2grid((8, 2), (3, 1), rowspan=2)
        
        if self.strange_response_count > 0:
            severity_labels = ['경미', '보통', '심각']
            severity_values = [severity_counts['mild'], severity_counts['moderate'], severity_counts['severe']]
            severity_colors = ['#f39c12', '#e67e22', '#e74c3c']  # 더 선명한 색상
            
            bars2 = ax5.bar(severity_labels, severity_values, color=severity_colors, alpha=0.8, 
                           width=0.6, edgecolor='white', linewidth=2)
            ax5.set_title('이상 답변 심각도', fontsize=13, fontweight='bold', pad=15, color='#2c3e50')
            ax5.set_ylabel('답변 횟수', fontsize=11, color='#34495e')
            
            # 바 위에 숫자 표시
            for bar, count in zip(bars2, severity_values):
                height = bar.get_height()
                if height > 0:
                    ax5.text(bar.get_x() + bar.get_width()/2., height + 0.05,
                            f'{count}회', ha='center', va='bottom', fontsize=11, fontweight='bold', color='#2c3e50')
            
            ax5.set_ylim(0, max(severity_values) * 1.4 if max(severity_values) > 0 else 1)
            ax5.grid(axis='y', alpha=0.2, linestyle='--')
            ax5.spines['top'].set_visible(False)
            ax5.spines['right'].set_visible(False)
            ax5.tick_params(colors='#34495e')
        else:
            ax5.text(0.5, 0.5, '이상 답변 없음', ha='center', va='center', 
                    fontsize=13, fontweight='bold', color='#27ae60', transform=ax5.transAxes,
                    bbox=dict(boxstyle="round,pad=0.5", facecolor="#d4edda", alpha=0.8, edgecolor='#c3e6cb'))
            ax5.set_xlim(0, 1)
            ax5.set_ylim(0, 1)
            ax5.axis('off')
        
        # 6. 새로 추가: 질문 타입별 분석
        ax6 = plt.subplot2grid((8, 2), (5, 0), colspan=2, rowspan=1)
        
        type_labels = ['일반 대화', '키워드 기반', '인지 검사']
        type_values = [question_type_counts['normal'], question_type_counts['keyword'], question_type_counts['cognitive']]
        type_colors = ['#3498db', '#9b59b6', '#e67e22']
        
        bars3 = ax6.bar(type_labels, type_values, color=type_colors, alpha=0.8, 
                       width=0.6, edgecolor='white', linewidth=2)
        ax6.set_title('질문 타입별 대화 분석', fontsize=13, fontweight='bold', pad=15, color='#2c3e50')
        ax6.set_ylabel('대화 횟수', fontsize=11, color='#34495e')
        
        # 바 위에 숫자 표시
        for bar, count in zip(bars3, type_values):
            height = bar.get_height()
            if height > 0:
                ax6.text(bar.get_x() + bar.get_width()/2., height + 0.1,
                        f'{count}회', ha='center', va='bottom', fontsize=11, fontweight='bold', color='#2c3e50')
        
        ax6.set_ylim(0, max(type_values) * 1.4 if max(type_values) > 0 else 1)
        ax6.grid(axis='y', alpha=0.2, linestyle='--')
        ax6.spines['top'].set_visible(False)
        ax6.spines['right'].set_visible(False)
        ax6.tick_params(colors='#34495e')
        
        # 7. 새로 추가: 인지 검사 결과 상세
        ax7 = plt.subplot2grid((8, 2), (6, 0), colspan=2, rowspan=1)
        ax7.axis('off')
        
        # 인지 검사 관련 이상 답변 분석
        cognitive_strange = [r for r in self.strange_responses if r.question_type == "cognitive"]
        keyword_strange = [r for r in self.strange_responses if r.question_type == "keyword"]
        normal_strange = [r for r in self.strange_responses if r.question_type == "normal"]
        
        cognitive_analysis = f"""[질문 타입별 이상 답변 분석]

● 인지 검사 질문: {question_type_counts['cognitive']}회 중 {len(cognitive_strange)}회 이상 ({(len(cognitive_strange)/question_type_counts['cognitive']*100):.1f}% 이상률)
● 키워드 기반 질문: {question_type_counts['keyword']}회 중 {len(keyword_strange)}회 이상 ({(len(keyword_strange)/question_type_counts['keyword']*100 if question_type_counts['keyword'] > 0 else 0):.1f}% 이상률)
● 일반 대화: {question_type_counts['normal']}회 중 {len(normal_strange)}회 이상 ({(len(normal_strange)/question_type_counts['normal']*100 if question_type_counts['normal'] > 0 else 0):.1f}% 이상률)

※ 인지 검사에서의 이상 답변은 특히 주의 깊게 관찰해야 합니다."""
        
        ax7.text(0.05, 0.95, cognitive_analysis, fontsize=11, va='top',
                bbox=dict(boxstyle="round,pad=0.8", facecolor="#e8f4fd", alpha=0.9, 
                         edgecolor='#85c1e9', linewidth=1.5))
        
        # 전체 레이아웃 조정
        plt.tight_layout(rect=[0, 0.08, 1, 0.95], pad=2.0)
        
        # 8. 하단: 권장사항 (더 정교한 판단 기준)
        cognitive_risk = len(cognitive_strange) / question_type_counts['cognitive'] * 100 if question_type_counts['cognitive'] > 0 else 0
        
        if severity_counts['severe'] >= 2 or risk_percentage > 80 or cognitive_risk > 60:
            recommendation = "[긴급] 전문의 상담 시급"
            rec_color = '#e74c3c'
            bg_color = '#fadbd8'
        elif severity_counts['severe'] >= 1 or risk_percentage > 60 or cognitive_risk > 40:
            recommendation = "[주의] 관찰 필요"
            rec_color = '#e67e22'
            bg_color = '#fdeaa7'
        elif risk_percentage > 40 or cognitive_risk > 30:
            recommendation = "[안내] 정기적 관찰 권장"
            rec_color = '#f39c12'
            bg_color = '#fcf3cf'
        else:
            recommendation = "[정상] 양호한 상태"
            rec_color = '#27ae60'
            bg_color = '#d5f4e6'
        
        # 권장사항 박스 (더 크고 눈에 띄게)
        fig.text(0.5, 0.04, recommendation, ha='center', va='center', 
                fontsize=16, fontweight='bold', color=rec_color,
                bbox=dict(boxstyle="round,pad=1.0", facecolor=bg_color, alpha=0.9, 
                         edgecolor=rec_color, linewidth=2))
        
        # 파일명 생성
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        image_basename = os.path.splitext(os.path.basename(image_path))[0]
        report_filename = os.path.join(output_dir, f"{image_basename}_integrated_report_{timestamp}.png")
        
        # 고해상도로 저장 (모바일 화면용)
        plt.savefig(report_filename, dpi=200, bbox_inches='tight', 
                    facecolor='#f8f9fa', edgecolor='none', format='png')
        plt.close()
        
        print(f"📱 통합 모바일 리포트가 생성되었습니다: {report_filename}")
        return report_filename
    
    def get_conversation_summary(self):
        """대화 종료 후 이상한 답변 요약 제공 (통합 버전)"""
        # 전체 답변 횟수 계산
        total_responses = len(self.conversation_turns)
        
        if total_responses == 0:
            return "대화가 진행되지 않았습니다."
        
        if self.strange_response_count == 0:
            return f"🎉 대화 중 특별히 이상한 답변은 없었습니다. 좋은 대화였어요!\n전체 답변 횟수: {total_responses}회"
        
        summary = f"\n{'='*60}\n"
        summary += f"📊 통합 대화 종료 - 분석 결과\n"
        summary += f"{'='*60}\n"
        summary += f"📌 전체 답변 횟수: {total_responses}회\n"
        summary += f"🔍 이상한 답변 횟수: {self.strange_response_count}회 ({(self.strange_response_count/total_responses*100):.1f}%)\n\n"
        
        # 질문 타입별 분류
        question_type_counts = {"normal": 0, "keyword": 0, "cognitive": 0}
        for turn in self.conversation_turns:
            question_type_counts[turn.question_type] += 1
        
        summary += f"질문 타입별 대화 분석:\n"
        summary += f"  • 일반 대화: {question_type_counts['normal']}회\n"
        summary += f"  • 키워드 기반: {question_type_counts['keyword']}회\n"
        summary += f"  • 인지 검사: {question_type_counts['cognitive']}회\n\n"
        
        # 심각도별 분류
        severity_counts = {"mild": 0, "moderate": 0, "severe": 0}
        for response in self.strange_responses:
            severity_counts[response.severity] += 1
        
        summary += f"이상한 답변 중 심각도별 분류:\n"
        summary += f"  • 경미 (Mild): {severity_counts['mild']}회 ({(severity_counts['mild']/self.strange_response_count*100):.1f}%)\n"
        summary += f"  • 보통 (Moderate): {severity_counts['moderate']}회 ({(severity_counts['moderate']/self.strange_response_count*100):.1f}%)\n"
        summary += f"  • 심각 (Severe): {severity_counts['severe']}회 ({(severity_counts['severe']/self.strange_response_count*100):.1f}%)\n\n"
        
        # 질문 타입별 이상 답변 분석
        cognitive_strange = [r for r in self.strange_responses if r.question_type == "cognitive"]
        keyword_strange = [r for r in self.strange_responses if r.question_type == "keyword"]
        normal_strange = [r for r in self.strange_responses if r.question_type == "normal"]
        
        summary += f"질문 타입별 이상 답변 분석:\n"
        summary += f"  • 인지 검사: {len(cognitive_strange)}회 ({(len(cognitive_strange)/question_type_counts['cognitive']*100 if question_type_counts['cognitive'] > 0 else 0):.1f}% 이상률)\n"
        summary += f"  • 키워드 기반: {len(keyword_strange)}회 ({(len(keyword_strange)/question_type_counts['keyword']*100 if question_type_counts['keyword'] > 0 else 0):.1f}% 이상률)\n"
        summary += f"  • 일반 대화: {len(normal_strange)}회 ({(len(normal_strange)/question_type_counts['normal']*100 if question_type_counts['normal'] > 0 else 0):.1f}% 이상률)\n\n"
        
        # 가중치 기반 위험도 점수 계산
        # 경미: 1점, 보통: 3점, 심각: 5점
        risk_score = (severity_counts['mild'] * 1 + 
                     severity_counts['moderate'] * 3 + 
                     severity_counts['severe'] * 5)
        
        # 최대 가능 점수 계산 (모든 이상한 답변이 severe인 경우)
        max_risk_score = self.strange_response_count * 5
        
        # 위험도 퍼센트 계산
        risk_percentage = (risk_score / max_risk_score * 100)
        
        summary += f"위험도 점수: {risk_score}점 / {max_risk_score}점 ({risk_percentage:.1f}%)\n"
        summary += f"   (경미=1점, 보통=3점, 심각=5점 가중치 적용)\n\n"
        
        summary += f"상세 기록:\n"
        for i, response in enumerate(self.strange_responses, 1):
            type_name = {"normal": "일반", "keyword": "키워드", "cognitive": "인지검사"}
            summary += f"\n{i}. [{response.severity.upper()}][{type_name[response.question_type]}] {response.timestamp}\n"
            summary += f"   질문: {response.question[:80]}{'...' if len(response.question) > 80 else ''}\n"
            summary += f"   답변: {response.answer[:80]}{'...' if len(response.answer) > 80 else ''}\n"
        
        # 권장사항 - 위험도 점수와 심각 답변, 인지 검사 결과 기반으로 판단
        cognitive_risk = len(cognitive_strange) / question_type_counts['cognitive'] * 100 if question_type_counts['cognitive'] > 0 else 0
        
        if severity_counts['severe'] >= 2 or risk_percentage > 80 or cognitive_risk > 60:
            summary += f"\n⚠️  권장사항: 심각한 수준의 이상 답변이 {severity_counts['severe']}회 관찰되었으며, "
            summary += f"전체 위험도가 {risk_percentage:.1f}%, 인지검사 이상률이 {cognitive_risk:.1f}%로 매우 높습니다. "
            summary += f"즉시 전문의 상담을 받으시기 바랍니다.\n"
        elif severity_counts['severe'] >= 1 or risk_percentage > 60 or cognitive_risk > 40:
            summary += f"\n🔶 권장사항: 심각한 답변이 포함되어 있으며, 위험도가 {risk_percentage:.1f}%, "
            summary += f"인지검사 이상률이 {cognitive_risk:.1f}%입니다. 전문의 상담을 권장합니다.\n"
        elif risk_percentage > 40 or cognitive_risk > 30:
            summary += f"\n🔷 권장사항: 이상 답변의 위험도가 {risk_percentage:.1f}%, 인지검사 이상률이 {cognitive_risk:.1f}%로 "
            summary += f"중간 수준입니다. 정기적인 관찰과 추적 검사를 받으시기 바랍니다.\n"
        elif risk_percentage > 20:
            summary += f"\n💙 권장사항: 이상 답변의 위험도가 {risk_percentage:.1f}%로 경미한 수준입니다. "
            summary += f"주기적인 관찰을 계속하시기 바랍니다.\n"
        else:
            summary += f"\n💚 이상 답변의 위험도가 {risk_percentage:.1f}%로 낮은 수준입니다. "
            summary += f"현재 상태를 잘 유지하시기 바랍니다.\n"
        
        # 추가 안내사항
        if cognitive_risk > 30:
            summary += f"\n⚠️  참고: 인지 검사에서의 이상률이 {cognitive_risk:.1f}%로 높게 나타났습니다. "
            summary += f"시공간 지남력과 인지 기능에 특별한 주의가 필요합니다.\n"
        
        if severity_counts['severe'] > 0:
            summary += f"\n📝 참고: 심각한 답변은 시공간 지남력 상실, 완전한 맥락 이탈 등을 의미합니다.\n"
        
        summary += f"{'='*60}\n"
        
        return summary
    
    def generate_story_from_conversation(self, image_path):
        """대화 내용을 바탕으로 노인분의 관점에서 스토리 생성"""
        # 대화 내용 정리
        conversation_text = ""
        for turn in self.conversation_turns:
            type_name = {"normal": "일반", "keyword": "키워드", "cognitive": "인지검사"}
            conversation_text += f"[{type_name[turn.question_type]}] 질문: {turn.question}\n답변: {turn.answer}\n\n"
        
        # 스토리 생성을 위한 프롬프트
        story_prompt = f"""
다음은 한 어르신이 옛날 사진을 보며 나눈 대화입니다:

{conversation_text}

이 대화 내용을 바탕으로, 사진 속 순간에 대한 어르신의 추억을 1인칭 시점으로 15줄 정도의 이야기로 작성해주세요.

작성 지침:
1. 어르신의 감정과 당시의 느낌을 생생하게 표현
2. 구체적인 감각적 묘사 포함 (소리, 냄새, 촉감 등)
3. 따뜻하고 향수를 불러일으키는 톤
4. 대화에서 언급된 내용을 자연스럽게 포함
5. 마치 손자/손녀에게 들려주는 것처럼 친근한 어투
6. 키워드 기반 대화와 인지검사 내용도 자연스럽게 반영

스토리만 작성하고 다른 설명은 하지 마세요.
"""
        
        try:
            response = self.client.chat.completions.create(
                model=self.deployment,
                messages=[
                    {"role": "system", "content": "당신은 노인의 추억을 아름답게 재구성하는 스토리텔러입니다."},
                    {"role": "user", "content": story_prompt}
                ],
                max_tokens=1024,
                temperature=0.8,
                top_p=1.0,
            )
            
            story = response.choices[0].message.content
            
            # story_telling 폴더 생성
            story_dir = "story_telling"
            os.makedirs(story_dir, exist_ok=True)
            
            # 이미지 파일명에서 확장자 제거하여 스토리 파일명 생성
            image_basename = os.path.splitext(os.path.basename(image_path))[0]
            story_filename = os.path.join(story_dir, f"{image_basename}_integrated.txt")
            
            # 스토리 파일 저장
            with open(story_filename, 'w', encoding='utf-8') as f:
                f.write(story)
            
            print(f"통합 추억 이야기가 '{story_filename}' 파일로 저장되었습니다.")
            
            return story, story_filename
            
        except Exception as e:
            print(f"스토리 생성 중 오류 발생: {e}")
            return None, None
    
    def save_conversation_to_file(self, filename_prefix="integrated_conversation", image_path=None):
        """대화 내용을 텍스트 파일로 저장 (통합 버전)"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 이미지 파일명 추출 (확장자 제외)
        if image_path:
            image_basename = os.path.splitext(os.path.basename(image_path))[0]
            base_filename = f"{image_basename}_integrated_{timestamp}"
        else:
            base_filename = f"{filename_prefix}_{timestamp}"
        
        # 폴더 생성 (없는 경우)
        conversation_dir = "conversation_log"
        analysis_dir = "analysis"
        os.makedirs(conversation_dir, exist_ok=True)
        os.makedirs(analysis_dir, exist_ok=True)
        
        # 대화 기록 파일 저장
        conversation_filename = os.path.join(conversation_dir, f"{base_filename}.txt")
        with open(conversation_filename, 'w', encoding='utf-8') as f:
            f.write(f"=== 통합 대화 기록 ===\n")
            f.write(f"생성 시간: {datetime.now().strftime('%Y년 %m월 %d일 %H:%M:%S')}\n")
            f.write(f"{'='*50}\n\n")
            
            for i, turn in enumerate(self.conversation_turns, 1):
                type_name = {"normal": "일반대화", "keyword": "키워드기반", "cognitive": "인지검사"}
                f.write(f"[대화 {i}] {turn.timestamp} [{type_name[turn.question_type]}]\n")
                f.write(f"질문: {turn.question}\n")
                f.write(f"답변: {turn.answer}\n")
                f.write(f"{'-'*30}\n\n")
        
        print(f"통합 대화 기록이 '{conversation_filename}' 파일로 저장되었습니다.")
        
        # 이상 답변 분석 파일 저장
        analysis_filename = None
        if self.strange_response_count > 0:
            analysis_filename = os.path.join(analysis_dir, f"{base_filename}_analysis.txt")
            with open(analysis_filename, 'w', encoding='utf-8') as f:
                f.write(self.get_conversation_summary())
            
            print(f"통합 이상 답변 분석이 '{analysis_filename}' 파일로 저장되었습니다.")
        
        return conversation_filename, analysis_filename


def analyze_and_describe_image_integrated(image_path, user_description="", user_description_date=""):
    """이미지 분석 및 설명 통합 함수 (통합 버전)"""
    # 1. GPT-4o 이미지 분석 객체 생성
    analyzer = ImageAnalysisGPT()
    
    # 2. 이미지 분석 수행
    print(f"GPT-4o로 이미지 분석 중: {image_path}")
    analysis_result = analyzer.analyze_image_with_gpt(image_path)
    
    if not analysis_result:
        return "이미지 분석에 실패했습니다.", None, None
    
    # 3. 통합 LLM 대화 객체 생성
    llm_chat = IntegratedLLMDescription()
    
    # 4. 대화 컨텍스트 설정
    print("\n통합 대화 컨텍스트 설정 중...")
    llm_chat.setup_conversation_context(
        analysis_result, 
        user_description, 
        user_description_date
    )
    
    # 5. 결과 출력
    print("\n===== 통합 GPT-4o 이미지 분석 완료 =====")
    print("🔄 실시간 대화 시스템 + 복잡한 분석 시스템이 준비되었습니다.")
    print("✨ 키워드 기반 질문, 인지 검사, 이상 답변 감지 기능이 모두 활성화됩니다.")
    
    return "통합 시스템 준비 완료", llm_chat, image_path


# 메인 실행부 (통합 버전)
if __name__ == "__main__":
    # 분석할 이미지 경로 입력
    image_path = "images.jpg"  # DB에서 가져온 이미지 경로로 변경 필요
    
    # 이미지 파일 존재 확인
    if not os.path.exists(image_path):
        print(f"오류: 파일이 존재하지 않습니다 - {image_path}")
        exit(1)
    
    # user_description_date = input("사진의 날짜를 입력해주세요 (예: 1980년대, 2000년 여름): ")
    # user_description = input("사진에 대한 설명을 입력해주세요: ")  --> 두부분도 DB에서 가져와야함
    
    # 통합 이미지 분석 및 대화 시스템 초기화
    result, llm_chat, img_path = analyze_and_describe_image_integrated(
        image_path
        # user_description, 
        # user_description_date
    )
    
    if llm_chat:
        print("\n===== 통합 이미지 대화 시작 =====")
        print("🎯 기능: 실시간 대화 + 키워드 감지 + 인지 검사 + 이상 답변 분석")
        
        # GPT가 먼저 질문 던지기
        initial_question = llm_chat.generate_initial_question()
        print(f"\n🤖 AI: {initial_question}")
        
        print(f"\n💡 대화를 종료하려면 'exit' 또는 '종료'를 입력하세요.")
        print(f"📋 3턴마다 인지 검사 질문이 자동으로 추가됩니다.")
        print(f"🔍 키워드 감지 시 관련 질문이 자동으로 생성됩니다.")
        
        while True:
            user_query = input(f"\n👤 답변을 입력하세요: ")
            
            # 수동 종료 조건 확인
            if user_query.lower() in ['exit', '종료', 'quit', 'q']:
                print("대화를 종료합니다.")
                break
            
            # 통합 GPT에게 사용자 답변 전달 및 토큰 제한 확인
            answer, should_end, question_type = llm_chat.chat_about_image(user_query)
            
            # 질문 타입에 따른 이모지 추가
            type_emoji = {
                "normal": "🤖",
                "keyword": "💝", 
                "cognitive": "🧠"
            }
            
            print(f"\n{type_emoji.get(question_type, '🤖')} AI: {answer}")
            
            # 특별 질문일 때 추가 안내
            if question_type == "keyword":
                print("   💡 키워드 기반 질문이 생성되었습니다.")
            elif question_type == "cognitive":
                print("   🧠 인지 능력 검사 질문입니다.")
            
            # 토큰 제한으로 인한 종료 확인
            if should_end:
                print("\n⏰ 대화 토큰 제한에 도달했습니다. 대화를 종료합니다.")
                break
        
        # 대화 종료 후 파일로 저장
        print("\n📁 대화 기록을 저장하는 중...")
        llm_chat.save_conversation_to_file(image_path=img_path)
        
        # 추억 스토리 생성
        print("\n📖 통합 추억 이야기를 생성하는 중...")
        story, story_file = llm_chat.generate_story_from_conversation(img_path)
        
        if story:
            print(f"\n=== 생성된 통합 추억 이야기 ===\n{story}\n")
        
        # 📱 통합 모바일 리포트 생성
        print("\n📱 통합 모바일 리포트를 생성하는 중...")
        mobile_report_file = llm_chat.generate_mobile_report(img_path)
        
        if mobile_report_file:
            print(f"✅ 통합 모바일 리포트가 성공적으로 생성되었습니다!")
            print(f"📂 파일 경로: {mobile_report_file}")
            print(f"🔍 키워드 기반 질문, 인지 검사, 심각도 분석이 모두 포함되어 있습니다.")
        
        # 콘솔에도 통합 요약 출력
        print(llm_chat.get_conversation_summary())
        
    else:
        print("이미지 분석에 실패하여 대화를 시작할 수 없습니다.")